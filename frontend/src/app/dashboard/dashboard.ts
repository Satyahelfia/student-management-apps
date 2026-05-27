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

  // Book Library CRUD state
  books: any[] = [];
  searchQuery = '';
  showBookModal = false;
  isEditing = false;
  currentBookId = '';
  bookTitle = '';
  bookAuthor = '';
  bookIsbn = '';
  bookSynopsis = '';
  selectedFile: File | null = null;
  bookError = '';
  isSavingBook = false;
  showDeleteBookModal = false;
  selectedBookToDelete: any = null;

  // Pagination state
  currentPage = 0;
  pageSize = 6; // Display 6 items per page for a compact 3x2 grid
  totalPages = 0;
  totalElements = 0;

  constructor(
    private studentApi: StudentApi,
    private projectApi: ProjectApi,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDashboardData();
    this.loadBooks();
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

  // Book Library operations
  loadBooks() {
    this.studentApi.getBooks(this.searchQuery, this.currentPage, this.pageSize).subscribe({
      next: data => {
        if (data && Array.isArray(data)) {
          this.books = data;
          this.totalPages = 1;
          this.totalElements = data.length;
        } else if (data && data.content && Array.isArray(data.content)) {
          this.books = data.content;
          this.totalPages = data.totalPages || 1;
          this.totalElements = data.totalElements || data.content.length;
        } else if (data && data.data && Array.isArray(data.data)) {
          this.books = data.data;
          if (data.metaData) {
            this.totalPages = data.metaData.totalPages || 1;
            this.totalElements = data.metaData.totalElements || data.data.length;
          } else {
            this.totalPages = 1;
            this.totalElements = data.data.length;
          }
        } else {
          this.books = [];
          this.totalPages = 0;
          this.totalElements = 0;
        }
        this.cdr.detectChanges();
      },
      error: err => {
        console.error("Failed to load books reference list on dashboard:", err);
        this.books = [];
        this.totalPages = 0;
        this.totalElements = 0;
        this.cdr.detectChanges();
      }
    });
  }

  onSearchChange() {
    this.currentPage = 0;
    this.loadBooks();
  }

  getMin(a: number, b: number): number {
    return Math.min(a, b);
  }

  getPagesArray(): number[] {
    const pages = [];
    for (let i = 0; i < this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }

  nextPage() {
    if (this.currentPage < this.totalPages - 1) {
      this.currentPage++;
      this.loadBooks();
    }
  }

  prevPage() {
    if (this.currentPage > 0) {
      this.currentPage--;
      this.loadBooks();
    }
  }

  goToPage(page: number) {
    if (page >= 0 && page < this.totalPages) {
      this.currentPage = page;
      this.loadBooks();
    }
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
    }
  }

  openAddBookModal() {
    this.isEditing = false;
    this.currentBookId = '';
    this.bookTitle = '';
    this.bookAuthor = '';
    this.bookIsbn = '';
    this.bookSynopsis = '';
    this.selectedFile = null;
    this.bookError = '';
    this.showBookModal = true;
    this.cdr.detectChanges();
  }

  openEditBookModal(book: any) {
    this.isEditing = true;
    this.currentBookId = book.id;
    this.bookTitle = book.title;
    this.bookAuthor = book.author;
    this.bookIsbn = book.isbn;
    this.bookSynopsis = book.synopsis || '';
    this.selectedFile = null;
    this.bookError = '';
    this.showBookModal = true;
    this.cdr.detectChanges();
  }

  closeBookModal() {
    this.showBookModal = false;
    this.selectedFile = null;
    this.cdr.detectChanges();
  }

  saveBook() {
    if (!this.bookTitle || !this.bookAuthor || !this.bookIsbn) {
      this.bookError = 'Title, Author, and ISBN are required.';
      this.cdr.detectChanges();
      return;
    }

    const formData = new FormData();
    formData.append('title', this.bookTitle.trim());
    formData.append('author', this.bookAuthor.trim());
    formData.append('isbn', this.bookIsbn.trim());
    if (this.bookSynopsis) {
      formData.append('synopsis', this.bookSynopsis.trim());
    }
    if (this.selectedFile) {
      formData.append('thumbnail', this.selectedFile);
    }

    this.isSavingBook = true;
    this.bookError = '';
    this.cdr.detectChanges();

    const saveObs = this.isEditing
      ? this.studentApi.updateBook(this.currentBookId, formData)
      : this.studentApi.createBook(formData);

    saveObs.subscribe({
      next: () => {
        this.isSavingBook = false;
        this.closeBookModal();
        this.loadBooks();
        alert(this.isEditing ? 'Book updated successfully!' : 'Book created successfully!');
      },
      error: err => {
        console.error('Failed to save book:', err);
        this.isSavingBook = false;
        this.bookError = 'Failed to save book. Please make sure the library microservice is running and values are valid.';
        this.cdr.detectChanges();
      }
    });
  }

  confirmDeleteBook(book: any) {
    this.selectedBookToDelete = book;
    this.showDeleteBookModal = true;
    this.cdr.detectChanges();
  }

  onDeleteBookConfirmed() {
    if (this.selectedBookToDelete) {
      this.studentApi.deleteBook(this.selectedBookToDelete.id).subscribe({
        next: () => {
          this.showDeleteBookModal = false;
          this.selectedBookToDelete = null;
          this.loadBooks();
          alert('Book deleted successfully!');
        },
        error: err => {
          console.error('Failed to delete book:', err);
          this.showDeleteBookModal = false;
          alert('Failed to delete book. Please make sure the library microservice is running.');
          this.cdr.detectChanges();
        }
      });
    }
  }
}

