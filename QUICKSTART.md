# MO 端快速命令参考

## 🚀 启动应用

```bash
# 进入项目目录
cd project-ta-system

# 启动开发服务器（Jetty）
mvn jetty:run

# 开浏览器访问 MO 页面
# http://localhost:8080/mo.jsp
```

---

## 📡 API 调用示例

### cURL 命令

#### 1️⃣ 发布岗位
```bash
curl -X POST http://localhost:8080/mo/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "jobId": "JOB001",
    "title": "Teaching Assistant",
    "moduleCode": "EBU6304",
    "requiredSkills": "Java, Spring Boot",
    "slots": 2,
    "createdBy": "recruiter@bupt.edu.cn"
  }'
```

#### 2️⃣ 查看岗位的所有候选人
```bash
curl "http://localhost:8080/mo/candidates?jobId=JOB001"
```

#### 3️⃣ 查看岗位的已面试候选人
```bash
curl "http://localhost:8080/mo/candidates?jobId=JOB001&status=INTERVIEWED"
```

#### 4️⃣ 使用分页查询
```bash
# 查询第2页，每页10条
curl "http://localhost:8080/mo/candidates?jobId=JOB001&page=2&size=10"
```

#### 5️⃣ 更新候选人状态
```bash
curl -X PUT http://localhost:8080/mo/applications \
  -H "Content-Type: application/json" \
  -d '{
    "applicationId": "user1-JOB001",
    "status": "ACCEPTED"
  }'
```

---

## 🧪 测试命令

```bash
# 运行所有单元测试
mvn test

# 只运行 MO 相关测试
mvn test -Dtest=MoScreeningServiceTest

# 编译检查
mvn clean compile

# 打包 WAR 文件
mvn clean package -DskipTests
```

---

## 📋 关键文件位置

| 文件 | 路径 | 说明 |
|------|------|------|
| MO 页面 | `src/main/webapp/mo.jsp` | 前端界面 |
| JavaScript | `src/main/webapp/assets/js/app.js` | 前端逻辑 |
| 候选人筛选 Servlet | `src/main/java/.../MoScreeningServlet.java` | /mo/candidates |
| 状态更新 Servlet | `src/main/java/.../MoStatusUpdateServlet.java` | /mo/applications |
| 服务类 | `src/main/java/.../ApplicationService.java` | 业务逻辑 |
| 数据层 | `src/main/java/.../ApplicationRepository.java` | 数据访问 |
| 单元测试 | `src/test/java/.../MoScreeningServiceTest.java` | 测试用例 |

---

## 📚 文档导航

```
项目根目录
├── 01_MO_DELIVERY_SUMMARY.md     ← 完整交付总结
├── DELIVERY_CHECKLIST.md         ← 交付检查清单
├── MO_IMPLEMENTATION_SUMMARY.md  ← 实现细节
├── docs/
│   ├── MO_FEATURES.md           ← 功能说明
│   └── MO_API_REFERENCE.md      ← API快速参考
└── QUICKSTART.md                ← 本文件
```

---

## 🔗 API 端点速查

### GET /mo/candidates
```
参数列表：
  ?jobId=JOB001                              (必需)
  &status=SUBMITTED|INTERVIEWED|...         (可选)
  &page=1                                   (可选，默认1)
  &size=20                                  (可选，默认20)

示例：
  /mo/candidates?jobId=JOB001
  /mo/candidates?jobId=JOB001&status=INTERVIEWED&page=1&size=10
```

### PUT /mo/applications
```
请求体：
{
  "applicationId": "string",  // 必需
  "status": "string"          // 必需
}

示例：
{
  "applicationId": "user1-JOB001",
  "status": "ACCEPTED"
}
```

### POST /mo/jobs
```
请求体：
{
  "jobId": "string",           // 必需
  "title": "string",           // 必需
  "moduleCode": "string",      // 必需
  "requiredSkills": "string",  // 必需
  "slots": int,                // 必需
  "createdBy": "string"        // 必需
}
```

---

## 🎯 常见场景

### 场景1：为新课程创建 TA 岗位并接收申请

