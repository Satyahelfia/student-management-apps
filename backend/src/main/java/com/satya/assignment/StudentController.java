package com.satya.assignment;

import com.satya.assignment.model.Project;
import com.satya.assignment.model.Student;
import com.satya.assignment.repository.ProjectRepository;
import com.satya.assignment.repository.StudentRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.expression.ExpressionException;
import org.springframework.http.HttpStatus;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "${SPRING_ORIGINS:*}")
@RequestMapping("/students")
public class StudentController{
    private static int maxProjectPerStudent=3;
    @Autowired
    private ProjectRepository projectRepository;
    @Autowired
    private StudentRepository studentRepository;

    @GetMapping("/")
    public ResponseEntity<List<Student>> getAllStudent(){
        return ResponseEntity.ok(studentRepository.findAll());
     }
     public Student retieveStudentById(int id){
        return studentRepository.findById(id).orElseThrow(
                ()-> new ExpressionException("Student with id "+id+" is not Found !")
        );
     }
    public Project retieveProjectById(int id){
        return projectRepository.findById(id).orElseThrow(
                ()-> new ExpressionException("Project with id "+id+" is not Found !")
        );
    }

     @GetMapping ("/{id:\\d+}")
     public ResponseEntity<Student> getStudentByID(@PathVariable int id){
         return ResponseEntity.of(studentRepository.findById(id));
     }

     @PostMapping("/")
     public ResponseEntity<Student> createStudent(@RequestBody Student studentDetails){
         Student savedStudent= studentRepository.save(studentDetails);
         return ResponseEntity.status(HttpStatus.CREATED).body(savedStudent);
     }

     @PutMapping("/{id}")
     public ResponseEntity<Student> updateStudent( @PathVariable int id , @RequestBody Student studentDetails){
        Student student= retieveStudentById(id);
        student.setName(studentDetails.getName());
        student.setAverage(studentDetails.getAverage());
        studentRepository.save(student);
        return ResponseEntity.ok(student);
     }
     @DeleteMapping("/{id}")
     public ResponseEntity<String> deleteStudent(@PathVariable int id){
        Student student= retieveStudentById(id);
        studentRepository.delete(student);
        return ResponseEntity.ok("Student deleted Successfully");
     }
     @GetMapping("/config/max_projects")
     public ResponseEntity<Integer> getMaxProjectPerStudent(){
         return ResponseEntity.ok(maxProjectPerStudent);
     }
     @PutMapping("/config/max_projects")
     public ResponseEntity<Integer> updateMaxProjectsPerStudent(@RequestBody int maximumNumber){
         maxProjectPerStudent=maximumNumber;
         return ResponseEntity.ok(maximumNumber);
    }

    // ============================ STUDENT PROJECT ===========================

    @GetMapping("/{student_id}/projects")
    public ResponseEntity<List<Project>> getProjectsByStudent(@PathVariable int student_id) {
        Student student = retieveStudentById(student_id);
        return ResponseEntity.ok(student.getProject());
    }

    @PostMapping("/{student_id}/projects/{project_id}")
    public ResponseEntity<Student> addProjectToStudent(@PathVariable int student_id , @PathVariable int project_id){
         Student student= retieveStudentById(student_id);
         Project project= retieveProjectById(project_id);
         for (Project p :student.getProject()){
             if(p.getId() == project.getId()){
                 return ResponseEntity.status(400).body(student);
             }
         }
         if (student.getProject().size()>=maxProjectPerStudent){
             return ResponseEntity.badRequest().body(student);
        }
         student.getProject().add(project);
         return ResponseEntity.status(HttpStatus.CREATED).body(studentRepository.save(student));
    }

    @DeleteMapping("/{student_id}/projects/{project_id}")
    public ResponseEntity<Student> deleteProjectFromStudent(@PathVariable int student_id , @PathVariable int project_id){
        Student student= retieveStudentById(student_id);
        Project project= retieveProjectById(project_id);
        student.getProject().remove(project);
        return ResponseEntity.ok(studentRepository.save(student));
    }

    @GetMapping("{student_id}/availableprojects")
    public ResponseEntity<List<Project>> getStudentAvailableProject(@PathVariable int student_id){
         Student student = retieveStudentById(student_id);
         List<Project> availableProject = new ArrayList<Project>();
         if (student.getProject().size() >=maxProjectPerStudent){
             return ResponseEntity.ok(availableProject);
         }
         List<Project> allProjects= projectRepository.findAll();
         HashSet<Integer> projectIds= new HashSet<>();
         for (Project p : student.getProject()){
             projectIds.add(p.getId());
         }
         for (Project pro: allProjects){
             if (! projectIds.contains(pro.getId())){
                 availableProject.add(pro);
             }
         }
    return ResponseEntity.ok(availableProject);
    }

    // =========================== ASSIGNMENT =============================

    @GetMapping("/assignment")
    public ResponseEntity<HashMap<String,String>> assignProjectToStudent(){
         HashMap<String,String> assignList= new HashMap<>();
         HashSet<Integer> projectIds = projectRepository.findAll()
                 .stream()
                 .map( Project::getId)
                 .collect(Collectors.toCollection(HashSet::new));
         List<Student> listStudent = studentRepository.findAll();
         listStudent.sort(  (Student s1, Student s2)->  Double.compare(s2.getAverage(), s1.getAverage()));
         for (Student s:listStudent){
             for (Project p:s.getProject()){
                 if(projectIds.contains(p.getId())){
                     assignList.put(s.getName(),p.getName());
                     projectIds.remove(p.getId());
                     break;
                 }
             }
         }
         return ResponseEntity.ok(assignList);
    }

}