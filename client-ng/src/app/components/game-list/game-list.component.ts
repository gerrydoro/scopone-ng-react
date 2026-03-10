import { Component, EventEmitter, Output } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatListModule } from '@angular/material/list';
import { NgFor } from '@angular/common';

@Component({
  selector: 'scopone-game-list',
  standalone: true,
  imports: [MatCardModule, MatListModule, NgFor],
  templateUrl: './game-list.component.html',
  styleUrls: ['./game-list.component.css'],
})
export class GameListComponent {
  @Output() gameSelected = new EventEmitter<any>();
}
