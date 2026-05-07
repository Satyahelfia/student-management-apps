import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap, of, BehaviorSubject } from 'rxjs';
import { Router } from '@angular/router';
import { environment } from '../environments/environment.development';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = environment.BASE_HOST + '/auth';
  private tokenKey = 'jwt_token';
  private rememberKey = 'remember_me';
  private usernameKey = 'remembered_username';

  private userRoleSubject = new BehaviorSubject<string | null>(null);
  public userRole$ = this.userRoleSubject.asObservable();

  private studentIdSubject = new BehaviorSubject<number | null>(null);
  public studentId$ = this.studentIdSubject.asObservable();

  private currentUserSubject = new BehaviorSubject<any>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient, private router: Router) {
    if (this.isLoggedIn()) {
      this.loadCurrentUser().subscribe();
    }
  }

  login(username: string, password: string, rememberMe: boolean = false): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/login`, { username, password }).pipe(
      tap(response => {
        if (response && response.token) {
          localStorage.setItem(this.tokenKey, response.token);
          if (rememberMe) {
            localStorage.setItem(this.rememberKey, 'true');
            localStorage.setItem(this.usernameKey, username);
          } else {
            localStorage.removeItem(this.rememberKey);
            localStorage.removeItem(this.usernameKey);
          }
          this.loadCurrentUser().subscribe();
        }
      })
    );
  }

  register(username: string, password: string, confirmPassword: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/register`, { username, password, confirmPassword }).pipe(
      tap(response => {
        if (response && response.token) {
          localStorage.setItem(this.tokenKey, response.token);
          this.loadCurrentUser().subscribe();
        }
      })
    );
  }

  loadCurrentUser(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/me`).pipe(
      tap({
        next: (user) => {
          this.currentUserSubject.next(user);
          this.userRoleSubject.next(user.role);
          this.studentIdSubject.next(user.studentId);
        },
        error: () => {
          this.logout();
        }
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    this.currentUserSubject.next(null);
    this.userRoleSubject.next(null);
    this.studentIdSubject.next(null);
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  isRemembered(): boolean {
    return localStorage.getItem(this.rememberKey) === 'true';
  }

  getRememberedUsername(): string {
    return localStorage.getItem(this.usernameKey) || '';
  }

  getRole(): string | null {
    return this.userRoleSubject.value;
  }

  getStudentId(): number | null {
    return this.studentIdSubject.value;
  }
}
