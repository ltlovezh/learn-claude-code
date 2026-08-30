# 学习记录

这里存放我跟着 Learn Claude Code 教程走的过程中的个人学习记录。

## 分支设计

```text
shareAI-lab/learn-claude-code (upstream)
      │  fetch（只拉不推，push 地址已设为 no_push）
      ▼
    main  ──push──►  origin/main     纯镜像，永远不在这里提交
      │  rebase 基线
      ▼
    diy   ──push──►  origin/diy      main + learning/ + 我对课程代码的改动
```

| 分支 | 跟踪 | 用途 | 规则 |
| --- | --- | --- | --- |
| `main` | `origin/main` | 同步 `shareAI-lab/learn-claude-code` 的原始代码 | 只做快进，不手写提交 |
| `diy` | `origin/diy` | 在 `main` 之上叠加学习改动 | 课程代码改动 + `learning/` |

两个远端：

- `origin` = `ltlovezh/learn-claude-code`（我的 fork，`main` / `diy` 都推这里）
- `upstream` = `shareAI-lab/learn-claude-code`（原始仓库，push 地址已禁用，防止误推）

> **2026-08-30 分支模型调整**：此前 `main` 是工作分支、`upstream-tracking` 是镜像，与工作区其他三个仓库（codex / deepseek-harness / pi）的约定相反，容易误操作。现已对齐：`main` 改为纯镜像，个人改动移到 `diy`。

## 与其他仓库的差异

这个仓库和工作区里另外三个不同 —— 它是**教学项目**（Python，19 章），不是可用的 harness。所以 `diy` 上的改动**不只在 `learning/` 里**：跟着教程改课程代码本身（如给 `s03_permission` 加对话历史打印）也是学习的一部分。

这意味着 rebase 到新的 `main` 时**可能产生冲突**，不像另外三个仓库那样天然无冲突。上游目前在做 monorepo 重构（见 `upstream/refactor/learn-agent-harness-monorepo`），冲突概率不低。

## 同步上游

```bash
./learning/sync.sh
```

需要在 `diy` 分支上运行。想在任何分支上跑：

```bash
git show diy:learning/sync.sh | bash
```

如果 `main` 上不小心提交过东西导致无法快进，脚本会报错、切回原分支并退出，不会硬来。

手动等价操作：

```bash
git fetch upstream
git switch main && git merge --ff-only upstream/main && git push origin main
git switch diy && git rebase main && git push --force-with-lease origin diy
```

## 写笔记的约定

- 一篇笔记一个文件，命名为 `YYYY-MM-DD-主题.md`，例如 `2026-08-30-s06-subagent.md`。
- 引用代码写成 `路径:行号`（如 `s06_subagent/main.py:42`），方便点击跳转。
- 写完在下面的索引里补一行。

## 章节与横向对比的对应

工作区根目录的 `common/agent-frameworks-comparison.html` 按维度对比了 codex / deepseek-harness / pi。本教程的章节与那些维度大致对应，建议先读这里建立概念，再去真实项目里看工业级实现：

| 教学章节 | 对比维度 |
| --- | --- |
| `s01_agent_loop` | Agent Loop |
| `s02_tool_use` / `s03_permission` | Tool 系统 / 权限 |
| `s04_hooks` / `s19_mcp_plugin` | 扩展机制 |
| `s06_subagent` / `s15_agent_teams` | Subagent |
| `s08_context_compact` | 上下文压缩 |
| `s09_memory` | 记忆 |

## 索引

| 日期 | 主题 | 笔记 |
| --- | --- | --- |
| - | 暂无 | - |
