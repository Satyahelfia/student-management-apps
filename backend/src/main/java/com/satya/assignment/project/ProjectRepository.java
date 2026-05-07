package com.satya.assignment.project;

import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Integer>{
    @Modifying
    @Transactional
    @Query(value = "DELETE FROM STUDENT_PROJECT WHERE PROJECT_ID=?1", nativeQuery = true)
    public void deleteFromStudentProjectByProjectId(Integer project_id);
}
