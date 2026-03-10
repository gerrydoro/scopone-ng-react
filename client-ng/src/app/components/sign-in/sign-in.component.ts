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
  selector: 'scopone-sign-in',
  standalone: true,
  imports: [
    MatDialogModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    FormsModule,
  ],
  templateUrl: './sign-in.component.html',
  styleUrls: ['./sign-in.component.css'],
})
export class SignInComponent {
  playerName = '';

  constructor(
    public scoponeService: ScoponeService,
    private router: Router
  ) {}

  playerEntersOsteria(name: string) {
    this.scoponeService.playerEntersOsteria(name);
    this.router.navigate(['pick-game']);
  }
}
