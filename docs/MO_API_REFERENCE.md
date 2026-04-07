# MO 端 API 快速参考

## 🔗 端点列表

### ✅ 已有功能
| 方法 | 端点 | 功能 |
|------|------|------|
| POST | `/mo/jobs` | 发布新岗位 |
| GET | `/jobs` | 查询所有岗位 |
| POST | `/applications` | 提交应聘 |
| GET | `/applications` | 查询我的应聘 |

### ⭐ 新增功能
| 方法 | 端点 | 功能 | 说明 |
|------|------|------|------|
| GET | `/mo/candidates` | 按岗位查询候选人 | MO筛选核心功能 |
| PUT | `/mo/applications` | 更新应聘状态 | 面试后管理状态 |

---

## 📌 GET /mo/candidates - 候选人筛选

最常用的MO功能。支持多维度筛选：

### 请求示例

```javascript
// 查询岗位JOB001的所有申请者
fetch('/mo/candidates?jobId=JOB001')

// 查询岗位JOB001已面试的申请者（第2页，每页10条）
fetch('/mo/candidates?jobId=JOB001&status=INTERVIEWED&page=2&size=10')
```

### 查询参数

| 参数 | 类型 | 必需 | 默认值 | 备注 |
|------|------|------|-------|------|
| `jobId` | string | ✅ | - | 岗位ID |
| `status` | enum | ❌ | ALL | SUBMITTED\|INTERVIEWED\|ACCEPTED\|REJECTED |
| `page` | int | ❌ | 1 | 分页页码 |
| `size` | int | ❌ | 20 | 每页条数 |

### 成功响应 (HTTP 200)

```json
{
  "jobId": "JOB001",
  "status": "INTERVIEWED",
  "page": 2,
  "size": 10,
  "count": 5,
  "candidates": [
    {
      "applicationId": "user1-JOB001",
      "applicantId": "user1",
      "jobId": "JOB001",
      "status": "INTERVIEWED",
      "submittedAt": "2026-04-07T08:00:00Z"
    },
    {
      "applicationId": "user2-JOB001",
      "applicantId": "user2",
      "jobId": "JOB001",
      "status": "INTERVIEWED",
      "submittedAt": "2026-04-07T09:30:00Z"
    }
  ]
}
```

### 错误响应

```json
// 缺少jobId参数 (HTTP 400)
{
  "error": "jobId is required"
}

// 无效的状态值 (HTTP 400)
{
  "error": "Validation failed"
}
```

---

## 🔄 PUT /mo/applications - 状态更新

更新单个候选人的申请状态。

### 请求示例

```javascript
fetch('/mo/applications', {
  method: 'PUT',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    applicationId: 'user1-JOB001',
    status: 'ACCEPTED'
  })
})
```

### 请求体

| 字段 | 类型 | 必需 | 备注 |
|------|------|------|------|
| `applicationId` | string | ✅ | 申请记录ID |
| `status` | string | ✅ | SUBMITTED\|INTERVIEWED\|ACCEPTED\|REJECTED |

### 成功响应 (HTTP 200)

```json
{
  "updated": true,
  "record": {
    "applicationId": "user1-JOB001",
    "applicantId": "user1",
    "jobId": "JOB001",
    "status": "ACCEPTED",
    "submittedAt": "2026-04-07T08:00:00Z"
  }
}
```

### 错误响应

```json
// 申请不存在 (HTTP 404)
{
  "error": "Application not found or status unchanged for applicationId=..."
}

// 缺少必需字段 (HTTP 400)
{
  "error": "applicationId is required"
}
```

---

## POST /mo/jobs - 发布岗位 (回顾)

MO创建新的招聘岗位。

### 请求示例

```javascript
fetch('/mo/jobs', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    jobId: 'TA-CS301-2026',
    title: 'Teaching Assistant for Advanced Java',
    moduleCode: 'CS301',
    requiredSkills: 'Java 17+, Spring Boot 3.x',
    slots: 2,
    createdBy: 'recruiter@bupt.edu.cn'
  })
})
```

### 请求体

