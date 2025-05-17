package com.encryptic.api.DTOs;

import com.encryptic.api.Models.UserStatus;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FriendDTO {

    private Long id;
    private String email;
    private String username;
    private String photoUrl;
    private UserStatus status;
    
}

// final int id;
// final String email;
// final String username;
// final String photoUrl;
// final String status;