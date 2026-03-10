import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatListModule } from '@angular/material/list';
import { Observable, Subject } from 'rxjs';
import { tap, takeUntil } from 'rxjs/operators';

import { ScoponeService } from '../../scopone/scopone.service';
import { GamePickerDialogueComponent } from '../game-list/game-picker-dialogue.component';
import { GameListComponent } from '../game-list/game-list.component';
import { NewGameComponent } from '../new-game/new-game.component';

@Component({
  selector: 'scopone-pick-game',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatButtonModule,
    MatListModule,
    GameListComponent,
    NewGameComponent,
  ],
  templateUrl: './pick-game.component.html',
  styleUrls: ['./pick-game.component.css'],
})
export class PickGameComponent implements OnInit, OnDestroy {
  openGames$!: Observable<any>;
  unsubscribe = new Subject<void>();

  constructor(
    public scoponeService: ScoponeService,
    private router: Router
  ) {}

  ngOnInit(): void {
    if (!this.scoponeService.playerName) {
      this.router.navigate(['']);
    }

    this.openGames$ = this.scoponeService.games_ShareReplay$.pipe(
      tap((games: any) => {
        if (games && games.length > 0) {
          const dialogRef = this.scoponeService.dialog.open(GamePickerDialogueComponent, {
            width: '400px',
            height: '400px',
            data: { games },
          });
          dialogRef.afterClosed().subscribe((selectedGame: any) => {
            if (selectedGame) {
              this.scoponeService.addPlayerToGame(this.scoponeService.playerName, selectedGame.name);
              this.router.navigate(['hand']);
            }
          });
        }
      }),
      takeUntil(this.unsubscribe)
    );
  }

  ngOnDestroy() {
    this.unsubscribe.next();
  }

  createGame() {
    this.scoponeService.newGame('New Game');
    this.router.navigate(['hand']);
  }
}
