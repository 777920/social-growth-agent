# 智拓 · 线上获客 Agent

面向**品牌方与线下门店**的线上获客运营 Agent Web 应用，基于 CodeBuddy Agent SDK 构建。

它不是一个泛泛的聊天机器人，而是一支「线上运营小组」：从选题、写文案、拍脚本，到私信话术、数据复盘，直接产出**可复制即用的交付物**。

---

## 内置运营岗位

| Agent | 定位 | 核心交付物 |
| --- | --- | --- |
| 全域获客运营官（默认） | 统筹策略 | 人群拆解、平台分工、30 天冷启动排期表、转化链路、数据看板 |
| 小红书种草运营 | 种草 + 搜索获客 | 10 个选题 / 3 版标题 / 笔记正文 / 封面建议 / 关键词与话题 / 合规检查 |
| 抖音短视频运营 | 爆量 + 本地生活 | 分镜脚本表、黄金 3 秒钩子、口播稿、发布配置、投流建议 |
| 视频号 & 私域运营 | 沉淀 + 复购 | 加微钩子、企微 SOP、社群日历、朋友圈脚本、转介绍机制 |
| 评论区 & 私信转化 | 临门一脚 | 评论区剧本、私信话术树、报价策略、跟进 SOP |
| 数据复盘 & 增长诊断 | 找卡点 | 漏斗归因、优化动作清单（按 ROI 排序）、A/B 测试方案、周报模板 |
| 门店本地获客 | 同城 3-5 公里 | 同城流量地图、探店达人方案、团购套餐设计、到店活动、CAC 测算 |

所有 Agent 共享一套底层工作准则（见 `src/agents/presets.ts` 中的 `BASE_OPERATOR_RULES`）：

- 先确认「行业客单价 / 目标人群城市 / 当前阶段」三要素，缺失就做标注假设，不空转追问
- 拒绝正确的废话，所有建议落到「谁、在哪、发什么、何时发、怎么衡量」
- 文案直接给成品，不只给思路
- 主动提示广告法禁词与平台导流合规风险

---

## 视频蒸馏

在聊天输入框上方有一个**视频蒸馏**入口：粘贴视频链接或上传本地视频文件，
Agent 会自动蒸馏视频内容并生成运营拆解笔记，一键带入对话。

### 蒸馏策略（分层降级）

| 层级 | 条件 | 产出 |
| --- | --- | --- |
| 字幕提取 | 视频有手动/自动字幕（B站、YouTube 覆盖率高） | 完整口播文字稿 |
| 语音转文字 | 无字幕 + 本地有 whisper 模型 | ASR 转录稿 |
| 元数据兜底 | 上述均不可用 | 标题/描述/标签 |

蒸馏完成后，运营 Agent 会从视频内容中拆解出：主题、黄金 3 秒钩子、脚本结构、
核心卖点、可复用点、改造建议、合规风险。

### 环境准备

视频蒸馏依赖 Python 工具链，首次使用需初始化：

```bash
cd social-growth-agent

# 1. 创建 Python 虚拟环境
C:/Users/Administrator/.workbuddy/binaries/python/versions/3.13.12/python.exe -m venv .venv

# 2. 安装依赖（yt-dlp 抓取 + faster-whisper 语音转文字 + imageio-ffmpeg 音频处理）
.venv/Scripts/python.exe -m pip install yt-dlp faster-whisper imageio-ffmpeg
```

> **ASR 模型说明**：faster-whisper 首次运行需从 HuggingFace 下载 base 模型（约 150MB）。
> 若网络环境无法访问 HuggingFace，蒸馏会自动降级为「字幕优先 + 元数据兜底」。
> 设置环境变量 `HF_ENDPOINT=https://hf-mirror.com` 可用国内镜像加速；
> 已下载模型后设置 `DISTILL_ALLOW_DOWNLOAD=1` 可正常使用 ASR。

### 支持平台

yt-dlp 支持 1000+ 平台，实测可达：B站、YouTube（需代理）。抖音/小红书/视频号
受平台反爬影响，成功率视具体视频而定；本地文件上传始终可用。

### 相关接口

| 接口 | 用途 |
| --- | --- |
| `GET /api/video/env` | 检查 Python/ffmpeg/whisper 环境就绪状态 |
| `POST /api/video/distill` | 启动蒸馏（JSON 传 url，或 multipart 上传 file） |
| `GET /api/video/distill/:jobId` | 轮询任务进度与结果 |
| `GET /api/video/distill/:jobId/context` | 获取可带入对话的文本 |

---

## 快速开始

```bash
cd social-growth-agent
npm install
npm run dev
```

- 前端：http://localhost:5173
- 后端：http://localhost:3000

编辑 `.env` 后启动（推荐直接编辑，前端“设置”页的配置接口默认只对管理员开放）：

```bash
cp .env.example .env
# 填入 LLM_API_KEY，例如 DeepSeek 的 sk-xxx
```

支持任意 **OpenAI 兼容** 服务：DeepSeek、通义千问、Kimi、智谱 GLM、OpenAI 等。

