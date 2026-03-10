import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatListModule } from '@angular/material/list';

@Component({
  selector: 'scopone-game-picker-dialogue',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatButtonModule,
    MatListModule,
  ],
  template: `
    <mat-card>
      <mat-card-content>
        <h2>Select a game</h2>
        <mat-list>
          <mat-list-item *ngFor="let game of data.games" (click)="onSelect(game)">
            {{ game.name }}
          </mat-list-item>
        </mat-list>
      </mat-card-content>
    </mat-card>
  `,
})
export class GamePickerDialogueComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public data: { games: any[] }) {}

  onSelect(game: any) {
    // The dialog will close with the selected game
  }
}