```bash
# 步骤1: MO 发布岗位
curl -X POST http://localhost:8080/mo/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "jobId": "CS301-TA-2026",
    "title": "TA for Advanced Java",
    "moduleCode": "CS301",
    "requiredSkills": "Java 17+, Spring Boot",
    "slots": 3,
    "createdBy": "mo_admin"
  }'

# 步骤2: 学生提交申请（使用 /applications 端点）
curl -X POST http://localhost:8080/applications \
  -H "Content-Type: application/json" \
  -d '{
    "applicantId": "student001",
    "jobId": "CS301-TA-2026"
  }'

# 步骤3: MO 查看有多少申请
curl "http://localhost:8080/mo/candidates?jobId=CS301-TA-2026"

# 步骤4: MO 选出候选人进行面试
curl -X PUT http://localhost:8080/mo/applications \
  -H "Content-Type: application/json" \
  -d '{
    "applicationId": "student001-CS301-TA-2026",
    "status": "INTERVIEWED"
  }'

# 步骤5: 查看已面试的候选人
curl "http://localhost:8080/mo/candidates?jobId=CS301-TA-2026&status=INTERVIEWED"

# 步骤6: 录用最终候选人
curl -X PUT http://localhost:8080/mo/applications \
  -H "Content-Type: application/json" \
  -d '{
    "applicationId": "student001-CS301-TA-2026",
    "status": "ACCEPTED"
  }'
```

---

## 🛠️ 构建和部署

```bash
# 清理旧构建
mvn clean

# 编译源代码
mvn compile

# 运行测试
mvn test

# 构建可部署包
mvn package

# 一键构建（跳过测试）
mvn clean package -DskipTests

# 启动开发服务器
mvn jetty:run

# 终止服务（Ctrl+C）
# 在终端按 Ctrl+C
```

---

## 📊 响应示例

### 成功查询候选人 (200)
```json
{
  "jobId": "JOB001",
  "status": "INTERVIEWED",
  "page": 1,
  "size": 20,
  "count": 5,
  "candidates": [
    {
      "applicationId": "user1-JOB001",
      "applicantId": "user1",
      "jobId": "JOB001",
      "status": "INTERVIEWED",
      "submittedAt": "2026-04-07T10:00:00Z"
    },
    {
      "applicationId": "user2-JOB001",
      "applicantId": "user2",
      "jobId": "JOB001",
      "status": "INTERVIEWED",
      "submittedAt": "2026-04-07T11:00:00Z"
    }
  ]
}
```

### 成功更新状态 (200)
```json
{
  "updated": true,
  "record": {
    "applicationId": "user1-JOB001",
    "applicantId": "user1",
    "jobId": "JOB001",
    "status": "ACCEPTED",
    "submittedAt": "2026-04-07T10:00:00Z"
  }
}
```

### 错误响应 (400/404)
```json
{
  "error": "jobId is required"
}
```

---

## 💡 提示

### 浏览器控制台调试

在 `mo.jsp` 页面按 F12 打开开发者工具，在控制台输入：

```javascript
// 查询所有候选人
await api('/mo/candidates?jobId=JOB001')
  .then(d => console.table(d.candidates))

// 输出漂亮的 JSON
await api('/mo/candidates?jobId=JOB001')
  .then(d => console.log(JSON.stringify(d, null, 2)))

// 检查错误
await api('/invalid').catch(e => console.error(e.message))
```

---

## 🆘 常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|--------|
| 404 Not Found | 端点不存在 | 检查 URL 拼写，确认 Servlet 已启动 |
| 400 Bad Request | 参数错误 | 检查必需参数是否提供，格式是否正确 |
| 500 Server Error | 服务器异常 | 查看控制台日志，检查 JSON 格式 |
| 访问空白页 | 页面加载失败 | 刷新浏览器，检查网络连接 |
| 表单无响应 | JavaScript 错误 | 打开浏览器控制台查看错误信息 |

---

## 📞 获取帮助

1. **查阅文档**
   - [完整交付总结](01_MO_DELIVERY_SUMMARY.md)
   - [API 快速参考](docs/MO_API_REFERENCE.md)
   - [功能说明书](docs/MO_FEATURES.md)

2. **查看代码示例**
   - [单元测试](src/test/java/cn/ebu6304/tarecruitment/service/MoScreeningServiceTest.java)
   - [前端代码](src/main/webapp/mo.jsp)

3. **运行测试**
   ```bash
   mvn test -Dtest=MoScreeningServiceTest
   ```

---

**最后更新:** 2026-04-07  
**版本:** v0.2.0-SNAPSHOT  
**状态:** ✅ 就绪使用

