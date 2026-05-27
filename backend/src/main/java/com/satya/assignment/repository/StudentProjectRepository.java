package com.satya.assignment.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

import com.satya.assignment.entity.StudentProject;

public interface StudentProjectRepository extends JpaRepository<StudentProject, Integer> {
    List<StudentProject> findByStudentId(int studentId);
    Optional<StudentProject> findByStudentIdAndProjectId(int studentId, int projectId);
    void deleteByStudentIdAndProjectId(int studentId, int projectId);
}
