package com.encryptic.api.Models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder

// @SuppressWarnings({"unchecked", "rawtypes", "unused"}) 
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO) 
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    private String photoUrl;

    @Enumerated(EnumType.STRING)
    private UserStatus status; 

    @Column(nullable = false, unique = true)
    private String rawPrivateKey; // Store the raw key

    @Column(nullable = false, unique = true)
    private String privateKey;

    
    @ManyToMany(fetch = FetchType.EAGER) 
    @JoinTable(name = "user_friends", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "friend_id"))
    @JsonIgnore
    private Set<User> friends = new HashSet<>();

    
    @ManyToMany(fetch = FetchType.EAGER) 
    @JoinTable(name = "user_blocked", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "blocked_user_id"))
    @JsonIgnore 
    private Set<User> blockedUsers = new HashSet<>(); 

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        User user = (User) o;
        return Objects.equals(username, user.username);
    }

    @Override
    public int hashCode() {
        return Objects.hash(username);
    }

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private Set<ClubMembership> clubMemberships = new HashSet<>();

    public String getImageUrl() {
        throw new UnsupportedOperationException("Unimplemented method 'getImageUrl'");
    }

}
