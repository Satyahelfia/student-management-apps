import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { Location } from '@angular/common';
import { StudentApi } from '../student-api';

interface StudentAssignmentItem {
  studentName: string;
  projects: string[];
}

@Component({
  selector: 'app-assignment',
  standalone: false,
  templateUrl: './assignment.html',
  styleUrl: './assignment.css',
})
export class Assignment implements OnInit {
  assignmentList: StudentAssignmentItem[] = [];

  // Sorting parameters
  sortBy: string = 'name'; // 'name' | 'projectCount'
  sortDirection: 'asc' | 'desc' = 'asc';

  // Pagination parameters
  currentPage = 1;
  pageSize = 5;

  constructor(
    private studentApi: StudentApi,
    private cdr: ChangeDetectorRef,
    private location: Location
  ) {}

  ngOnInit(): void {
    this.getAssignmentResult()
  }

  goBack() {
    this.location.back();
  }

  getInitial(name: string): string {
    return name ? name.charAt(0).toUpperCase() : '?';
  }


  getAssignmentResult() {
    this.studentApi.getStudentAssignment().subscribe({
      next: data => {
        this.assignmentList = Object.entries(data || {}).map(([studentName, projects]) => ({
          studentName,
          projects: (projects as string[]) || []
        }));
        this.applySort();
        this.currentPage = 1;
        this.cdr.detectChanges();
      }
    });
  }

  setSort(field: string) {
    if (this.sortBy === field) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortBy = field;
      this.sortDirection = 'asc';
    }
    this.applySort();
    this.currentPage = 1;
    this.cdr.detectChanges();
  }

  applySort() {
    this.assignmentList.sort((a, b) => {
      let comparison = 0;
      if (this.sortBy === 'name') {
        comparison = a.studentName.localeCompare(b.studentName);
      } else if (this.sortBy === 'projectCount') {
        comparison = a.projects.length - b.projects.length;
      }
      return this.sortDirection === 'asc' ? comparison : -comparison;
    });
  }

  // Pagination getters
  get totalPages(): number {
    return Math.ceil(this.assignmentList.length / this.pageSize);
  }

  get paginatedAssignment(): StudentAssignmentItem[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.assignmentList.slice(start, start + this.pageSize);
  }

  get pageNumbers(): number[] {
    const pages: number[] = [];
    for (let i = 1; i <= this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }

  get showingFrom(): number {
    if (this.assignmentList.length === 0) return 0;
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get showingTo(): number {
    return Math.min(this.currentPage * this.pageSize, this.assignmentList.length);
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
      this.cdr.detectChanges();
    }
  }
}
