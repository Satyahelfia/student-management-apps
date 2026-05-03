import { Component, ChangeDetectorRef } from '@angular/core';
import { Project } from '../project';
import { ProjectApi } from '../project-api';
import { OnInit } from '@angular/core';

@Component({
  selector: 'app-project-list',
  standalone: false,
  templateUrl: './project-list.html',
  styleUrl: './project-list.css',
})
export class ProjectList implements OnInit {
  projects:Project[]=[]
  project:Project=new Project("")

  constructor(
    private projectApi:ProjectApi,
    private cdr:ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.getAllProjects();
  }

  getAllProjects(){
    return this.projectApi.getAllProject().subscribe({
      next: (data) => {
        this.projects=data
        this.cdr.detectChanges();
      }
    });
  }
  addProject(){
    return this.projectApi.addProject(this.project).subscribe({
      next: (data) => {
        this.getAllProjects()
        this.project.name=""
      }
    });
  }
  deleteProject(id:any){
    return this.projectApi.deleteProject(id).subscribe({
      next: (data) => {
        this.getAllProjects()
      }
    });
  }
}
