package com.encryptic.api.Repositories;



import org.springframework.data.jpa.repository.JpaRepository;

import com.encryptic.api.Models.Message;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findBySenderAndReceiverOrReceiverAndSender(String sender1, String receiver1, String sender2, String receiver2);

}

