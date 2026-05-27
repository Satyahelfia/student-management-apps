import { Injectable } from '@angular/core';
import { environment } from '../environments/environment.development';
import { HttpClient } from '@angular/common/http';
import { Student } from './student';
import { Observable } from 'rxjs';
import { Project } from './project';


@Injectable({
  providedIn: 'root',
})
export class StudentApi {
  link=environment.BASE_HOST+"/students/"
  constructor(private httpClient:HttpClient) {}

  getAllStudent():Observable<Student[]>{
    return this.httpClient.get<Student[]>(this.link)
  }
  getStudentById(id:Number):Observable<Student>{
    return this.httpClient.get<Student>(this.link+id)
  }
  addStudent(student:Student):Observable<Student>{
    return this.httpClient.post<Student>(this.link,student)
  }
  updateStudent(id:Number,student:Student){
    return this.httpClient.put<Student>(this.link+id,student)
  }
  deleteStudent(id:Number):Observable<String>{
    return this.httpClient.delete(this.link+id,{responseType:"text"})
  }
  getAvailableStudentProjects(student_id:any):Observable<Project[]>{
    return this.httpClient.get<Project[]>(this.link+student_id+"/availableprojects")
  } 
  addProjectToStudent(student_id:any, project_id:any, startDate?:string, endDate?:string, bookId?:string):Observable<Student>{
    const body = { startDate, endDate, bookId };
    return this.httpClient.post<Student>(this.link+student_id+"/projects/"+project_id, body)
  }
  deleteProjectFromStudent(student_id: any, project_id: any):Observable<Student>{
    return this.httpClient.delete<Student>(this.link+student_id+"/projects/"+project_id)
  }
  getBooks(q?: string, page = 0, size = 100): Observable<any> {
    let url = environment.BASE_HOST + "/books?page=" + page + "&size=" + size;
    if (q) {
      url += "&q=" + encodeURIComponent(q);
    }
    return this.httpClient.get<any>(url);
  }
  createBook(formData: FormData): Observable<any> {
    return this.httpClient.post<any>(environment.BASE_HOST + "/books", formData);
  }
  updateBook(id: string, formData: FormData): Observable<any> {
    return this.httpClient.put<any>(environment.BASE_HOST + "/books/" + id, formData);
  }
  deleteBook(id: string): Observable<any> {
    return this.httpClient.delete<any>(environment.BASE_HOST + "/books/" + id);
  }
  getMaxProjectsPerStudent():Observable<Number>{
    return this.httpClient.get<Number>(this.link+"config/max_projects")
  }
  updateMaxProjectsPerStudent(val:number):Observable<Number>{
    return this.httpClient.put<Number>(this.link+"config/max_projects", val)
  }
  getStudentAssignment(): Observable<any> {
      return this.httpClient.get<any>(this.link + "assignment")
  }
  getStudentProjectDetails(student_id:any):Observable<any[]>{
    return this.httpClient.get<any[]>(this.link+student_id+"/projectdetails")
  }
  submitProject(student_id: any, project_id: any, submissionUrl: string, submissionText: string): Observable<any> {
    return this.httpClient.post<any>(this.link + student_id + "/projects/" + project_id + "/submit", { submissionUrl, submissionText });
  }
  gradeProject(student_id: any, project_id: any, grade: number, feedback: string): Observable<any> {
    return this.httpClient.post<any>(this.link + student_id + "/projects/" + project_id + "/grade", { grade, feedback });
  }
}