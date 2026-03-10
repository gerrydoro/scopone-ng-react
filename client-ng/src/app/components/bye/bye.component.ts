import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { Observable, Subject } from 'rxjs';
import { tap, takeUntil, map } from 'rxjs/operators';
import { AsyncPipe } from '@angular/common';

import { ScoponeService } from '../../scopone/scopone.service';

@Component({
  selector: 'scopone-bye',
  standalone: true,
  imports: [MatCardModule, MatButtonModule, AsyncPipe],
  templateUrl: './bye.component.html',
  styleUrls: ['./bye.component.css'],
})
export class ByeComponent implements OnInit, OnDestroy {
  gameClosedName$!: Observable<string>;
  gameCloserPlayer$!: Observable<string>;
  unsubscribe = new Subject<void>();

  constructor(
    public scoponeService: ScoponeService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.gameClosedName$ = this.scoponeService.myCurrentOpenGame_ShareReplay$.pipe(
      tap((game: any) => {
        if (!game) {
          this.router.navigate(['sign-in']);
        }
      }),
      map((game: any) => game?.name ? `"${game.name}"` : 'Unknown')
    );

    this.gameCloserPlayer$ = this.scoponeService.myCurrentOpenGame_ShareReplay$.pipe(
      map((game: any) => {
        const lastHand = game?.hands?.[game.hands.length - 1];
        return lastHand?.closedBy ? `"${lastHand.closedBy}"` : 'Unknown';
      })
    );
  }

  ngOnDestroy() {
    this.unsubscribe.next();
    this.unsubscribe.complete();
  }

  goToGameList() {
    this.router.navigate(['pick-game']);
  }
}
