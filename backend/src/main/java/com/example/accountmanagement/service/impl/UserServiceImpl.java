package com.example.accountmanagement.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.accountmanagement.entity.User;
import com.example.accountmanagement.mapper.UserMapper;
import com.example.accountmanagement.service.UserService;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
}
