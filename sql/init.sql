-- =============================================
-- Account Management System - Database Init
-- =============================================

CREATE DATABASE IF NOT EXISTS account_management
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE account_management;

-- =============================================
-- 用户表
-- =============================================
DROP TABLE IF EXISTS `record`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username`   VARCHAR(50)  NOT NULL                COMMENT '用户名',
    `password`   VARCHAR(255) NOT NULL                COMMENT '密码',
    `nickname`   VARCHAR(50)  DEFAULT NULL            COMMENT '昵称',
    `avatar`     VARCHAR(255) DEFAULT NULL            COMMENT '头像',
    `email`      VARCHAR(100) DEFAULT NULL            COMMENT '邮箱',
    `created_at` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`    TINYINT(1)   DEFAULT 0               COMMENT '逻辑删除: 0=未删除, 1=已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =============================================
-- 分类表（收入/支出分类）
-- =============================================
CREATE TABLE `category` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id`    BIGINT       DEFAULT NULL            COMMENT '用户ID, NULL表示系统预设分类',
    `name`       VARCHAR(50)  NOT NULL                COMMENT '分类名称',
    `type`       VARCHAR(10)  NOT NULL                COMMENT '类型: INCOME=收入, EXPENSE=支出',
    `icon`       VARCHAR(50)  DEFAULT NULL            COMMENT '图标',
    `color`      VARCHAR(20)  DEFAULT NULL            COMMENT '标识颜色',
    `parent_id`  BIGINT       DEFAULT NULL            COMMENT '父分类ID',
    `sort_order` INT          DEFAULT 0               COMMENT '排序',
    `created_at` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`    TINYINT(1)   DEFAULT 0               COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- =============================================
-- 记账记录表
-- =============================================
CREATE TABLE `record` (
    `id`          BIGINT         NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id`     BIGINT         NOT NULL                COMMENT '用户ID',
    `category_id` BIGINT         DEFAULT NULL            COMMENT '分类ID',
    `type`        VARCHAR(10)    NOT NULL                COMMENT '类型: INCOME=收入, EXPENSE=支出',
    `amount`      DECIMAL(12,2)  NOT NULL                COMMENT '金额',
    `description` VARCHAR(255)   DEFAULT NULL            COMMENT '描述',
    `record_date` DATE           NOT NULL                COMMENT '记账日期',
    `created_at`  DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT(1)     DEFAULT 0               COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_type` (`type`),
    KEY `idx_record_date` (`record_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='记账记录表';
