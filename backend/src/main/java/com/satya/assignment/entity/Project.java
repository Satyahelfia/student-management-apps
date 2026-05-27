package com.satya.assignment.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name="project")
public class Project{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @Column(name="name")
    private String name;

    @ManyToMany(mappedBy = "projects")
    @JsonIgnore
    private List<Student> students;

    @Lob
    @Column(name="pdf_data", columnDefinition="LONGBLOB")
    @JsonIgnore
    private byte[] pdfData;

    @Column(name="pdf_name")
    private String pdfName;

    @Column(name="pdf_type")
    private String pdfType;

    @Lob
    @Column(name="image_data", columnDefinition="LONGBLOB")
    @JsonIgnore
    private byte[] imageData;

    @Column(name="image_name")
    private String imageName;

    @Column(name="image_type")
    private String imageType;

    public byte[] getPdfData() {
        return pdfData;
    }

    public void setPdfData(byte[] pdfData) {
        this.pdfData = pdfData;
    }

    public String getPdfName() {
        return pdfName;
    }

    public void setPdfName(String pdfName) {
        this.pdfName = pdfName;
    }

    public String getPdfType() {
        return pdfType;
    }

    public void setPdfType(String pdfType) {
        this.pdfType = pdfType;
    }

    public byte[] getImageData() {
        return imageData;
    }

    public void setImageData(byte[] imageData) {
        this.imageData = imageData;
    }

    public String getImageName() {
        return imageName;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }

    public String getImageType() {
        return imageType;
    }

    public void setImageType(String imageType) {
        this.imageType = imageType;
    }


    public String getName() {
        return name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id){
        this.id = id;
    }

    public void setName(String name){
        this.name = name;
    }

    @Override
    public String toString() {
        return "Project{" +
                "id=" + id +
                ", name='" + name + '\'' +
                '}';
    }
}
