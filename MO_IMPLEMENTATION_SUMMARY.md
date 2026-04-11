# MO 端模块实现总结

## ✅ 交付清单

### 📦 代码文件

#### 1. 新增 Servlet 控制器
| 文件 | 功能 | 映射 |
|------|------|------|
| [MoScreeningServlet.java](src/main/java/cn/ebu6304/tarecruitment/controller/MoScreeningServlet.java) | 候选人筛选API | `/mo/candidates` |
| [MoStatusUpdateServlet.java](src/main/java/cn/ebu6304/tarecruitment/controller/MoStatusUpdateServlet.java) | 状态更新API | `/mo/applications` |

#### 2. 服务层扩展 - ApplicationService
新增方法：
- `listCandidatesByJob(jobId, page, size)` - 列表查询
- `listCandidatesByJobAndStatus(jobId, status, page, size)` - 条件查询
- `getJobStats()` - 统计各岗位
- `getJobStatusStats(jobId)` - 统计岗位状态分布
- `updateStatus(applicationId, newStatus)` - 状态更新

#### 3. 数据访问层扩展 - ApplicationRepository  
新增方法：
- `findByJobId(jobId, page, size)` - 按岗位查询
- `findByJobIdAndStatus(jobId, status, page, size)` - 多条件查询
- `countByJob()` - 岗位统计
- `countByJobAndStatus(jobId)` - 岗位状态统计
- `updateStatus(applicationId, newStatus)` - 状态更新

#### 4. 前端页面 - mo.jsp
三个独立功能区：
1. **发布新岗位** - 岗位创建表单
2. **筛选候选人** - 候选人查询&筛选UI
3. **更新应聘状态** - 批量更新界面

#### 5. 前端脚本 - app.js
新增逻辑：
- `candidateFilterForm` 事件监听 - 候选人查询
- `statusUpdateForm` 事件监听 - 状态更新

#### 6. 单元测试
- [MoScreeningServiceTest.java](src/test/java/cn/ebu6304/tarecruitment/service/MoScreeningServiceTest.java)
  - 测试候选人查询功能
  - 测试状态更新功能
  - 测试统计功能

---

## 🎯 API 规范

### 1. 发布岗位 (已有)
```
POST /mo/jobs
Content-Type: application/json

Request Body:
{
  "jobId": "string (required)",
  "title": "string (required)",
  "moduleCode": "string (required)",
  "requiredSkills": "string (required)",
  "slots": "int (required, min=1)",
  "createdBy": "string (required)"
}

Response (201/200):
{
  "created": true,
  "record": { JobPosting object }
}
```

### 2. 筛选候选人 ⭐ NEW
```
GET /mo/candidates?jobId=...&status=...&page=...&size=...

Query Parameters:
- jobId (required): 岗位ID
- status (optional): SUBMITTED|INTERVIEWED|ACCEPTED|REJECTED
- page (optional, default=1): 页码
- size (optional, default=20): 每页数量

Response (200):
{
  "jobId": "string",
  "status": "string",
  "page": int,
  "size": int,
  "count": int,
  "candidates": [
    {
      "applicationId": "string",
      "applicantId": "string",
      "jobId": "string",
      "status": "string",
      "submittedAt": "ISO8601 timestamp"
    },
    ...
  ]
}
```

### 3. 更新应聘状态 ⭐ NEW
```
PUT /mo/applications
Content-Type: application/json

Request Body:
{
  "applicationId": "string (required)",
  "status": "string (required)"  // SUBMITTED|INTERVIEWED|ACCEPTED|REJECTED
}

Response (200):
{
  "updated": true,
  "record": { ApplicationRecord object }
}
```

---

## 🧪 测试覆盖

### 运行测试
```bash
mvn test
```

