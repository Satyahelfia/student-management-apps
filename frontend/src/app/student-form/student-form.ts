import { Component, ChangeDetectorRef } from '@angular/core';
import { Location } from '@angular/common';
import { Student } from '../student';
import { StudentApi } from '../student-api';
import { OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-student-form',
  standalone: false,
  templateUrl: './student-form.html',
  styleUrl: './student-form.css',
})
export class StudentForm implements OnInit {
  student: Student = new Student("", 0, [], 0)
  isOutOfRange = false
  id!: Number

  // Modal state
  showSaveModal = false;

  constructor(
    private studentApi: StudentApi,
    private router: Router,
    private activeRoute: ActivatedRoute,
    private cdr: ChangeDetectorRef,
    private location: Location
  ) {}

  ngOnInit(): void {
    this.id = this.activeRoute.snapshot.params["id"]
    if (this.id) {
      this.studentApi.getStudentById(this.id).subscribe({
        next: data => {
          this.student = data;
          this.cdr.detectChanges();
        }
      })
    }
  }

  goBack() {
    this.location.back();
  }

  confirmSave() {
    const average = Number(this.student.average)
    if (average < 0 || average > 100) {
      this.isOutOfRange = true
      return
    }
    this.isOutOfRange = false;
    this.showSaveModal = true;
    this.cdr.detectChanges();
  }

  onSaveConfirmed() {
    const observer = {
      next: (data: Student) => {
        this.showSaveModal = false;
        this.router.navigate(["/students"]);
      },
      error: (err: any) => {
        this.showSaveModal = false;
        console.error(err);
        this.cdr.detectChanges();
      },
      complete: () => { console.log("Operation completed") }
    }
    if (this.id) {
      this.studentApi.updateStudent(this.id, this.student).subscribe(observer)
    } else {
      this.studentApi.addStudent(this.student).subscribe(observer)
    }
  }
}
