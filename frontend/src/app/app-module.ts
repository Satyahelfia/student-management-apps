import { NgModule, provideZonelessChangeDetection } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing-module';
import { App } from './app';
import { FormsModule } from '@angular/forms';
import { HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { Header } from './header/header';
import { ProjectList } from './project-list/project-list';
import { StudentList } from './student-list/student-list';
import { StudentForm } from './student-form/student-form';
import { StudentProjects } from './student-projects/student-projects';
import { Assignment } from './assignment/assignment';
import { LoginComponent } from './login/login';
import { RegisterComponent } from './register/register';
import { ForgotPasswordComponent } from './forgot-password/forgot-password';
import { DashboardComponent } from './dashboard/dashboard';
import { AuthInterceptor } from './auth.interceptor';
import { ConfirmModalComponent } from './confirm-modal/confirm-modal';
import { StudentSubmissionsComponent } from './student-submissions/student-submissions';

@NgModule({
  declarations: [
    App, 
    Header, 
    ProjectList, 
    StudentList, 
    StudentForm, 
    StudentProjects, 
    Assignment,
    LoginComponent,
    RegisterComponent,
    ForgotPasswordComponent,
    DashboardComponent,
    ConfirmModalComponent,
    StudentSubmissionsComponent
  ],

  imports: [
    FormsModule, 
    BrowserModule, 
    AppRoutingModule
  ],
    
  providers: [
    provideHttpClient(withInterceptorsFromDi()),
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    provideZonelessChangeDetection(),
  ],
  bootstrap: [App],
})
export class AppModule {}
