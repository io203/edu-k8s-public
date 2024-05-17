package com.example.demo.controller;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;



@RestController
public class DemoController {

    @GetMapping("/")
    public String home(){
        return "hello world demo !!! version: 3.0 changed ";
    }
    
}