| 字段 | 类型 | 必需 | 备注 |
|------|------|------|------|
| `jobId` | string | ✅ | 唯一标识符 |
| `title` | string | ✅ | 岗位名称 |
| `moduleCode` | string | ✅ | 模块代码，如CS301 |
| `requiredSkills` | string | ✅ | 所需技能，逗号分隔 |
| `slots` | int | ✅ | 招聘名额，最小1 |
| `createdBy` | string | ✅ | 创建者身份 |

### 成功响应 (HTTP 201)

```json
{
  "created": true,
  "record": {
    "jobId": "TA-CS301-2026",
    "title": "Teaching Assistant for Advanced Java",
    "moduleCode": "CS301",
    "requiredSkills": "Java 17+, Spring Boot 3.x",
    "slots": 2,
    "status": "OPEN",
    "createdBy": "recruiter@bupt.edu.cn",
    "createdAt": "2026-04-07T10:00:00Z"
  }
}
```

---

## 🎯 常见用例

### 用例1：查看某个岗位有多少人申请？
```javascript
// 查询并检查count字段
const response = await fetch('/mo/candidates?jobId=JOB001');
const data = await response.json();
console.log(`岗位${data.jobId}共有${data.count}名申请者`);
```

### 用例2：找到所有面试过的申请者
```javascript
const response = await fetch('/mo/candidates?jobId=JOB001&status=INTERVIEWED');
const data = await response.json();
data.candidates.forEach(c => {
  console.log(`${c.applicantId} 已面试`);
});
```

### 用例3：批量录用申请者
```javascript
// 对多个applicants执行状态更新
const appIds = ['user1-JOB001', 'user3-JOB001'];
for (const appId of appIds) {
  await fetch('/mo/applications', {
    method: 'PUT',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      applicationId: appId,
      status: 'ACCEPTED'
    })
  });
}
```

### 用例4：生成某岗位的应聘数统计
```javascript
async function getJobStats(jobId) {
  const stats = {
    submitted: 0,
    interviewed: 0,
    accepted: 0,
    rejected: 0
  };
  
  for (const status of ['SUBMITTED', 'INTERVIEWED', 'ACCEPTED', 'REJECTED']) {
    const response = await fetch(`/mo/candidates?jobId=${jobId}&status=${status}`);
    const data = await response.json();
    stats[status.toLowerCase()] = data.count;
  }
  
  return stats;
}
```

---

## 🪲 调试技巧

### 1. 在浏览器控制台测试
```javascript
// 在mo.jsp页面按F12打开控制台，直接调用api()函数
await api('/mo/candidates?jobId=JOB001').then(d => console.table(d.candidates))
```

### 2. 使用curl命令行
```bash
# 查询候选人
curl "http://localhost:8080/mo/candidates?jobId=JOB001&status=INTERVIEWED"

# 更新状态
curl -X PUT http://localhost:8080/mo/applications \
  -H "Content-Type: application/json" \
  -d '{"applicationId":"user1-JOB001","status":"ACCEPTED"}'
```

### 3. 使用Postman/Thunderclient
- 导入API端点到REST客户端
- 快速编辑参数并查看响应
- 自动格式化JSON输出

---

## 📊 状态转换图

```
SUBMITTED  ──→  INTERVIEWED  ──→  ACCEPTED
    ↓                ↓
    └──{REJECTED}────┴────{NOT SELECTED}
```

可能的状态转换：
- SUBMITTED → INTERVIEWED（面试邀请）
- INTERVIEWED → ACCEPTED（录取）
- INTERVIEWED → REJECTED（不录取）
- SUBMITTED → REJECTED（直接拒绝）

---

## 🚨 常见问题

**Q: 查询返回0条候选人？**  
A: 检查jobId是否正确，确认岗位已创建且有人申请过。

**Q: 更新状态报404？**  
A: applicationId须精确匹配，格式通常为`{applicantId}-{jobId}`。

**Q: 如何修改状态后不影响历史记录？**  
A: 系统采用追加写入，历史记录自动保留，最新的应用被查询。

**Q: 支持批量更新吗？**  
A: 目前需逐个调用。批量API可作为后续功能扩展。

