import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { Observable, Subscription, merge } from 'rxjs';
import { map, tap, catchError, switchMap } from 'rxjs/operators';
import { AsyncPipe } from '@angular/common';

import { ScoponeService } from '../../scopone/scopone.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'scopone-game',
  standalone: true,
  imports: [MatCardModule, AsyncPipe],
  templateUrl: './game.component.html',
  styleUrls: ['./game.component.css'],
})
export class GameComponent implements OnInit, OnDestroy {
  title$ = new Observable<string>((observer) => {
    observer.next('Scopone');
    observer.complete();
  });
  error$!: Observable<string>;
  subscriptions: Subscription[] = [];
  observing = false;

  constructor(
    private router: Router,
    public scoponeServer: ScoponeService
  ) {}

  ngOnInit(): void {
    const subConnect = this.scoponeServer
      .connect(environment.serverAddress)
      .pipe(
        catchError((err: any) => {
          console.error('Connection error to the server failed', err);
          throw new Error('Connection failed');
        }),
        switchMap(() =>
          merge(
            this.scoponeServer.playerEnteredOsteria$.pipe(
              tap(() => this.router.navigate(['pick-game']))
            ),
            this.scoponeServer.playerIsAlreadyInOsteria$.pipe(
              tap(() => this.router.navigate(['pick-game']))
            )
          )
        )
      )
      .subscribe({
        error: (err) => {
          console.error('Connection error', err);
          this.router.navigate(['error']);
        },
      });

    this.subscriptions.push(subConnect);
  }

  ngOnDestroy() {
    this.subscriptions.forEach((sub) => sub.unsubscribe());
  }
}
