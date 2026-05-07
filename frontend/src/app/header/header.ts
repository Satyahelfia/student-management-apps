import { Component, ChangeDetectorRef, OnInit, OnDestroy } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { AuthService } from '../auth.service';
import { filter } from 'rxjs/operators';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-header',
  standalone: false,
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header implements OnInit, OnDestroy {
  currentPath = '';
  userRole: string | null = null;
  isDarkMode = false;
  private sub: Subscription = new Subscription();

  constructor(
    public authService: AuthService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {
    this.currentPath = this.router.url;
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: any) => {
        this.currentPath = event.urlAfterRedirects || event.url;
        this.cdr.detectChanges();
      });
  }

  ngOnInit() {
    this.isDarkMode = document.body.classList.contains('dark');
    this.sub.add(
      this.authService.userRole$.subscribe(role => {
        this.userRole = role;
        this.cdr.detectChanges();
      })
    );
  }

  toggleTheme() {
    this.isDarkMode = !this.isDarkMode;
    if (this.isDarkMode) {
      document.body.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.body.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
    this.cdr.detectChanges();
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  isActive(path: string): boolean {
    if (path === '/dashboard') {
      return this.currentPath === '/dashboard' || this.currentPath === '/';
    }
    return this.currentPath.startsWith(path);
  }

  logout() {
    this.authService.logout();
  }
}
