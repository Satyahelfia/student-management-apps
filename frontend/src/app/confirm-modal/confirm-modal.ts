import { Component, Input, Output, EventEmitter } from '@angular/core';

export type ModalType = 'delete' | 'save' | 'create' | 'info';

@Component({
  selector: 'app-confirm-modal',
  templateUrl: './confirm-modal.html',
  standalone: false
})
export class ConfirmModalComponent {
  @Input() show = false;
  @Input() title = 'Confirm Action';
  @Input() message = 'Are you sure you want to proceed?';
  @Input() confirmText = 'Confirm';
  @Input() cancelText = 'Cancel';
  @Input() type: ModalType = 'info';
  @Input() isLoading = false;

  @Output() confirmed = new EventEmitter<void>();
  @Output() cancelled = new EventEmitter<void>();

  onConfirm() {
    this.confirmed.emit();
  }

  onCancel() {
    this.cancelled.emit();
  }

  onOverlayClick(event: MouseEvent) {
    if ((event.target as HTMLElement).classList.contains('modal-overlay')) {
      this.onCancel();
    }
  }
}
