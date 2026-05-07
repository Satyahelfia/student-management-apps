import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { StudentList } from './student-list/student-list';
import { StudentForm } from './student-form/student-form';
import { ProjectList } from './project-list/project-list';
import { Assignment } from './assignment/assignment';
import { StudentProjects } from './student-projects/student-projects';
import { LoginComponent } from './login/login';
import { RegisterComponent } from './register/register';
import { ForgotPasswordComponent } from './forgot-password/forgot-password';
import { DashboardComponent } from './dashboard/dashboard';
import { AuthGuard } from './auth.guard';
import { StudentSubmissionsComponent } from './student-submissions/student-submissions';

const routes: Routes = [
  {path: "login", component: LoginComponent},
  {path: "register", component: RegisterComponent},
  {path: "forgot-password", component: ForgotPasswordComponent},
  {path: "dashboard", component: DashboardComponent, canActivate: [AuthGuard]},
  {path: "students", component: StudentList, canActivate: [AuthGuard]},
  {path: "students/addstudent", component: StudentForm, canActivate: [AuthGuard]},
  {path: "students/updatestudent/:id", component: StudentForm, canActivate: [AuthGuard]},
  {path: "students/:id/projects", component: StudentProjects, canActivate: [AuthGuard]},
  {path: "projects", component: ProjectList, canActivate: [AuthGuard]},
  {path: "assignment", component: Assignment, canActivate: [AuthGuard]},
  {path: "my-submissions", component: StudentSubmissionsComponent, canActivate: [AuthGuard]},
  {path: "", redirectTo: "dashboard", pathMatch: "full"}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
