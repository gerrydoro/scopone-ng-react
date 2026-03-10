import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { CardsComponent } from '../cards/cards.component';
import { Card } from '../../../../../scopone-rx-service/src/model/card';

@Component({
  selector: 'scopone-cards-picker-dialogue',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatButtonModule,
    CardsComponent,
  ],
  template: `
    <div style="text-align: center;">
      <h2>Choose cards to take</h2>
      <scopone-cards [cards]="data.cards"></scopone-cards>
      <button mat-button (click)="onSelect()">Select</button>
    </div>
  `,
})
export class CardsPickerDialogueComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public data: { cards: Card[] }) {}

  onSelect() {
    // The dialog will close with the selected cards
  }
}