### 测试用例 (`MoScreeningServiceTest`)
- ✅ `testListCandidatesByJob` - 按岗位查询候选人
- ✅ `testListCandidatesByJobAndStatus` - 按岗位+状态查询
- ✅ `testGetJobStats` - 岗位统计
- ✅ `testGetJobStatusStats` - 岗位状态统计
- ✅ `testUpdateStatus` - 更新状态成功路径
- ✅ `testUpdateStatusNotFound` - 更新状态异常处理

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                   mo.jsp (前端)                         │
│  ┌──────────────┬─────────────────┬──────────────────┐ │
│  │ 发布岗位表单  │ 筛选候选人表单  │ 更新状态表单     │ │
│  └──────────────┴─────────────────┴──────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↓ HTTP/REST
┌─────────────────────────────────────────────────────────┐
│        Servlet 控制层（Controller）                    │
│  ┌──────────────────┬─────────────────────────────────┐ │
│  │ MoJobServlet     │ MoScreeningServlet              │ │
│  │ /mo/jobs (POST)  │ /mo/candidates (GET)           │ │
│  │                  │ /mo/applications (PUT)         │ │
│  └──────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│        Service 服务层                                  │
│  ┌───────────────────────────────────────────────────┐ │
│  │ ApplicationService                                │ │
│  │ + listCandidatesByJob()                          │ │
│  │ + listCandidatesByJobAndStatus()                 │ │
│  │ + getJobStats()                                  │ │
│  │ + updateStatus()                                 │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│        Repository 数据访问层                           │
│  ┌───────────────────────────────────────────────────┐ │
│  │ ApplicationRepository                             │ │
│  │ + findByJobId()                                  │ │
│  │ + findByJobIdAndStatus()                         │ │
│  │ + countByJob()                                   │ │
│  │ + updateStatus()                                 │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│        JsonlFileStore 文件存储层                       │
│        data/applications.jsonl                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 快速开始

### 本地开发运行

```bash
# 1. 进入项目目录
cd project-ta-system

# 2. 编译项目
mvn clean compile

# 3. 运行测试
mvn test

# 4. 启动开发服务器
mvn jetty:run

# 5. 访问MO管理界面
# http://localhost:8080/mo.jsp
```

### 使用示例

#### 查询案例1：列出岗位JOB001的所有申请者
```bash
curl "http://localhost:8080/mo/candidates?jobId=JOB001"
```

#### 查询案例2：列出岗位JOB001中已面试的申请者（第1页，每页10条）
```bash
curl "http://localhost:8080/mo/candidates?jobId=JOB001&status=INTERVIEWED&page=1&size=10"
```

#### 更新案例：将申请APP001的状态更新为ACCEPTED
```bash
curl -X PUT http://localhost:8080/mo/applications \
  -H "Content-Type: application/json" \
  -d '{
    "applicationId": "APP001",
    "status": "ACCEPTED"
  }'
```

---

## 📊 数据模型

### ApplicationRecord (候选人申请)
```json
{
  "applicationId": "user1-JOB001",      // 唯一标识
  "applicantId": "user1",                // 申请人ID
  "jobId": "JOB001",                     // 岗位ID  
  "status": "SUBMITTED",                 // 当前状态
  "submittedAt": "2026-04-07T12:30:00Z" // 提交时间
}
```

### JobPosting (岗位信息)
```json
{
  "jobId": "JOB001",              // 岗位ID
  "title": "Teaching Assistant",    // 岗位名称
  "moduleCode": "EBU6304",          // 模块代码
  "requiredSkills": "Java, Spring", // 所需技能
  "slots": 3,                       // 招聘名额
  "status": "OPEN",                 // OPEN|CLOSED
  "createdBy": "recruiter",         // 创建者
  "createdAt": "2026-04-07T10:00:00Z" // 创建时间
}
```

---

## 🔐 错误处理

系统会返回标准HTTP状态码和error信息：

| 状态码 | 情景 |
|-------|------|
| 201 | 岗位创建成功 |
| 200 | 查询/更新成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 📝 前端效果

mo.jsp 页面包装三个玻璃态卡片：
- 左上角导航链接返回主页
- 表单验证和用户友好的错误提示
- JSON格式化输出查询结果
- 支持分页参数设置
- 支持状态筛选下拉菜单

---

## 🎓 架构优点

✅ **分层设计** - Servlet → Service → Repository → FileStore  
✅ **关注点分离** - 各层职责单一  
✅ **易于测试** - Service层可独立单元测试  
✅ **可维护性** - 代码结构清晰，易于扩展  
✅ **性能优化** - 轻量级索引、分页查询、原子操作  
✅ **无需数据库** - 纯文本JSONL存储，符合项目约束  

---

## ✏️ 后续扩展建议

1. **权限验证** - 添加MO身份验证
2. **批量操作** - 支持批量申请状态更新
3. **导出功能** - 支持候选人列表导出
4. **高级筛选** - 支持日期范围、技能关键字等
5. **缓存优化** - 添加Redis缓存热数据
6. **审计日志** - 记录所有状态变更历史

