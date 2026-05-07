import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.html',
  standalone: false
})
export class LoginComponent implements OnInit {
  username = '';
  password = '';
  rememberMe = false;
  errorMessage = '';
  showPassword = false;
  isLoading = false;

  constructor(private authService: AuthService, private router: Router) {}

  ngOnInit() {
    if (this.authService.isRemembered()) {
      this.username = this.authService.getRememberedUsername();
      this.rememberMe = true;
    }
  }

  togglePassword() {
    this.showPassword = !this.showPassword;
  }

  onSubmit() {
    this.errorMessage = '';
    this.isLoading = true;
    this.authService.login(this.username, this.password, this.rememberMe).subscribe({
      next: () => {
        this.isLoading = false;
        this.router.navigate(['/dashboard']);
      },
      error: () => {
        this.isLoading = false;
        this.errorMessage = 'Invalid username or password';
      }
    });
  }
}
