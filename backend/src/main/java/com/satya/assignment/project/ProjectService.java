package com.satya.assignment.project;

import com.satya.assignment.common.exception.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProjectService {

    @Autowired
    private ProjectRepository projectRepository;

    public List<Project> getAllProjects() {
        return projectRepository.findAll();
    }

    public Project getProjectById(int id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project", id));
    }

    public Project createProject(Project projectDetails) {
        return projectRepository.save(projectDetails);
    }

    public Project createProjectWithFiles(String name, org.springframework.web.multipart.MultipartFile pdfFile, org.springframework.web.multipart.MultipartFile imageFile) throws java.io.IOException {
        Project project = new Project();
        project.setName(name);

        if (pdfFile != null && !pdfFile.isEmpty()) {
            project.setPdfData(pdfFile.getBytes());
            project.setPdfName(pdfFile.getOriginalFilename());
            project.setPdfType(pdfFile.getContentType());
        }

        if (imageFile != null && !imageFile.isEmpty()) {
            project.setImageData(imageFile.getBytes());
            project.setImageName(imageFile.getOriginalFilename());
            project.setImageType(imageFile.getContentType());
        }

        return projectRepository.save(project);
    }


    public Project updateProject(int id, Project projectDetails) {
        Project project = getProjectById(id);
        project.setName(projectDetails.getName());
        return projectRepository.save(project);
    }

    public Project updateProjectWithFiles(int id, String name, org.springframework.web.multipart.MultipartFile pdfFile, org.springframework.web.multipart.MultipartFile imageFile) throws java.io.IOException {
        Project project = getProjectById(id);
        project.setName(name);

        if (pdfFile != null && !pdfFile.isEmpty()) {
            project.setPdfData(pdfFile.getBytes());
            project.setPdfName(pdfFile.getOriginalFilename());
            project.setPdfType(pdfFile.getContentType());
        }

        if (imageFile != null && !imageFile.isEmpty()) {
            project.setImageData(imageFile.getBytes());
            project.setImageName(imageFile.getOriginalFilename());
            project.setImageType(imageFile.getContentType());
        }

        return projectRepository.save(project);
    }

    public void deleteProject(int id) {
        Project project = getProjectById(id);
        projectRepository.deleteFromStudentProjectByProjectId(id);
        projectRepository.delete(project);
    }
}
