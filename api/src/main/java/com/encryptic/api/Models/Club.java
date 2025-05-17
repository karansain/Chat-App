package com.encryptic.api.Models;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import lombok.Data;

@Entity
@Data
public class Club {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(length = 500)
    private String description;

    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private Set<ClubMembership> members = new HashSet<>();

    @Column(nullable = false)
    private int capacity;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ClubStatus status;

    @Column(nullable = true)
    private String imageUrl;

    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @JsonManagedReference
    List<Questions> questions;

    // Check if a user is an admin by their role
    public boolean isAdmin(User user) {
        return members.stream()
                .anyMatch(membership -> membership.getUser().equals(user) && membership.getRole() == ClubRole.ADMIN);
    }

    // Check if the club is full
    public boolean isFull() {
        return members.size() >= capacity;
    }

    // Add a user to the club with a specific role
    public void addMember(User user, ClubRole role) {
        if (isFull()) {
            throw new IllegalStateException("Club is full");
        }
        ClubMembership membership = new ClubMembership();
        membership.setClub(this);
        membership.setUser(user);
        membership.setRole(role);
        members.add(membership);
    }

    // Remove a user from the club
    public void removeMember(User user) {
        members.removeIf(membership -> membership.getUser().equals(user));
    }
}
