package com.satya.assignment.project;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/projects")
public class ProjectController {

    @Autowired
    private ProjectService projectService;

    @GetMapping("/")
    public ResponseEntity<List<Project>> getAllProjects() {
        return ResponseEntity.ok(projectService.getAllProjects());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Project> getProjectById(@PathVariable int id) {
        return ResponseEntity.ok(projectService.getProjectById(id));
    }

    @PostMapping(value = "/", consumes = {"application/json"})
    public ResponseEntity<Project> createProjectJson(@RequestBody Project projectDetails) {
        Project project = projectService.createProject(projectDetails);
        return ResponseEntity.status(HttpStatus.CREATED).body(project);
    }

    @PostMapping(value = "/", consumes = {"multipart/form-data"})
    public ResponseEntity<Project> createProject(
            @RequestParam("name") String name,
            @RequestParam(value = "pdf", required = false) org.springframework.web.multipart.MultipartFile pdfFile,
            @RequestParam(value = "image", required = false) org.springframework.web.multipart.MultipartFile imageFile) throws java.io.IOException {
        Project project = projectService.createProjectWithFiles(name, pdfFile, imageFile);
        return ResponseEntity.status(HttpStatus.CREATED).body(project);
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> getProjectPdf(@PathVariable int id) {
        Project project = projectService.getProjectById(id);
        if (project.getPdfData() == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(org.springframework.http.HttpHeaders.CONTENT_TYPE, project.getPdfType() != null ? project.getPdfType() : "application/pdf")
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + project.getPdfName() + "\"")
                .body(project.getPdfData());
    }

    @GetMapping("/{id}/image")
    public ResponseEntity<byte[]> getProjectImage(@PathVariable int id) {
        Project project = projectService.getProjectById(id);
        if (project.getImageData() == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
                .header(org.springframework.http.HttpHeaders.CONTENT_TYPE, project.getImageType() != null ? project.getImageType() : "image/png")
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + project.getImageName() + "\"")
                .body(project.getImageData());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Project> updateProject(@PathVariable int id, @RequestBody Project projectDetails) {
        return ResponseEntity.ok(projectService.updateProject(id, projectDetails));
    }

    @PutMapping(value = "/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Project> updateProjectWithFiles(
            @PathVariable int id,
            @RequestParam("name") String name,
            @RequestParam(value = "pdf", required = false) org.springframework.web.multipart.MultipartFile pdfFile,
            @RequestParam(value = "image", required = false) org.springframework.web.multipart.MultipartFile imageFile) throws java.io.IOException {
        Project project = projectService.updateProjectWithFiles(id, name, pdfFile, imageFile);
        return ResponseEntity.ok(project);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProject(@PathVariable int id) {
        projectService.deleteProject(id);
        return ResponseEntity.ok("Project deleted successfully");
    }
}

