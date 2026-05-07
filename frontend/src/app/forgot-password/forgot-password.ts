import { Component } from '@angular/core';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.html',
  standalone: false
})
export class ForgotPasswordComponent {
  email = '';
  isSubmitted = false;
  isLoading = false;
  errorMessage = '';

  onSubmit() {
    this.errorMessage = '';

    if (!this.email.trim()) {
      this.errorMessage = 'Please enter your username or email';
      return;
    }

    this.isLoading = true;

    // Simulate sending reset email (since there's no email backend yet)
    setTimeout(() => {
      this.isLoading = false;
      this.isSubmitted = true;
    }, 1500);
  }

  resetForm() {
    this.isSubmitted = false;
    this.email = '';
    this.errorMessage = '';
  }
}
