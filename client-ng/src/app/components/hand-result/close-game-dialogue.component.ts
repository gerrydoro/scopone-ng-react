import { Component } from '@angular/core';
import { MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'scopone-close-game-dialogue',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatButtonModule,
  ],
  template: `
    <mat-card>
      <mat-card-content>
        <p>Do you want to close the game?</p>
        <div style="text-align: center; margin-top: 20px;">
          <button mat-button (click)="onClose(true)">Yes</button>
          <button mat-button (click)="onClose(false)">No</button>
        </div>
      </mat-card-content>
    </mat-card>
  `,
})
export class CloseGameDialogueComponent {
  onClose(result: boolean) {
    // The dialog will close with the result
  }
}
