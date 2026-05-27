package com.satya.assignment.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.satya.assignment.entity.Project;
import com.satya.assignment.entity.Student;
import com.satya.assignment.entity.StudentProject;
import com.satya.assignment.repository.ProjectRepository;
import com.satya.assignment.repository.StudentProjectRepository;
import com.satya.assignment.repository.StudentRepository;
import com.satya.assignment.web.error.ResourceNotFoundException;

@Service
public class StudentService {

    private static int maxProjectPerStudent = 3;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private StudentProjectRepository studentProjectRepository;

    public List<Student> getAllStudents() {
        return studentRepository.findAllWithProjects();
    }

    public Student getStudentById(int id) {
        return studentRepository.findByIdWithProjects(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student", id));
    }

    public Student createStudent(Student studentDetails) {
        return studentRepository.save(studentDetails);
    }

    public Student updateStudent(int id, Student studentDetails) {
        Student student = getStudentById(id);
        student.setName(studentDetails.getName());
        student.setAverage(studentDetails.getAverage());
        return studentRepository.save(student);
    }

    public void deleteStudent(int id) {
        Student student = getStudentById(id);
        studentRepository.delete(student);
    }

    // ==================== Config ====================

    public int getMaxProjectPerStudent() {
        return maxProjectPerStudent;
    }

    public int updateMaxProjectsPerStudent(Integer maximumNumber) {
        if (maximumNumber != null && maximumNumber > 0) {
            maxProjectPerStudent = maximumNumber;
        }
        return maxProjectPerStudent;
    }

    // ==================== Student-Project Management ====================

    public List<Project> getProjectsByStudent(int studentId) {
        Student student = getStudentById(studentId);
        return student.getProjects();
    }

    public Student addProjectToStudent(int studentId, int projectId, LocalDateTime startDate, LocalDateTime endDate) {
        Student student = getStudentById(studentId);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", projectId));

        for (Project p : student.getProjects()) {
            if (p.getId() == project.getId()) {
                return null; // duplicate
            }
        }
        if (student.getProjects().size() >= maxProjectPerStudent) {
            return null; // max reached
        }

        // Add to the ManyToMany projects list
        student.getProjects().add(project);
        Student saved = studentRepository.save(student);

        // Save date details in the separate detail table
        StudentProject detail = new StudentProject(studentId, projectId, startDate, endDate);
        studentProjectRepository.save(detail);

        return saved;
    }

    @Transactional
    public Student removeProjectFromStudent(int studentId, int projectId) {
        Student student = getStudentById(studentId);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", projectId));
        student.getProjects().remove(project);

        // Also remove from detail table
        studentProjectRepository.deleteByStudentIdAndProjectId(studentId, projectId);

        return studentRepository.save(student);
    }

    public List<Project> getAvailableProjects(int studentId) {
        Student student = getStudentById(studentId);
        List<Project> availableProject = new ArrayList<>();
        if (student.getProjects().size() >= maxProjectPerStudent) {
            return availableProject;
        }
        List<Project> allProjects = projectRepository.findAll();
        HashSet<Integer> projectIds = new HashSet<>();
        for (Project p : student.getProjects()) {
            projectIds.add(p.getId());
        }
        for (Project pro : allProjects) {
            if (!projectIds.contains(pro.getId())) {
                availableProject.add(pro);
            }
        }
        return availableProject;
    }

    // ==================== Student-Project with Dates ====================

    public List<StudentProject> getStudentProjectsWithDates(int studentId) {
        return studentProjectRepository.findByStudentId(studentId);
    }

    // ==================== Project Submissions & Grading ====================

    public StudentProject submitProject(int studentId, int projectId, String submissionUrl, String submissionText) {
        StudentProject detail = studentProjectRepository.findByStudentId(studentId).stream()
                .filter(d -> d.getProjectId() == projectId)
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Assignment details not found", projectId));
        
        detail.setSubmissionUrl(submissionUrl);
        detail.setSubmissionText(submissionText);
        detail.setSubmittedAt(LocalDateTime.now());
        detail.setStatus("SUBMITTED");
        return studentProjectRepository.save(detail);
    }

    public StudentProject gradeProject(int studentId, int projectId, Double grade, String feedback) {
        StudentProject detail = studentProjectRepository.findByStudentId(studentId).stream()
                .filter(d -> d.getProjectId() == projectId)
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Assignment details not found", projectId));
        
        detail.setGrade(grade);
        detail.setFeedback(feedback);
        detail.setStatus("GRADED");
        
        StudentProject saved = studentProjectRepository.save(detail);
        updateStudentAverage(studentId);
        return saved;
    }

    private void updateStudentAverage(int studentId) {
        List<StudentProject> projects = studentProjectRepository.findByStudentId(studentId);
        double sum = 0;
        int count = 0;
        for (StudentProject sp : projects) {
            if (sp.getGrade() != null) {
                sum += sp.getGrade();
                count++;
            }
        }
        if (count > 0) {
            Student student = getStudentById(studentId);
            student.setAverage(Math.round((sum / count) * 100.0) / 100.0);
            studentRepository.save(student);
        }
    }
}
