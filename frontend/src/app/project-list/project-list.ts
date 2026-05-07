import { Component, ChangeDetectorRef } from '@angular/core';
import { Location } from '@angular/common';
import { Project } from '../project';
import { ProjectApi } from '../project-api';
import { OnInit } from '@angular/core';

@Component({
  selector: 'app-project-list',
  standalone: false,
  templateUrl: './project-list.html',
  styleUrl: './project-list.css',
})
export class ProjectList implements OnInit {
  projects: Project[] = []
  project: Project = new Project("")

  // File attachments state
  selectedPdfFile: File | null = null;
  selectedImageFile: File | null = null;
  imagePreviewUrl: string | null = null;


  // Search & pagination
  searchQuery = '';
  currentPage = 1;
  pageSize = 5;

  // Modal state
  showDeleteModal = false;
  showCreateModal = false;
  selectedProject: Project | null = null;


  constructor(
    private projectApi: ProjectApi,
    private cdr: ChangeDetectorRef,
    private location: Location
  ) {}

  ngOnInit(): void {
    this.getAllProjects();
  }

  goBack() {
    this.location.back();
  }

  // Search & filter
  get filteredProjects(): Project[] {
    if (!this.searchQuery.trim()) return this.projects;
    const q = this.searchQuery.toLowerCase().trim();
    return this.projects.filter(p =>
      p.name.toLowerCase().includes(q) ||
      String(p.id).includes(q)
    );
  }

  get totalPages(): number {
    return Math.ceil(this.filteredProjects.length / this.pageSize);
  }

  get paginatedProjects(): Project[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredProjects.slice(start, start + this.pageSize);
  }

  get pageNumbers(): number[] {
    const pages: number[] = [];
    for (let i = 1; i <= this.totalPages; i++) {
      pages.push(i);
    }
    return pages;
  }

  get showingFrom(): number {
    if (this.filteredProjects.length === 0) return 0;
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get showingTo(): number {
    return Math.min(this.currentPage * this.pageSize, this.filteredProjects.length);
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

  getAllProjects() {
    return this.projectApi.getAllProject().subscribe({
      next: (data) => {
        this.projects = data;
        this.currentPage = 1;
        this.cdr.detectChanges();
      }
    });
  }

  // Delete confirmation flow
  confirmDelete(project: Project) {
    this.selectedProject = project;
    this.showDeleteModal = true;
    this.cdr.detectChanges();
  }

  onDeleteConfirmed() {
    if (this.selectedProject?.id) {
      this.projectApi.deleteProject(this.selectedProject.id).subscribe({
        next: () => {
          this.showDeleteModal = false;
          this.selectedProject = null;
          this.getAllProjects();
          this.cdr.detectChanges();
        }
      });
    }
  }

  onPdfSelected(event: any) {
    const file = event.target.files?.[0];
    if (file) {
      this.selectedPdfFile = file;
    }
  }

  onImageSelected(event: any) {
    const file = event.target.files?.[0];
    if (file) {
      this.selectedImageFile = file;
      
      // Local image preview using FileReader
      const reader = new FileReader();
      reader.onload = () => {
        this.imagePreviewUrl = reader.result as string;
        this.cdr.detectChanges();
      };
      reader.readAsDataURL(file);
    }
  }

  viewPdf(id: number, event: Event) {
    event.preventDefault();
    this.projectApi.getPdfBlob(id).subscribe({
      next: (blob) => {
        const fileURL = URL.createObjectURL(blob);
        window.open(fileURL, '_blank');
      },
      error: (err) => console.error('Error opening PDF:', err)
    });
  }

  viewImage(id: number, event: Event) {
    event.preventDefault();
    this.projectApi.getImageBlob(id).subscribe({
      next: (blob) => {
        const fileURL = URL.createObjectURL(blob);
        window.open(fileURL, '_blank');
      },
      error: (err) => console.error('Error opening image:', err)
    });
  }

  // Create confirmation flow
  confirmAdd() {
    if (!this.project.name || !this.project.name.trim()) return;
    this.showCreateModal = true;
    this.cdr.detectChanges();
  }

  onCreateConfirmed() {
    this.projectApi.addProject(this.project.name, this.selectedPdfFile, this.selectedImageFile).subscribe({
      next: () => {
        this.showCreateModal = false;
        this.project.name = "";
        this.selectedPdfFile = null;
        this.selectedImageFile = null;
        this.imagePreviewUrl = null;
        
        // Reset file inputs on HTML
        const pdfInput = document.getElementById('pdf') as HTMLInputElement;
        if (pdfInput) pdfInput.value = '';
        const imageInput = document.getElementById('image') as HTMLInputElement;
        if (imageInput) imageInput.value = '';

        this.getAllProjects();
        this.cdr.detectChanges();
      }
    });
  }
}


