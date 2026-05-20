CREATE TABLE IF NOT EXISTS `user` (
    `id`         BIGINT AUTO_INCREMENT PRIMARY KEY,
    `username`   VARCHAR(50)  NOT NULL UNIQUE,
    `password`   VARCHAR(255) NOT NULL,
    `nickname`   VARCHAR(50)  DEFAULT NULL,
    `avatar`     VARCHAR(255) DEFAULT NULL,
    `email`      VARCHAR(100) DEFAULT NULL,
    `created_at` TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    `deleted`    TINYINT      DEFAULT 0
);

CREATE TABLE IF NOT EXISTS `category` (
    `id`         BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id`    BIGINT       DEFAULT NULL,
    `name`       VARCHAR(50)  NOT NULL,
    `type`       VARCHAR(10)  NOT NULL,
    `icon`       VARCHAR(50)  DEFAULT NULL,
    `color`      VARCHAR(20)  DEFAULT NULL,
    `parent_id`  BIGINT       DEFAULT NULL,
    `sort_order` INT          DEFAULT 0,
    `created_at` TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    `deleted`    TINYINT      DEFAULT 0
);

CREATE TABLE IF NOT EXISTS `record` (
    `id`          BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id`     BIGINT         NOT NULL,
    `category_id` BIGINT         DEFAULT NULL,
    `type`        VARCHAR(10)    NOT NULL,
    `amount`      DECIMAL(12,2)  NOT NULL,
    `description` VARCHAR(255)   DEFAULT NULL,
    `record_date` DATE           NOT NULL,
    `created_at`  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    `deleted`     TINYINT        DEFAULT 0
);

INSERT INTO category (id, user_id, name, type, icon, color, sort_order) VALUES
(1,  NULL, '餐饮',  'EXPENSE', 'Food',       '#E74C3C', 1),
(2,  NULL, '交通',  'EXPENSE', 'Van',        '#F39C12', 2),
(3,  NULL, '购物',  'EXPENSE', 'ShoppingBag','#E91E63', 3),
(4,  NULL, '住房',  'EXPENSE', 'House',      '#9B59B6', 4),
(5,  NULL, '娱乐',  'EXPENSE', 'VideoPlay',  '#3498DB', 5),
(6,  NULL, '医疗',  'EXPENSE', 'FirstAidKit','#1ABC9C', 6),
(7,  NULL, '教育',  'EXPENSE', 'Reading',    '#2ECC71', 7),
(8,  NULL, '通讯',  'EXPENSE', 'Iphone',     '#607D8B', 8),
(9,  NULL, '其他支出','EXPENSE','More',      '#95A5A6', 9),
(10, NULL, '工资',  'INCOME', 'Salary',      '#67C23A', 1),
(11, NULL, '奖金',  'INCOME', 'Present',     '#E6A23C', 2),
(12, NULL, '投资收益','INCOME','TrendCharts','#409EFF', 3),
(13, NULL, '兼职',  'INCOME', 'PartTime',    '#909399', 4),
(14, NULL, '其他收入','INCOME','More',       '#B0BEC5', 5);
