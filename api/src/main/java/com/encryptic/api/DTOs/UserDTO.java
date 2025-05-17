package com.encryptic.api.DTOs;

import java.util.Set;

import com.encryptic.api.Models.UserStatus;

import lombok.Data;

@Data
public class UserDTO {
    private Long id;
    private String email;
    private String username;
    private String photoUrl;
    private UserStatus status;
    private Set<Long> blockedUserIds; // Just IDs or any other required fields
}

// final int id;
// final String email;
// final String username;
// final String photoUrl;
// final String status;
