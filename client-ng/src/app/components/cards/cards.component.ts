import { Component, Input, Output, EventEmitter } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { Card } from '../../../../../scopone-rx-service/src/model/card';

@Component({
  selector: 'scopone-cards',
  standalone: true,
  imports: [MatCardModule, MatButtonModule],
  templateUrl: './cards.component.html',
  styleUrls: ['./cards.component.css'],
})
export class CardsComponent {
  @Input() cards: Card[] = [];
  @Input() name = '';
  @Input() enabled = true;
  @Output() cardClicked = new EventEmitter<Card>();

  onCardClick(card: Card) {
    if (this.enabled) {
      this.cardClicked.emit(card);
    }
  }
}
