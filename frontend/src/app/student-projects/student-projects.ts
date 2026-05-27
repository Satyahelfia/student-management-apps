import { Component, ChangeDetectorRef } from '@angular/core';
import { Location } from '@angular/common';
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
  student: Student = new Student("", 0, [])
  availableProjects: Project[] = []
  projectId: any
  startDate: string = '';
  endDate: string = '';
  dateError: string = '';

  // Project details with dates
  projectDetails: any[] = [];

  // Books reference list
  books: any[] = [];
  selectedBookId: string = '';

  // Modal state
  showDeleteModal = false;
  showAssignModal = false;
  selectedProject: Project | null = null;
  assignModalMessage = '';

  // Grading Modal state
  showGradeModal = false;
  gradingProjectDetail: any = null;
  gradeValue: number | null = null;
  feedbackText: string = '';
  isSavingGrade = false;
  gradeError = '';

  constructor(
    private studentApi: StudentApi,
    private activatedRoute: ActivatedRoute,
    private cdr: ChangeDetectorRef,
    private location: Location
  ) {}

  ngOnInit(): void {
    const id = Number(this.activatedRoute.snapshot.paramMap.get('id'));
    this.student.id = id;
    this.loadBooks();
    this.getStudentById();
  }

  loadBooks() {
    this.studentApi.getBooks().subscribe({
      next: data => {
        if (data && Array.isArray(data)) {
          this.books = data;
        } else if (data && data.content && Array.isArray(data.content)) {
          this.books = data.content;
        } else if (data && data.data && Array.isArray(data.data)) {
          this.books = data.data;
        } else {
          this.books = [];
        }
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to load books reference list:", err);
      }
    });
  }

  getBookTitle(bookId: string): string {
    if (!bookId) return '';
    const book = this.books.find(b => b.id === bookId);
    return book ? book.title : 'Unknown Reference Book';
  }

  getBookAuthor(bookId: string): string {
    if (!bookId) return '';
    const book = this.books.find(b => b.id === bookId);
    return book ? book.author : '';
  }

  goBack() {
    this.location.back();
  }

  getInitial(name: String): string {
    return name ? name.charAt(0).toUpperCase() : '?';
  }

  getStudentById() {
    this.studentApi.getStudentById(Number(this.student.id)).subscribe({
      next: data => {
        this.student = data;
        this.GetStudentAvailableProjects();
        this.loadProjectDetails();
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to fetch student by ID:", err);
      }
    });
  }

  loadProjectDetails() {
    this.studentApi.getStudentProjectDetails(this.student.id).subscribe({
      next: data => {
        this.projectDetails = data;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to fetch project details:", err);
      }
    });
  }

  getProjectDetail(projectId: any): any {
    return this.projectDetails.find(d => d.project?.id === projectId) || null;
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-GB', {
      day: '2-digit', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
  }

  getProjectStatus(projectId: any): string {
    const detail = this.getProjectDetail(projectId);
    if (detail?.status === 'GRADED') return 'graded';
    if (detail?.status === 'SUBMITTED') return 'submitted';
    if (!detail?.startDate || !detail?.endDate) return 'no-date';
    const now = new Date();
    const start = new Date(detail.startDate);
    const end = new Date(detail.endDate);
    if (now < start) return 'upcoming';
    if (now > end) return 'overdue';
    return 'active';
  }

  openGradeModal(project: any) {
    const detail = this.getProjectDetail(project.id);
    if (!detail) return;
    this.gradingProjectDetail = detail;
    this.gradeValue = detail.grade !== null ? detail.grade : null;
    this.feedbackText = detail.feedback || '';
    this.gradeError = '';
    this.showGradeModal = true;
    this.cdr.detectChanges();
  }

  closeGradeModal() {
    this.showGradeModal = false;
    this.gradingProjectDetail = null;
    this.gradeValue = null;
    this.feedbackText = '';
    this.gradeError = '';
    this.cdr.detectChanges();
  }

  submitGrade() {
    if (!this.gradingProjectDetail) return;
    if (this.gradeValue === null || this.gradeValue < 0 || this.gradeValue > 100) {
      this.gradeError = 'Please enter a valid grade between 0 and 100.';
      this.cdr.detectChanges();
      return;
    }

    this.isSavingGrade = true;
    this.gradeError = '';
    this.cdr.detectChanges();

    this.studentApi.gradeProject(
      this.student.id,
      this.gradingProjectDetail.project.id,
      this.gradeValue,
      this.feedbackText.trim()
    ).subscribe({
      next: () => {
        this.isSavingGrade = false;
        this.closeGradeModal();
        this.refreshPage();
        alert("Grade and feedback saved successfully!");
      },
      error: (err) => {
        console.error("Failed to save grade:", err);
        this.isSavingGrade = false;
        this.gradeError = "Failed to save grade. Please try again.";
        this.cdr.detectChanges();
      }
    });
  }

  GetStudentAvailableProjects() {
    this.studentApi.getAvailableStudentProjects(this.student.id).subscribe({
      next: data => {
        this.availableProjects = data;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to fetch available projects:", err);
      }
    });
  }

  refreshPage() {
    this.getStudentById()
  }

  // Delete confirmation flow
  confirmDelete(project: Project) {
    this.selectedProject = project;
    this.showDeleteModal = true;
    this.cdr.detectChanges();
  }

  onDeleteConfirmed() {
    if (this.selectedProject?.id) {
      this.studentApi.deleteProjectFromStudent(this.student.id, this.selectedProject.id).subscribe({
        next: () => {
          this.showDeleteModal = false;
          this.selectedProject = null;
          this.refreshPage();
          this.cdr.detectChanges();
        },
        error: err => {
          this.showDeleteModal = false;
          console.error("Failed to delete project:", err);
          this.cdr.detectChanges();
        }
      });
    }
  }

  // Assign confirmation flow
  confirmAssign() {
    if (!this.projectId) {
      this.dateError = 'Please select a project first!';
      this.cdr.detectChanges();
      return;
    }

    // Validate dates
    if (this.startDate && this.endDate) {
      if (new Date(this.endDate) <= new Date(this.startDate)) {
        this.dateError = 'End date must be after start date.';
        this.cdr.detectChanges();
        return;
      }
    }

    this.dateError = '';
    const selectedProjectName = this.availableProjects.find(p => p.id == this.projectId)?.name || '';
    let msg = `Are you sure you want to assign "${selectedProjectName}" to ${this.student.name}?`;
    if (this.selectedBookId) {
      const bookTitle = this.getBookTitle(this.selectedBookId);
      msg += `\n\nReference Book: "${bookTitle}"`;
    }
    if (this.startDate && this.endDate) {
      msg += `\n\nStart: ${this.formatDate(this.startDate)}\nDeadline: ${this.formatDate(this.endDate)}`;
    }
    this.assignModalMessage = msg;
    this.showAssignModal = true;
    this.cdr.detectChanges();
  }

  onAssignConfirmed() {
    // Format dates for backend
    const startDateStr = this.startDate ? this.startDate + ':00' : undefined;
    const endDateStr = this.endDate ? this.endDate + ':00' : undefined;
    const bookIdVal = this.selectedBookId ? this.selectedBookId : undefined;

    this.studentApi.addProjectToStudent(this.student.id, this.projectId, startDateStr, endDateStr, bookIdVal).subscribe({
      next: data => {
        this.showAssignModal = false;
        this.projectId = "";
        this.selectedBookId = "";
        this.startDate = '';
        this.endDate = '';
        this.dateError = '';
        this.refreshPage();
        this.cdr.detectChanges();
      },
      error: err => {
        this.showAssignModal = false;
        console.error("Failed to assign project:", err);
        this.cdr.detectChanges();
      }
    });
  }
}