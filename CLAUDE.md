# CLAUDE.md — 个人记账管理系统

## 项目概览

基于 Spring Boot + Vue 3 + MySQL 的个人记账管理系统，支持多用户数据隔离、收支记录管理、分类管理和数据统计。

## 技术栈

| 层级   | 技术                                           |
| ------ | ---------------------------------------------- |
| 后端   | Spring Boot 3.3.7, MyBatis Plus 3.5.9, Java 17 |
| 前端   | Vue 3 (Composition API), Vite, Element Plus     |
| 图表   | ECharts 5.6.0                                  |
| 状态   | Pinia (localStorage 持久化)                     |
| 数据库 | MySQL 9.7, 库名 account_management             |

## 项目结构

```
AccountManagement/
├── backend/                          # Spring Boot 后端
│   ├── pom.xml                       # Maven — 含 Lombok annotationProcessor
│   └── src/main/java/.../
│       ├── AccountManagementApplication.java
│       ├── common/Result.java        # 统一响应体 {code, msg, data}
│       ├── config/
│       │   ├── CorsConfig.java       # CORS 跨域
│       │   ├── MyBatisPlusConfig.java
│       │   └── MetaObjectHandlerConfig.java  # 自动填充时间戳
│       ├── entity/                   # User, Category, Record
│       ├── mapper/
│       ├── service/
│       └── controller/
├── frontend/                         # Vue 3 前端
│   ├── vite.config.js                # Vite, /api → localhost:8080 代理
│   └── src/
│       ├── api/                      # request.js (axios), user/category/record API
│       ├── router/index.js           # 路由: /login, / (MainLayout 嵌套)
│       ├── stores/auth.js            # Pinia 认证状态 (userId, token)
│       └── views/
│           ├── Login.vue             # 登录/注册
│           ├── Dashboard.vue         # 仪表盘 (概览卡片 + 图表)
│           ├── Income.vue            # 收入管理
│           ├── Expense.vue           # 支出管理
│           ├── Categories.vue        # 分类管理
│           ├── Statistics.vue        # 数据统计 (图表明细)
│           └── layout/MainLayout.vue # 侧边栏 + 顶部布局
└── sql/
    └── init.sql                      # 建库建表脚本
```

## 数据库连接

- 主机: `localhost:3306`
- 用户: `root`
- 密码: `xubin200593@`
- 库名: `account_management`
- MySQL 服务名: `MYSQL97`

## 运行命令

### 后端

```bash
cd backend
mvn spring-boot:run        # 启动在 :8080
```

或在 IDEA 中运行 `AccountManagementApplication.java`

### 前端

```bash
cd frontend
npm install                 # 首次安装依赖
npm run dev                 # 启动在 :5173, /api 代理到 :8080
npm run build               # 生产构建 → dist/
```

## 关键架构决策

### 密码安全
- `User.password` 使用 `@JsonProperty(access = WRITE_ONLY)` — 接收但不在 API 中返回
- **不要使用 `@JsonIgnore`**，否则注册时密码不可反序列化为 null，导致数据库 NOT NULL 约束报错

### 用户数据隔离
- 所有记录 API (`GET /records`) 接收可选的 `userId` 查询参数
- 前端所有页面通过 `useAuthStore().user.id` 获取当前用户 ID，并在调用 API 时传入
- 严禁在任何地方硬编码 `userId: 1` — 这是之前多用户隔离失败的根本原因

### 模拟数据
- 前后端代码中**不得包含**模拟数据后备（catch 块中的 mock fallback）
- API 调用失败时应展示空状态和错误提示，不要用假数据

### MyBatis Plus 分页
- MyBatis Plus 3.5.9 **移除了** `PaginationInnerInterceptor` 类
- 不要在 Config 中显式创建 `MybatisPlusInterceptor` bean
- 如需分页，使用 MyBatis Plus 自动配置

## 已知陷阱

| 陷阱                                   | 解决方案                                   |
| -------------------------------------- | ------------------------------------------ |
| Lombok 编译报错 (找不到 getter/setter)   | pom.xml 中 maven-compiler-plugin 需配置 annotationProcessorPaths |
| `@JsonIgnore` 导致注册失败              | 改用 `@JsonProperty(access = WRITE_ONLY)`  |
| MySQL 服务在运行，但 3306 端口未监听     | 通过 `mysql -u root -p` 管道执行 SQL，而非 TCP 连接 |
| IDEA 中端口 8080 冲突                   | `taskkill //PID <pid> //F` 终止旧进程       |
| 前端代理 404                            | 确认 vite.config.js 中 proxy target 为 `http://localhost:8080` |
