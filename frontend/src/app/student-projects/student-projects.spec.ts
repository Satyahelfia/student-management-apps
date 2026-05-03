import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StudentProjects } from './student-projects';

describe('StudentProjects', () => {
  let component: StudentProjects;
  let fixture: ComponentFixture<StudentProjects>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [StudentProjects],
    }).compileComponents();

    fixture = TestBed.createComponent(StudentProjects);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
