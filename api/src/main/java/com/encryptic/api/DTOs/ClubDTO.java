package com.encryptic.api.DTOs;

import com.encryptic.api.Models.Club;
import com.encryptic.api.Models.ClubStatus;

import lombok.Data;

@Data
public class ClubDTO {

    private Long id;
    private String name;
    private String description;
    private int currentMembers;
    private int capacity;
    private String imageUrl;
    private ClubStatus status;

    // Constructor to easily convert from Club entity to ClubDTO
    public ClubDTO(Club club) {
        this.id = club.getId();
        this.name = club.getName();
        this.description = club.getDescription();
        this.currentMembers = club.getMembers().size();
        this.capacity = club.getCapacity();
        this.imageUrl = club.getImageUrl();
        this.status = club.getStatus();
    }
}
