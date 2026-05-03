import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Project } from './project';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment.development';
import { Student } from './student';

@Injectable({
  providedIn: 'root',
})
export class ProjectApi {
  link=environment.BASE_HOST+"/projects/"
  constructor(private httpClient:HttpClient) {}

  getAllProject():Observable<Project[]>{
    return this.httpClient.get<Project[]>(this.link);
  }
  getProjectById(id:Number):Observable<Project>{
    return this.httpClient.get<Project>(this.link+id);
  }
  addProject(Project:Project):Observable<Project>{
    return this.httpClient.post<Project>(this.link,Project);
  }
  updateProject(id:Number,Project:Project){
    return this.httpClient.put<Project>(this.link+id,Project);
  }
  deleteProject(id:Number):Observable<String>{
    return this.httpClient.delete(this.link+id,{responseType:"text"});
  }
  getAvailableStudentProjects(student_id:any):Observable<Project[]>{
    return this.httpClient.get<Project[]>(this.link+"available/"+student_id+"/availableprojects")
  }
  addProjectToStudent(student_id:any,project_id:any):Observable<Student>{
    return this.httpClient.post<Student>(this.link+"available/"+student_id+"/addproject/"+project_id,"");
  }
  deleteProjectFromStudent(student_id:any,project_id:any):Observable<Student>{
    return this.httpClient.delete<Student>(this.link+"available/"+student_id+"/deleteproject/"+project_id);
  }
  getMaxProjectsPerStudent():Observable<Number>{
    return this.httpClient.get<Number>(this.link+"available/maxprojectsperstudent");
  }
  updateMaxProjectsPerStudent(max:Number):Observable<Number>{
    return this.httpClient.put<Number>(this.link+"available/maxprojectsperstudent",max);
  }

}
