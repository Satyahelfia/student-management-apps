import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.html',
  standalone: false
})
export class RegisterComponent {
  username = '';
  password = '';
  confirmPassword = '';
  errorMessage = '';
  showPassword = false;
  showConfirmPassword = false;
  isLoading = false;

  constructor(private authService: AuthService, private router: Router) {}

  togglePassword() {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPassword() {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  onSubmit() {
    this.errorMessage = '';

    if (this.username.trim().length < 3) {
      this.errorMessage = 'Username must be at least 3 characters';
      return;
    }

    if (this.password.length < 4) {
      this.errorMessage = 'Password must be at least 4 characters';
      return;
    }

    if (this.password !== this.confirmPassword) {
      this.errorMessage = 'Passwords do not match';
      return;
    }

    this.isLoading = true;
    this.authService.register(this.username, this.password, this.confirmPassword).subscribe({
      next: () => {
        this.isLoading = false;
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.isLoading = false;
        if (err.status === 409) {
          this.errorMessage = 'Username already exists';
        } else if (err.error?.message) {
          this.errorMessage = err.error.message;
        } else {
          this.errorMessage = 'Registration failed. Please try again.';
        }
      }
    });
  }
}
