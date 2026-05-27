package com.satya.assignment.web;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.satya.assignment.entity.Project;
import com.satya.assignment.entity.Student;
import com.satya.assignment.entity.StudentProject;
import com.satya.assignment.service.StudentService;
import com.satya.assignment.web.dto.AssignProjectRequest;

@RestController
@RequestMapping("/students")
public class StudentController {

    @Autowired
    private StudentService studentService;

    @GetMapping("/")
    public ResponseEntity<List<Student>> getAllStudent() {
        return ResponseEntity.ok(studentService.getAllStudents());
    }

    @GetMapping("/{id:\\d+}")
    public ResponseEntity<Student> getStudentByID(@PathVariable int id) {
        System.out.println("GET Student ID: " + id);
        return ResponseEntity.ok(studentService.getStudentById(id));
    }

    @PostMapping("/")
    public ResponseEntity<Student> createStudent(@RequestBody Student studentDetails) {
        System.out.println("POST Create Student: " + studentDetails.getName());
        Student savedStudent = studentService.createStudent(studentDetails);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedStudent);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Student> updateStudent(@PathVariable int id, @RequestBody Student studentDetails) {
        System.out.println("PUT Update Student ID: " + id);
        Student updatedStudent = studentService.updateStudent(id, studentDetails);
        System.out.println("Update success for ID: " + id);
        return ResponseEntity.ok(updatedStudent);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteStudent(@PathVariable int id) {
        System.out.println("DELETE Student ID: " + id);
        studentService.deleteStudent(id);
        return ResponseEntity.ok("Student deleted Successfully");
    }

    @GetMapping("/config/max_projects")
    public ResponseEntity<Integer> getMaxProjectPerStudent() {
        return ResponseEntity.ok(studentService.getMaxProjectPerStudent());
    }

    @PutMapping("/config/max_projects")
    public ResponseEntity<Integer> updateMaxProjectsPerStudent(@RequestBody(required = false) Integer maximumNumber) {
        return ResponseEntity.ok(studentService.updateMaxProjectsPerStudent(maximumNumber));
    }

    // ============================ STUDENT PROJECT ===========================

    @GetMapping("/{student_id}/projects")
    public ResponseEntity<List<Project>> getProjectsByStudent(@PathVariable int student_id) {
        return ResponseEntity.ok(studentService.getProjectsByStudent(student_id));
    }

    @PostMapping("/{student_id}/projects/{project_id}")
    public ResponseEntity<Student> addProjectToStudent(
            @PathVariable int student_id,
            @PathVariable int project_id,
            @RequestBody(required = false) AssignProjectRequest request) {

        java.time.LocalDateTime startDate = (request != null) ? request.getStartDate() : null;
        java.time.LocalDateTime endDate = (request != null) ? request.getEndDate() : null;

        Student result = studentService.addProjectToStudent(student_id, project_id, startDate, endDate);
        if (result == null) {
            Student student = studentService.getStudentById(student_id);
            return ResponseEntity.badRequest().body(student);
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @DeleteMapping("/{student_id}/projects/{project_id}")
    public ResponseEntity<Student> deleteProjectFromStudent(@PathVariable int student_id, @PathVariable int project_id) {
        return ResponseEntity.ok(studentService.removeProjectFromStudent(student_id, project_id));
    }

    @GetMapping("/{student_id}/availableprojects")
    public ResponseEntity<List<Project>> getStudentAvailableProject(@PathVariable int student_id) {
        return ResponseEntity.ok(studentService.getAvailableProjects(student_id));
    }

    // ============================ STUDENT PROJECT WITH DATES ===========================

    @GetMapping("/{student_id}/projectdetails")
    public ResponseEntity<List<StudentProject>> getStudentProjectDetails(@PathVariable int student_id) {
        return ResponseEntity.ok(studentService.getStudentProjectsWithDates(student_id));
    }

    // ============================ SUBMISSIONS AND GRADING ===========================

    @PostMapping("/{studentId}/projects/{projectId}/submit")
    public ResponseEntity<StudentProject> submitProject(
            @PathVariable int studentId,
            @PathVariable int projectId,
            @RequestBody java.util.Map<String, String> body) {
        String url = body.get("submissionUrl");
        String text = body.get("submissionText");
        return ResponseEntity.ok(studentService.submitProject(studentId, projectId, url, text));
    }

    @PostMapping("/{studentId}/projects/{projectId}/grade")
    public ResponseEntity<StudentProject> gradeProject(
            @PathVariable int studentId,
            @PathVariable int projectId,
            @RequestBody java.util.Map<String, Object> body) {
        Double grade = Double.valueOf(body.get("grade").toString());
        String feedback = (String) body.get("feedback");
        return ResponseEntity.ok(studentService.gradeProject(studentId, projectId, grade, feedback));
    }
}
