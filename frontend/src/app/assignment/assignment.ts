import { Component, OnInit } from '@angular/core';
import { StudentApi } from '../student-api';

@Component({
  selector: 'app-assignment',
  standalone: false,
  templateUrl: './assignment.html',
  styleUrl: './assignment.css',
})
export class Assignment implements OnInit {
  assignmentResult:Map<String,String>= new Map()

  constructor(
    private studentApi:StudentApi
  ){}
  ngOnInit(): void {
    this.getAssignmentResult()
  }

  getAssignmentResult(){
    this.studentApi.getStudentAssignment().subscribe(
      data=>{
        this.assignmentResult=data
      }
    )
  }

}
