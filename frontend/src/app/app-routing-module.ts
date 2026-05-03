import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { StudentList } from './student-list/student-list';
import { StudentForm } from './student-form/student-form';
import { ProjectList } from './project-list/project-list';
import { Assignment } from './assignment/assignment';
import { StudentProjects } from './student-projects/student-projects';
import { LoginComponent } from './login/login';
import { AuthGuard } from './auth.guard';

const routes: Routes = [
  {path: "login", component: LoginComponent},
  {path: "students", component: StudentList, canActivate: [AuthGuard]},
  {path: "students/addstudent", component: StudentForm, canActivate: [AuthGuard]},
  {path: "students/updatestudent/:id", component: StudentForm, canActivate: [AuthGuard]},
  {path: "students/:id/projects", component: StudentProjects, canActivate: [AuthGuard]},
  {path: "projects", component: ProjectList, canActivate: [AuthGuard]},
  {path: "assignment", component: Assignment, canActivate: [AuthGuard]},
  {path: "", redirectTo: "students", pathMatch: "full"}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
