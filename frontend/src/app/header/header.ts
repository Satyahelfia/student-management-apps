import { Component } from '@angular/core';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-header',
  standalone: false,
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  constructor(public authService: AuthService) {}

  logout() {
    this.authService.logout();
  }
}
