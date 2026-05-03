import { Component } from '@angular/core';
import { Student } from '../student';
import { StudentApi } from '../student-api';
import { OnInit } from '@angular/core';
import { Router,ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-student-form',
  standalone: false,
  templateUrl: './student-form.html',
  styleUrl: './student-form.css',
})
export class StudentForm implements OnInit {
  student:Student=new Student("",0,[],0)
  isOutOfRange=false
  id!:Number
  constructor(
    private studentApi:StudentApi,
    private router:Router,
    private activeRoute:ActivatedRoute,
  ){     }

  ngOnInit(): void {
    this.id=this.activeRoute.snapshot.params["id"]
    if(this.id){
      this.studentApi.getStudentById(this.id).subscribe(
        data=>{
          this.student=data;
        }
      )
    }
  }

  upsert(){
    console.log("Submit Keklik");
    const average=Number(this.student.average)
    if (average < 0 || average > 100) {
      this.isOutOfRange = true
      return
    }
    const observer={
      next:(data:Student)=>{this.router.navigate(["/students"])},
      error:(err:any)=>{console.error(err)},
      complete:()=>{console.log("Operation completed")}
    }
    if (this.id){
      this.studentApi.updateStudent(this.id,this.student).subscribe(observer)
    }
    else{
      this.studentApi.addStudent(this.student).subscribe(observer)
    }
    
    // Call the API to upsert the student
  }
}
