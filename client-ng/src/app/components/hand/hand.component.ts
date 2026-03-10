import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { Observable, Subject, merge, combineLatest } from 'rxjs';
import { tap, takeUntil, concatMap, switchMap, map } from 'rxjs/operators';
import { AsyncPipe, NgIf } from '@angular/common';

import { ScoponeService } from '../../scopone/scopone.service';
import { CardsPickerDialogueComponent } from './cards-picker-dialogue.component';
import { CardsTakenDialogueComponent } from './cards-taken-dialogue.component';
import { CardsComponent } from '../cards/cards.component';
import { Card, TypeValues } from '../../../../../scopone-rx-service/src/model/card';
import { Team } from '../../../../../scopone-rx-service/src/model/team';
import { HandState } from '../../../../../scopone-rx-service/src/model/hand';
import { TableComponent } from '../table/table.component';

@Component({
  selector: 'scopone-hand',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    CardsComponent,
    TableComponent,
    AsyncPipe,
    NgIf,
  ],
  templateUrl: './hand.component.html',
  styleUrls: ['./hand.component.css'],
})
export class HandComponent implements OnInit, OnDestroy {
  playerCards: Card[] = [];
  table: Card[] = [];
  ourScope: Card[] = [];
  theirScope: Card[] = [];
  teams: [Team, Team] = [{} as Team, {} as Team];
  currentPlayerName = '';

  showStartButton = false;
  canSendCardToServer = false;

  enablePlay$!: Observable<boolean>;
  unsubscribe = new Subject<void>();

  constructor(
    protected scoponeService: ScoponeService,
    public dialog: MatDialog,
    private router: Router
  ) {}

  ngOnInit(): void {
    if (!this.scoponeService.playerName) {
      this.router.navigate(['']);
    }

    const myCurrentGame$ = this.scoponeService.myCurrentOpenGame_ShareReplay$.pipe(
      tap((game: any) => {
        this.teams = game.teams;
        const gameWith4PlayersAndNoHand = Object.keys(game.players).length === 4 && game.hands.length === 0;
        const lastHandClosed = game.hands
          ? game.hands.length > 0
            ? game.hands[game.hands.length - 1].state === HandState.closed
            : false
          : false;
        this.showStartButton = gameWith4PlayersAndNoHand || lastHandClosed;
      })
    );

    const myObservedGame$ = this.scoponeService.myCurrentObservedGame_ShareReplay$.pipe(
      tap((game: any) => {
        this.teams = game.teams;
        this.showStartButton = false;
      })
    );

    const handView$ = this.scoponeService.handView_ShareReplay$.pipe(
      tap((hv: any) => {
        this.playerCards = hv.playerCards
          ? hv.playerCards.sort((a: Card, b: Card) => TypeValues.get(b.type)! - TypeValues.get(a.type)!)
          : null;
        this.table = hv.table;
        this.ourScope = hv.ourScope;
        this.theirScope = hv.theirScope;
        this.currentPlayerName = hv.currentPlayerName;
      })
    );

    const allHandViews$ = this.scoponeService.allHandViews_ShareReplay$.pipe(
      tap((handViews: any) => {
        const values = Object.values(handViews);
        const currentPlayer = values.length > 0 ? (values[0] as any).currentPlayerName : '';
        const currentPlayerHandView = handViews[currentPlayer];
        this.playerCards = currentPlayerHandView?.playerCards
          ? currentPlayerHandView.playerCards.sort((a: Card, b: Card) => TypeValues.get(b.type)! - TypeValues.get(a.type)!)
          : null;
        this.table = currentPlayerHandView?.table || [];
        this.ourScope = currentPlayerHandView?.ourScope || [];
        this.theirScope = currentPlayerHandView?.theirScope || [];
        this.currentPlayerName = currentPlayerHandView?.currentPlayerName || '';
      })
    );

    let cardsTakenDialogueRef: MatDialogRef<CardsTakenDialogueComponent, any>;
    const cardPlayedAndCardsTakenFromTable$ = this.scoponeService.cardsPlayedAndTaken$.pipe(
      concatMap(({ cardPlayed, cardsTaken, cardPlayedByPlayer, finalTableTake }: any) => {
        cardsTakenDialogueRef = this.dialog.open(CardsTakenDialogueComponent, {
          width: '650px',
          height: heightOfCardsTakenDialogue(cardsTaken, finalTableTake),
          data: { cardPlayed, cardsTaken, cardPlayedByPlayer, finalTableTake },
        });
        cardsTakenDialogueRef.disableClose = true;
        return cardsTakenDialogueRef.afterClosed();
      })
    );

    const heightOfCardsTakenDialogue = (cardsTaken: Card[], finalTableTake: any) => {
      const areCardsTaken = !!cardsTaken && cardsTaken.length > 0;
      const areFinalCardsTaken = !!finalTableTake && !!finalTableTake.Cards && finalTableTake.Cards.length > 0;
      return areCardsTaken && areFinalCardsTaken ? '900px' : !areCardsTaken && !areFinalCardsTaken ? '300px' : '600px';
    };

    const handClosed$ = this.scoponeService.handClosed$.pipe(
      switchMap(() => {
        return cardsTakenDialogueRef
          ? cardsTakenDialogueRef.afterClosed().pipe(tap(() => this.router.navigate(['hand-result'])))
          : this.router.navigate(['hand-result']);
      })
    );

    merge(
      myCurrentGame$,
      myObservedGame$,
      handView$,
      allHandViews$,
      cardPlayedAndCardsTakenFromTable$,
      handClosed$
    )
      .pipe(takeUntil(this.unsubscribe))
      .subscribe({
        error: (err) => {
          console.error('Error while communicating with the server', err);
          this.router.navigate(['error']);
        },
      });

    this.enablePlay$ = combineLatest([
      this.scoponeService.isMyTurnToPlay$,
      this.scoponeService.myCurrentOpenGameWithAll4PlayersIn_ShareReplay$,
    ]).pipe(
      map((tuple: any) => {
        const [isMyTurn, all4PlayersIn] = tuple;
        const enable = isMyTurn && all4PlayersIn;
        this.canSendCardToServer = enable;
        return enable;
      })
    );
  }

  ngOnDestroy() {
    this.unsubscribe.next();
  }

  start() {
    this.scoponeService.newHand();
  }

  play(card: Card) {
    this.canSendCardToServer = false;
    const cardsTakeable = this.scoponeService.cardsTakeable(card, this.table);
    if (cardsTakeable.length > 1) {
      const dialogRef = this.dialog.open(CardsPickerDialogueComponent, {
        width: '1250px',
        height: '600px',
        data: { cards: cardsTakeable },
      });
      dialogRef.afterClosed().subscribe((cardsToTake) => {
        this.scoponeService.playCardForPlayer(this.scoponeService.playerName, card, cardsToTake);
      });
    } else {
      this.scoponeService.playCard(card, this.table);
    }
  }
}