### 演示模式（托管/销售演示）

设置 `DEMO_MODE=1` 后，访客无需授权码即可使用核心功能（对话 / 视频蒸馏 / 生图 / 数据看板），
前端自动切换为移动端友好的演示版：隐藏“设置”入口、显示演示横幅、底部导航。
配置类接口在演示模式下对访客关闭；设置 `ADMIN_TOKEN` 后管理员可携带
`Authorization: Bearer <ADMIN_TOKEN>` 访问配置与授权接口。
可选设置 `DEMO_ACCESS_TOKEN`，开启后访客需先输入访问令牌。

---

## 关于对话引擎

应用支持两条对话链路，启动时自动选择：

| 引擎 | 触发条件 | 说明 |
| --- | --- | --- |
| `openai-compatible` | 配置了 `LLM_API_KEY` | **推荐**。可独立部署，人设、多轮上下文、流式输出均正常 |
| `codebuddy` | 配置了 `CODEBUDDY_API_KEY` / `AUTH_TOKEN` | Agent SDK 链路，附带工具调用能力 |

> **已知限制**：CodeBuddy Agent SDK 通过 spawn `codebuddy-headless.js` 子进程工作，
> 该 CLI 依赖宿主运行时（WorkBuddy Desktop）在进程内提供网关鉴权。
> 在独立部署环境中，其 `initialize` 握手无法完成，表现为请求静默超时且无任何输出。
> 因此本项目内置了 OpenAI 兼容引擎作为可独立运行的对话链路。

相关接口：

| 接口 | 用途 |
| --- | --- |
| `GET /api/engine/status` | 当前引擎、就绪状态、服务商预设列表 |
| `POST /api/engine/test` | 仅测试连通性，不保存（需管理员令牌） |
| `POST /api/engine/config` | 校验通过后保存配置（需管理员令牌） |
| `DELETE /api/engine/config` | 清除运行时配置（需管理员令牌） |
| `GET /api/debug/dns` | 诊断：关键域名解析情况（需管理员令牌） |
| `GET /api/debug/sdk` | 诊断：在服务器上下文实测 SDK 握手（需管理员令牌） |

> 安全说明：`POST /api/license/issue` 已移除，授权码只能通过本机 CLI
> `scripts/generate-license.ts` 签发；API Key 一律不返回明文，仅返回脱敏值；
> 所有状态变更接口带同源（CSRF）校验，核心消耗型接口按 IP 限流。
> 上线部署（Docker + EdgeOne）见交付包 `智拓-EdgeOne上线包/deploy/README.md`。

---

## 使用建议

1. **首次使用**：进入首页 → 选择运营岗位 → 点击「试试这些高频任务」快捷标签 → 把示例里的品牌信息改成你自己的 → 发送。
2. **素材 / 交付物目录**：在新对话页填入一个本地目录（如 `D:\品牌资料\小红书内容库`），Agent 就能读取你的品牌资料，并把生成的文案、脚本直接存成文件。
3. **权限模式**：
   - 只想要方案 → `仅规划`
   - 需要 Agent 帮你批量写文件 → `自动编辑`
   - 默认模式下每次文件操作都会弹窗确认
4. **自定义品牌版本**：设置页 → 内置运营岗位 → 「复制修改」，把品牌调性、禁用词、产品信息写进系统提示词，之后的产出会自动带上品牌约束。

---

## 项目结构

```
social-growth-agent/
├── server/
│   ├── index.ts          # Express + SSE，双引擎路由 + 视频蒸馏路由
│   ├── llm-engine.ts     # ★ 对话引擎抽象：OpenAI 兼容流式客户端 + 服务商预设
│   ├── video-distill.ts  # ★ 视频蒸馏：调 Python + LLM 结构化拆解 + 任务管理
│   └── db.ts             # SQLite 会话与消息持久化
├── scripts/
│   └── distill.py        # ★ 视频蒸馏 Python 脚本（yt-dlp 抓取 + 字幕/ASR + 分层降级）
├── src/
│   ├── agents/presets.ts # ★ 运营 Agent 人设库与快捷提示词（核心资产）
│   ├── components/       # UI 组件（含 EngineConfigCard 引擎配置、VideoDistillBar 视频蒸馏栏）
│   ├── hooks/            # useChat / useAgents / useSessions / useModels
│   ├── pages/ChatPage.tsx
│   └── config.ts         # 应用名称与文案
└── data/chat.db          # 会话数据库（运行后生成）
```

想调整 Agent 能力，**改 `src/agents/presets.ts` 就够了**；`server/index.ts` 里的 `DEFAULT_OPERATOR_PROMPT` 是前端未传提示词时的服务端兜底，建议同步修改。

---

## 合规提醒

内置提示词已包含广告法与平台规则约束，但 **AI 产出仍需人工复核后再发布**，特别是医疗、美业、教育、食品等强监管品类。所有涉及效果承诺、绝对化用语、导流方式的内容，请以平台最新规则为准。
