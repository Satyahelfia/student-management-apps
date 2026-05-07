import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { StudentApi } from '../student-api';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-student-submissions',
  templateUrl: './student-submissions.html',
  styleUrls: ['./student-submissions.css'],
  standalone: false
})
export class StudentSubmissionsComponent implements OnInit {
  studentId: number | null = null;
  assignedProjects: any[] = [];
  studentName = '';
  isLoading = true;

  // Form Modal States
  showSubmitModal = false;
  selectedProject: any = null;
  submissionUrl = '';
  submissionText = '';
  isSubmitting = false;

  constructor(
    private studentApi: StudentApi,
    private authService: AuthService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.authService.studentId$.subscribe(id => {
      if (id !== null) {
        this.studentId = id;
        this.loadStudentProfileAndSubmissions();
      }
    });

    this.authService.currentUser$.subscribe(user => {
      if (user) {
        this.studentName = user.username;
      }
    });
  }

  loadStudentProfileAndSubmissions() {
    if (!this.studentId) return;
    this.isLoading = true;

    // Load Student Profile to get the nice real name
    this.studentApi.getStudentById(this.studentId).subscribe({
      next: (student) => {
        this.studentName = student.name.toString();
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error("Failed to load student profile:", err);
      }
    });

    // Load Project details and submissions
    this.studentApi.getStudentProjectDetails(this.studentId).subscribe({
      next: (data) => {
        this.assignedProjects = data;
        this.isLoading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error("Failed to load assigned projects:", err);
        this.isLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  openSubmitModal(projDetail: any) {
    this.selectedProject = projDetail;
    this.submissionUrl = projDetail.submissionUrl || '';
    this.submissionText = projDetail.submissionText || '';
    this.showSubmitModal = true;
    this.cdr.detectChanges();
  }

  closeSubmitModal() {
    this.showSubmitModal = false;
    this.selectedProject = null;
    this.submissionUrl = '';
    this.submissionText = '';
    this.cdr.detectChanges();
  }

  submitDeliverable() {
    if (!this.studentId || !this.selectedProject) return;

    if (!this.submissionUrl || !this.submissionUrl.trim()) {
      alert("Please provide a submission URL (e.g., GitHub repository link).");
      return;
    }

    this.isSubmitting = true;
    this.cdr.detectChanges();

    this.studentApi.submitProject(
      this.studentId,
      this.selectedProject.project.id,
      this.submissionUrl.trim(),
      this.submissionText.trim()
    ).subscribe({
      next: () => {
        this.isSubmitting = false;
        this.closeSubmitModal();
        this.loadStudentProfileAndSubmissions(); // reload
        alert("Your project deliverable has been submitted successfully!");
      },
      error: (err) => {
        console.error("Failed to submit project:", err);
        this.isSubmitting = false;
        this.cdr.detectChanges();
        alert("There was an error submitting your deliverable. Please try again.");
      }
    });
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-GB', {
      day: '2-digit', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
  }

  getProjectStatus(projDetail: any): string {
    if (projDetail.status === 'GRADED') return 'graded';
    if (projDetail.status === 'SUBMITTED') return 'submitted';

    if (!projDetail.startDate || !projDetail.endDate) return 'no-date';
    const now = new Date();
    const start = new Date(projDetail.startDate);
    const end = new Date(projDetail.endDate);
    if (now < start) return 'upcoming';
    if (now > end) return 'overdue';
    return 'active';
  }

  getTimeRemaining(projDetail: any): string {
    if (projDetail.status === 'GRADED') return 'Finished & Graded';
    if (projDetail.status === 'SUBMITTED') return 'Pending grading';
    if (!projDetail.endDate) return 'No Deadline Set';

    const now = new Date().getTime();
    const end = new Date(projDetail.endDate).getTime();
    const diff = end - now;

    if (diff < 0) {
      return 'Overdue';
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    
    if (days > 0) {
      return `${days}d ${hours}h remaining`;
    }
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    return `${hours}h ${minutes}m remaining`;
  }
}
