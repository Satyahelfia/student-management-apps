import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { Location } from '@angular/common';
import { Student } from '../student';
import { StudentApi } from '../student-api';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-student-list',
  standalone: false,
  templateUrl: './student-list.html',
  styleUrl: './student-list.css',
})
export class StudentList implements OnInit {
  students: Student[] = []
  maxProjectsPerStudent: any
  tempNumber: any

  sortBy: 'id' | 'name' | 'average' | '' = '';
  sortDirection: 'asc' | 'desc' = 'asc';

  // Search & pagination
  searchQuery = '';
  currentPage = 1;
  pageSize = 5;

  // Modal state
  showDeleteModal = false;
  showSaveModal = false;
  selectedStudent: Student | null = null;

  constructor(
    private studentApi: StudentApi,
    private cdr: ChangeDetectorRef,
    private location: Location
  ) {}

  ngOnInit(): void {
    this.loadInitialData();
  }

  loadInitialData() {
    forkJoin({
      students: this.studentApi.getAllStudent(),
      maxProjects: this.studentApi.getMaxProjectsPerStudent()
    }).subscribe({
      next: ({ students, maxProjects }) => {
        this.students = students;
        this.maxProjectsPerStudent = maxProjects;
        this.currentPage = 1;
        this.cdr.detectChanges();
      },
      error: err => console.error("Error loading student initial data:", err)
    });
  }

  goBack() {
    this.location.back();
  }

  getInitial(name: String): string {
    return name ? name.charAt(0).toUpperCase() : '?';
  }

  // Toggle sort order
  toggleSort(column: 'id' | 'name' | 'average') {
    if (this.sortBy === column) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortBy = column;
      // Default to desc for average (highest score first) and asc for name/id
      this.sortDirection = column === 'average' ? 'desc' : 'asc';
    }
    this.currentPage = 1;
    this.cdr.detectChanges();
  }

  // Search, filter & sort
  get filteredStudents(): Student[] {
    let result = [...this.students];

    // 1. Filter by search query
    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      result = result.filter(s =>
        s.name.toLowerCase().includes(q) ||
        String(s.id).includes(q) ||
        String(s.average).includes(q)
      );
    }

    // 2. Sort
    if (this.sortBy) {
      result.sort((a, b) => {
        let valA: any;
        let valB: any;

        if (this.sortBy === 'name') {
          valA = a.name ? a.name.toLowerCase().trim() : '';
          valB = b.name ? b.name.toLowerCase().trim() : '';
        } else if (this.sortBy === 'average') {
          valA = a.average !== undefined && a.average !== null ? Number(a.average) : 0;
          valB = b.average !== undefined && b.average !== null ? Number(b.average) : 0;
        } else if (this.sortBy === 'id') {
          valA = a.id !== undefined && a.id !== null ? Number(a.id) : 0;
          valB = b.id !== undefined && b.id !== null ? Number(b.id) : 0;
        }

        if (valA < valB) return this.sortDirection === 'asc' ? -1 : 1;
        if (valA > valB) return this.sortDirection === 'asc' ? 1 : -1;
        return 0;
      });
    }

    return result;
  }

  get totalPages(): number {
    return Math.ceil(this.filteredStudents.length / this.pageSize);
  }

  get paginatedStudents(): Student[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredStudents.slice(start, start + this.pageSize);
  }

  get pageNumbers(): number[] {
    const pages: number[] = [];
    for (let i = 1; i <= this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }

  get showingFrom(): number {
    if (this.filteredStudents.length === 0) return 0;
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get showingTo(): number {
    return Math.min(this.currentPage * this.pageSize, this.filteredStudents.length);
  }

  onSearchChange() {
    this.currentPage = 1;
    this.cdr.detectChanges();
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
      this.cdr.detectChanges();
    }
  }

  getAllStudents() {
    this.studentApi.getAllStudent().subscribe({
      next: data => {
        this.students = data;
        this.currentPage = 1;
        this.cdr.detectChanges();
      },
      error: err => console.error("Error : ", err)
    });
  }

  // Delete confirmation flow
  confirmDelete(student: Student) {
    this.selectedStudent = student;
    this.showDeleteModal = true;
    this.cdr.detectChanges();
  }

  onDeleteConfirmed() {
    if (this.selectedStudent?.id) {
      this.studentApi.deleteStudent(this.selectedStudent.id).subscribe({
        next: () => {
          this.showDeleteModal = false;
          this.selectedStudent = null;
          this.getAllStudents();
          this.cdr.detectChanges();
        }
      });
    }
  }

  // Save settings confirmation flow
  confirmSaveSettings() {
    this.showSaveModal = true;
    this.cdr.detectChanges();
  }

  onSaveConfirmed() {
    this.studentApi.updateMaxProjectsPerStudent(this.tempNumber).subscribe({
      next: data => {
        this.maxProjectsPerStudent = data;
        this.showSaveModal = false;
        this.cdr.detectChanges();
      }
    });
  }

  getMaxProjectsPerStudent() {
    this.studentApi.getMaxProjectsPerStudent().subscribe({
      next: data => {
        this.maxProjectsPerStudent = data;
        this.cdr.detectChanges();
      },
      error: err => console.error("Error : ", err)
    })
  }
}
