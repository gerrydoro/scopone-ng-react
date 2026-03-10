import { Injectable, Inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

import { ScoponeServerService } from '../../../../scopone-rx-service/src/scopone-server.service';

@Injectable({
  providedIn: 'root',
})
export class ScoponeService extends ScoponeServerService {
  dialog!: MatDialog;

  constructor(@Inject(MatDialog) dialog: MatDialog) {
    super();
    this.dialog = dialog;
  }
}
