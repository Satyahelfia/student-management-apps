import { Component } from '@angular/core';
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
    private activatedRoute:ActivatedRoute
  ) {}

  ngOnInit(): void {
    const id = Number(this.activatedRoute.snapshot.paramMap.get('id'));
    console.log("ID:", id);
    this.student.id = id;
    this.getStudentById();
  }
  getStudentById(){
    this.studentApi.getStudentById(Number(this.student.id)).subscribe(
      data=>{
        this.student=data

        this.GetStudentAvailableProjects();
      }
    )
  }
  GetStudentAvailableProjects(){
    this.studentApi.getAvailableStudentProjects(this.student.id).subscribe(
      data=>{
        this.availableProjects=data
      }
    )
  }
  refreshPage(){
    this.getStudentById()
  }
  addProject(){
    this.studentApi.addProjectToStudent(this.student.id, this.projectId).subscribe(
      data=> {
        this.refreshPage()
      }
    )
  }
  deleteProject(project_id:any){
    this.studentApi.deleteProjectFromStudent(this.student.id, project_id).subscribe(
      data=> {
        this.refreshPage()
      }
    )
  }
}