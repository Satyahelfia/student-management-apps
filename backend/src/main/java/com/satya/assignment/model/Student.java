package com.satya.assignment.model;

import jakarta.persistence.*;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonManagedReference;
@Entity
@Table(name="student")
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @Column(name = "name")
    private String name;

    @Column(name = "average")
    private double average;
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "student_project",
            joinColumns = @JoinColumn (name = "student_id"),
            inverseJoinColumns = @JoinColumn(name = "project_id")
    )
    @JsonManagedReference
    @OrderColumn(name = "project_order")
    private List<Project> projects;

    public int getId() {
        return id;
    }

    public List<Project> getProject() {
        return projects;
    }

    public String getName() {
        return name;
    }

    public double getAverage() {
        return average;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setAverage(double average) {
        this.average = average;
    }

    public void setProject(List<Project> projects) {
        this.projects = projects;
    }

    @Override
    public String toString() {
        return "Student{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", average=" + average +
                ", project=" + projects +
                '}';
    }
}
