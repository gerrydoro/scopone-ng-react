import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { CardsComponent } from '../cards/cards.component';
import { Card } from '../../../../../scopone-rx-service/src/model/card';

@Component({
  selector: 'scopone-cards-taken-dialogue',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatButtonModule,
    CardsComponent,
  ],
  template: `
    <mat-card>
      <mat-card-content>
        <scopone-cards [cards]="data.cardPlayed" [name]="data.cardPlayedByPlayer"></scopone-cards>
        <scopone-cards [cards]="data.cardsTaken" [name]="'Cards Taken'"></scopone-cards>
        <scopone-cards [cards]="data.finalTableTake?.Cards" [name]="data.finalTableTake?.TeamTakingTable ? 'Final Take' : ''"></scopone-cards>
      </mat-card-content>
    </mat-card>
  `,
})
export class CardsTakenDialogueComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public data: {
    cardPlayed: Card[];
    cardsTaken: Card[];
    cardPlayedByPlayer: string;
    finalTableTake: { Cards: Card[]; TeamTakingTable: [any, any] };
  }) {}
}
