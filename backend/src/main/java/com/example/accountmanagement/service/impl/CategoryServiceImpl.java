package com.example.accountmanagement.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.accountmanagement.entity.Category;
import com.example.accountmanagement.mapper.CategoryMapper;
import com.example.accountmanagement.service.CategoryService;
import org.springframework.stereotype.Service;

@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category> implements CategoryService {
}
