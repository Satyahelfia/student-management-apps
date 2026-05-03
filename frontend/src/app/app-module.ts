import { NgModule, provideBrowserGlobalErrorListeners } from '@angular/core';
import { BrowserModule, provideClientHydration, withEventReplay } from '@angular/platform-browser';
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
import { AuthInterceptor } from './auth.interceptor';

@NgModule({
  declarations: [
    App, 
    Header, 
    ProjectList, 
    StudentList, 
    StudentForm, 
    StudentProjects, 
    Assignment,
    LoginComponent
  ],

  imports: [
    FormsModule, 
    BrowserModule, 
    AppRoutingModule
  ],
    
  providers: [
    provideHttpClient(withInterceptorsFromDi()),
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    provideBrowserGlobalErrorListeners(),
    provideClientHydration(withEventReplay()),
  ],
  bootstrap: [App],
})
export class AppModule {}
