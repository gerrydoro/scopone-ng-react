import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { FormsModule } from '@angular/forms';

import { ScoponeService } from '../../scopone/scopone.service';

@Component({
  selector: 'scopone-new-game',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    FormsModule,
  ],
  templateUrl: './new-game.component.html',
  styleUrls: ['./new-game.component.css'],
})
export class NewGameComponent {
  gameName = '';

  constructor(
    public scoponeService: ScoponeService,
    private router: Router
  ) {}

  createNewGame(name: string) {
    this.scoponeService.newGame(name);
    this.router.navigate(['hand']);
  }
}
