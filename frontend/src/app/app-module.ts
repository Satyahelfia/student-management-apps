import { NgModule, provideBrowserGlobalErrorListeners } from '@angular/core';
import { BrowserModule, provideClientHydration, withEventReplay } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing-module';
import { App } from './app';
import { FormsModule } from '@angular/forms';
import { provideHttpClient } from '@angular/common/http';
import { Header } from './header/header';
import { ProjectList } from './project-list/project-list';
import { StudentList } from './student-list/student-list';
import { StudentForm } from './student-form/student-form';
import { StudentProjects } from './student-projects/student-projects';
import { Assignment } from './assignment/assignment';

@NgModule({
  declarations: [
    App, 
    Header, 
    ProjectList, 
    StudentList, 
    StudentForm, 
    StudentProjects, 
    Assignment],

  imports: [
    FormsModule, 
    BrowserModule, 
    AppRoutingModule],
    
  providers: [
    provideHttpClient(),
    provideBrowserGlobalErrorListeners(),
    provideClientHydration(withEventReplay()),
  ],
  bootstrap: [App],
})
export class AppModule {}
