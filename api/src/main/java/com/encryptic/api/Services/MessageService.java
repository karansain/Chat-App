package com.encryptic.api.Services;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.encryptic.api.Models.Message;
import com.encryptic.api.Repositories.MessageRepository;

import java.util.List;

@Service
public class MessageService {

    @Autowired
    private MessageRepository messageRepository;

    public Message saveMessage(Message message) {
        return messageRepository.save(message);
    }

    public List<Message> getChatMessages(String sender, String receiver) {
        return messageRepository.findBySenderAndReceiverOrReceiverAndSender(sender, receiver, sender, receiver);
    }
    
}

