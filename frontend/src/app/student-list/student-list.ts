import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { Student } from '../student';
import { StudentApi } from '../student-api';

@Component({
  selector: 'app-student-list',
  standalone: false,
  templateUrl: './student-list.html',
  styleUrl: './student-list.css',
})
export class StudentList implements OnInit {
  constructor(private studentApi:StudentApi, private cdr:ChangeDetectorRef) {}
  students: Student[] = []
  maxProjectsPerStudent:any
  tempNumber:any
  ngOnInit(): void {
    this.getAllStudents()
    this.getMaxProjectsPerStudent()
  }

  getAllStudents() {
    this.studentApi.getAllStudent().subscribe({
      next: data => {
        console.log("Data Masuk : ",data)
        this.students = data
        this.cdr.detectChanges();
      },
      error: err => console.error("Error : ",err)
    });
  }
  deleteStudent(id:any){
    this.studentApi.deleteStudent(id).subscribe({
      next: data => {
        this.getAllStudents()
      }
    })
  }
  getMaxProjectsPerStudent(){
    this.studentApi.getMaxProjectsPerStudent().subscribe({
      next: data => {
        this.maxProjectsPerStudent = data
        console.log("Data Masuk : ",data)
        this.cdr.detectChanges();
      },
      error: err => console.error("Error : ",err)
    })
  }
  updateMaxProjectsPerStudent(){
    this.studentApi.updateMaxProjectsPerStudent(this.tempNumber).subscribe({
      next: data => {
        this.maxProjectsPerStudent=data
        this.cdr.detectChanges();
      }
    })
  }
}
