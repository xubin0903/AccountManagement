package com.example.accountmanagement.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.accountmanagement.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
