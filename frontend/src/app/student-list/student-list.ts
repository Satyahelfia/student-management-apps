import { Component, OnInit } from '@angular/core';
import { Student } from '../student';
import { StudentApi } from '../student-api';

@Component({
  selector: 'app-student-list',
  standalone: false,
  templateUrl: './student-list.html',
  styleUrl: './student-list.css',
})
export class StudentList implements OnInit {
  constructor(private studentApi:StudentApi) {}
  students: Student[] = []
  maxProjectsPerStudent:any
  tempNumber:any
  ngOnInit(): void {
    this.getAllStudents()
    this.getMaxProjectsPerStudent()
  }

  getAllStudents() {
    this.studentApi.getAllStudent().subscribe(
      data=> {
        console.log("Data Masuk : ",data)
        this.students = data
      },
      error=> console.error("Error : ",error)
    );
  }
  deleteStudent(id:any){
    this.studentApi.deleteStudent(id).subscribe(
      data=>{
        this.getAllStudents()
      }
    )
  }
  getMaxProjectsPerStudent(){
    this.studentApi.getMaxProjectsPerStudent().subscribe(
      data=>{
        this.maxProjectsPerStudent = data
        console.log("Data Masuk : ",data)
      },
      error=> console.error("Error : ",error)
    )
  }
    updateMaxProjectsPerStudent(){
    this.studentApi.updateMaxProjectsPerStudent(this.tempNumber).subscribe(
      data=>{
        this.maxProjectsPerStudent=data
      }
    )
  }
}
