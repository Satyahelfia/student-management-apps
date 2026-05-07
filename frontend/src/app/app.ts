import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { environment } from '../environments/environment';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  standalone: false,
  styleUrl: './app.css'
})
export class App implements OnInit {
  title = 'frontprojectassignment';
  isAuthPage = false;

  is_prod=environment.PRODUCTION;

  constructor(private router: Router) {}

  ngOnInit(): void{
    // Initialize theme from localStorage
    const savedTheme = localStorage.getItem('theme') || 'light';
    if (savedTheme === 'dark') {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }

    if (this.is_prod){
      console.log("my environment is PROD")
    }
    else{
      console.log("my environment is DEV")
    }

    // Track auth pages to hide header/main wrapper
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe((event: any) => {
      const authRoutes = ['/login', '/register', '/forgot-password'];
      this.isAuthPage = authRoutes.includes(event.urlAfterRedirects || event.url);
    });
  }
}
