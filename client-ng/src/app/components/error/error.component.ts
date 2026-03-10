import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'scopone-error',
  standalone: true,
  imports: [MatCardModule, MatButtonModule],
  templateUrl: './error.component.html',
  styleUrls: ['./error.component.css'],
})
export class ErrorComponent {
  error: any = { message: 'An unknown error occurred' };

  constructor(private router: Router) {}

  retry() {
    this.router.navigate(['sign-in']);
  }
}
