#!/usr/bin/env python3
# 消息数组打印工具，支持不同颜色区分不同来源的消息流

# ANSI颜色码映射
COLORS = {
    "yellow": "\033[33m",
    "purple": "\033[35m",
    "green": "\033[32m",
    "cyan": "\033[36m",
    "red": "\033[31m",
    "blue": "\033[34m",
}
RESET = "\033[0m"


def _format_block(block) -> str:
    """格式化单个content block的描述"""
    if isinstance(block, dict):
        if block.get("type") == "tool_use":
            return f"tool_use({block.get('name', '?')})"
        elif block.get("type") == "tool_result":
            preview = str(block.get("content", ""))[:50].replace("\n", "\\n")
            return f"tool_result({preview})"
        else:
            return f"dict({block.get('type', '?')})"
    elif hasattr(block, "type"):
        if block.type == "tool_use":
            return f"tool_use({getattr(block, 'name', '?')})"
        elif block.type == "text":
            preview = getattr(block, "text", "")[:50].replace("\n", "\\n")
            return f"text({preview})"
        else:
            return f"obj({block.type})"
    else:
        return f"{type(block).__name__}"


def print_messages(messages: list, label: str = "messages", color: str = "yellow", indent: int = 2):
    """打印消息数组内容，区分不同类型的message

    Args:
        messages: 消息数组
        label: 标签名（如 history / sub_messages）
        color: ANSI颜色名，支持 yellow/purple/green/cyan/red/blue
        indent: 缩进空格数
    """
    c = COLORS.get(color, COLORS["yellow"])
    pad = " " * indent

    print(f"{c}{pad}--- {label} ({len(messages)} messages) ---{RESET}")
    for i, msg in enumerate(messages):
        role = msg["role"]
        content = msg["content"]
        if isinstance(content, str):
            preview = content[:120].replace("\n", "\\n")
            print(f"{c}{pad}[{i}] {role}: str | {preview}{RESET}")
        elif isinstance(content, list):
            block_types = [_format_block(b) for b in content]
            print(f"{c}{pad}[{i}] {role}: list | {', '.join(block_types)}{RESET}")
    print(f"{c}{pad}--- end {label} ---{RESET}")
