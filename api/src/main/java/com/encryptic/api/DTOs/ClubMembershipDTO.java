package com.encryptic.api.DTOs;

import com.encryptic.api.Models.ClubRole;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ClubMembershipDTO {

    private Long id;
    private Long clubId;
    private String clubName; // Optional: If you want to include club name
    private Long userId;
    private String userName; // Optional: If you want to include user name
    private String userImage;
    private ClubRole role;

}
