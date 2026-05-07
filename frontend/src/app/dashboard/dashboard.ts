import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { StudentApi } from '../student-api';
import { ProjectApi } from '../project-api';
import { Student } from '../student';
import { Project } from '../project';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.html',
  standalone: false
})
export class DashboardComponent implements OnInit {
  totalStudents = 0;
  totalProjects = 0;
  averageScore = 0;
  maxProjects = 0;
  topStudents: Student[] = [];
  recentProjects: Project[] = [];
  isLoading = true;

  constructor(
    private studentApi: StudentApi,
    private projectApi: ProjectApi,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDashboardData();
  }

  loadDashboardData() {
    this.isLoading = true;

    forkJoin({
      students: this.studentApi.getAllStudent(),
      projects: this.projectApi.getAllProject(),
      maxProjects: this.studentApi.getMaxProjectsPerStudent()
    }).subscribe({
      next: ({ students, projects, maxProjects }) => {
        // Calculate students stats
        this.totalStudents = students.length;
        if (students.length > 0) {
          const sum = students.reduce((acc, s) => acc + Number(s.average), 0);
          this.averageScore = Math.round((sum / students.length) * 100) / 100;
        } else {
          this.averageScore = 0;
        }

        this.topStudents = [...students]
          .sort((a, b) => Number(b.average) - Number(a.average))
          .slice(0, 5);

        // Calculate projects stats
        this.totalProjects = projects.length;
        this.recentProjects = projects.slice(-5).reverse();

        // Calculate max projects setting
        this.maxProjects = Number(maxProjects);

        this.isLoading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error("Error loading dashboard data:", err);
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });
  }
}

