# MO 端功能实现指南

## 📦 交付成果

### 1. **API 接口** 

#### POST /mo/jobs - 发布岗位
```json
Request:
{
  "jobId": "JOB001",
  "title": "Teaching Assistant",
  "moduleCode": "EBU6304",
  "requiredSkills": "Java, Spring Boot",
  "slots": 3,
  "createdBy": "mo_admin"
}

Response:
{
  "created": true,
  "record": {
    "jobId": "JOB001",
    "title": "Teaching Assistant",
    "status": "OPEN",
    ...
  }
}
```

#### GET /mo/candidates - 筛选候选人
```
Query Parameters:
- jobId (必需): 岗位ID
- status (可选): SUBMITTED|INTERVIEWED|ACCEPTED|REJECTED
- page (可选): 分页页码，默认1
- size (可选): 分页大小，默认20

Response:
{
  "jobId": "JOB001",
  "status": "SUBMITTED",
  "page": 1,
  "size": 20,
  "count": 15,
  "candidates": [
    {
      "applicationId": "user1-JOB001",
      "applicantId": "user1",
      "jobId": "JOB001",
      "status": "SUBMITTED",
      "submittedAt": "2026-04-07T00:00:00Z"
    },
    ...
  ]
}
```

#### PUT /mo/applications - 更新候选人状态
```json
Request:
{
  "applicationId": "user1-JOB001",
  "status": "INTERVIEWED"
}

Response:
{
  "updated": true,
  "record": {
    "applicationId": "user1-JOB001",
    "status": "INTERVIEWED",
    ...
  }
}
```

---

## 🎨 前端页面 (mo.jsp)

### 功能模块

1. **发布新岗位** - 创建新的招聘岗位
   - 输入：岗位ID、标题、模块代码、所需技能、岗位数量、创建者
   - 输出：创建结果及岗位详情

2. **筛选候选人** - 查看和筛选岗位的申请者
   - 输入：岗位ID、申请状态（可选）、分页参数
   - 输出：符合条件的候选人列表

3. **更新申请状态** - 对候选人进行状态更新
   - 输入：申请ID、新状态
   - 输出：更新后的申请记录

---

## 🔧 后端实现

### 新增 Servlet

1. **MoScreeningServlet** (`/mo/candidates`)
   - GET 方法：查询指定岗位的候选人
   - 支持按状态筛选
   - 支持分页查询

2. **MoStatusUpdateServlet** (`/mo/applications`)  
   - PUT 方法：更新申请状态
   - 验证申请ID和新状态
   - 返回更新后的记录

### Service 层增强

**ApplicationService** 新增方法：
- `listCandidatesByJob(jobId, page, size)` - 按岗位查询候选人
- `listCandidatesByJobAndStatus(jobId, status, page, size)` - 按岗位和状态查询
- `getJobStats()` - 获取各岗位的申请统计
- `getJobStatusStats(jobId)` - 获取特定岗位的状态统计
- `updateStatus(applicationId, newStatus)` - 更新申请状态

### Repository 层增强

**ApplicationRepository** 新增方法：
- `findByJobId(jobId, page, size)` - 按岗位查询申请
- `findByJobIdAndStatus(jobId, status, page, size)` - 按岗位和状态查询
- `countByJob()` - 统计各岗位申请数
- `countByJobAndStatus(jobId)` - 统计特定岗位各状态数
- `updateStatus(applicationId, newStatus)` - 更新申请状态

---

## 📋 候选人申请状态流转

支持的状态值：
- **SUBMITTED** - 已提交申请（初始状态）
- **INTERVIEWED** - 已面试
- **ACCEPTED** - 已录用
- **REJECTED** - 已拒绝

---

## 🧪 测试

运行测试套件：
```bash
mvn test
```

已创建的测试类：
- `MoScreeningServiceTest` - 覆盖MO筛选功能的单元测试

---

## 📝 使用示例

### 1. 创建岗位
```javascript
POST /mo/jobs
{
  "jobId": "TA-2026-001",
  "title": "TA for Advanced Java",
  "moduleCode": "CS301",
  "requiredSkills": "Java 17+",
  "slots": 2,
  "createdBy": "recruiter@bupt.edu.cn"
}
```

### 2. 查看岗位的所有申请者
```javascript
GET /mo/candidates?jobId=TA-2026-001
```

### 3. 查看岗位的已面试申请者
```javascript
GET /mo/candidates?jobId=TA-2026-001&status=INTERVIEWED
```

### 4. 更新申请状态
```javascript
PUT /mo/applications
{
  "applicationId": "user123-TA-2026-001",
  "status": "ACCEPTED"
}
```

---

## 🎯 关键特性

✅ **岗位发布** - MO可快速创建新岗位  
✅ **候选人筛选** - 支持按状态和岗位多维度筛选  
✅ **状态管理** - 完整的申请状态生命周期管理  
✅ **分页支持** - 高效处理大量申请记录  
✅ **前后端一体化** - JSP前端与Servlet后端无缝集成  

