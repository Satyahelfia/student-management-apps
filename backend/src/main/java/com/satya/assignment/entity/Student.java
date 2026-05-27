package com.satya.assignment.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

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
    @OrderColumn(name = "project_order")
    private List<Project> projects = new ArrayList<>();

    public int getId() {
        return id;
    }

    public List<Project> getProjects() {
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

    public void setProjects(List<Project> projects) {
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
