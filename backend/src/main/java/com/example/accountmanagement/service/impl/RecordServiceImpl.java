package com.example.accountmanagement.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.accountmanagement.entity.Record;
import com.example.accountmanagement.mapper.RecordMapper;
import com.example.accountmanagement.service.RecordService;
import org.springframework.stereotype.Service;

@Service
public class RecordServiceImpl extends ServiceImpl<RecordMapper, Record> implements RecordService {
}
