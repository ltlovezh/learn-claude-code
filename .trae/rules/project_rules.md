# 项目规范

## 通用规范
1. 当运行Python代码时，确保在虚拟环境中执行
2. 生成代码时，添加函数级中文注释
3. 项目中的.claude/settings.local.json是本地调试文件，不要加入git版本管理

## agents 模块规范
4. 打印Message数组时，统一使用 `from msg_printer import print_messages`，不要手写打印逻辑。该函数支持 `color`（yellow/purple/green/cyan/red/blue）、`label`、`indent` 参数来区分不同来源的消息流。
