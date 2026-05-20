package com.example.accountmanagement.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.accountmanagement.common.Result;
import com.example.accountmanagement.entity.Record;
import com.example.accountmanagement.service.RecordService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/records")
public class RecordController {

    private final RecordService recordService;

    public RecordController(RecordService recordService) {
        this.recordService = recordService;
    }

    @GetMapping
    public Result<List<Record>> list(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        LambdaQueryWrapper<Record> wrapper = new LambdaQueryWrapper<>();
        if (userId != null) wrapper.eq(Record::getUserId, userId);
        if (categoryId != null) wrapper.eq(Record::getCategoryId, categoryId);
        if (type != null && !type.isEmpty()) wrapper.eq(Record::getType, type);
        if (startDate != null) wrapper.ge(Record::getRecordDate, startDate);
        if (endDate != null) wrapper.le(Record::getRecordDate, endDate);
        wrapper.orderByDesc(Record::getRecordDate);

        return Result.success(recordService.list(wrapper));
    }

    @GetMapping("/{id}")
    public Result<Record> getById(@PathVariable Long id) {
        return Result.success(recordService.getById(id));
    }

    @PostMapping
    public Result<Record> create(@RequestBody Record record) {
        recordService.save(record);
        return Result.success(record);
    }

    @PutMapping("/{id}")
    public Result<Record> update(@PathVariable Long id, @RequestBody Record record) {
        record.setId(id);
        recordService.updateById(record);
        return Result.success(record);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        recordService.removeById(id);
        return Result.success();
    }
}
