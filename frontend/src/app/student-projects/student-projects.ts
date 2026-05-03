import { Component, ChangeDetectorRef } from '@angular/core';
import { Student } from '../student';
import { Project } from '../project';
import { StudentApi } from '../student-api';
import { ActivatedRoute } from '@angular/router';
import { OnInit } from '@angular/core';

@Component({
  selector: 'app-student-projects',
  standalone: false,
  templateUrl: './student-projects.html',
  styleUrl: './student-projects.css',
})
export class StudentProjects implements OnInit {
  student:Student=new Student("",0,[])
  availableProjects:Project[]=[]
  projectId:any

  constructor(
    private studentApi:StudentApi,
    private activatedRoute:ActivatedRoute,
    private cdr:ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    const id = Number(this.activatedRoute.snapshot.paramMap.get('id'));
    console.log("ID:", id);
    this.student.id = id;
    this.getStudentById();
  }
  getStudentById(){
    console.log("Fetching student with ID:", this.student.id);
    this.studentApi.getStudentById(Number(this.student.id)).subscribe({
      next: data => {
        console.log("Student data received:", data);
        this.student = data;
        this.GetStudentAvailableProjects();
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to fetch student by ID:", err);
        alert("Failed to load student data! Check console.");
      }
    });
  }
  GetStudentAvailableProjects(){
    this.studentApi.getAvailableStudentProjects(this.student.id).subscribe({
      next: data => {
        console.log("Available projects received:", data);
        this.availableProjects = data;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to fetch available projects:", err);
      }
    });
  }
  refreshPage(){
    this.getStudentById()
  }
  addProject(){
    console.log("Assigning project ID:", this.projectId, "to student ID:", this.student.id);
    if (!this.projectId) {
      alert("Please select a project first!");
      return;
    }
    this.studentApi.addProjectToStudent(this.student.id, this.projectId).subscribe({
      next: data => {
        console.log("Successfully assigned project:", data);
        this.projectId = ""; // reset selection
        this.refreshPage();
      },
      error: err => {
        console.error("Failed to assign project:", err);
        alert("Failed to assign project! Check console for details.");
      }
    });
  }
  deleteProject(project_id:any){
    this.studentApi.deleteProjectFromStudent(this.student.id, project_id).subscribe({
      next: data => {
        this.refreshPage();
      },
      error: err => {
        console.error("Failed to delete project:", err);
      }
    });
  }
}