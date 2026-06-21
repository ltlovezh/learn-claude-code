#!/usr/bin/env bash
# 同步上游仓库到本地 fork。
#
# 远端职责：
#   - upstream → 原始仓库 (shareAI-lab/learn-claude-code)，只读上游来源
#   - origin   → 个人 fork (ltlovezh/learn-claude-code)，推送目标
#
# 分支职责：
#   - upstream-tracking → 上游精确镜像，始终 reset --hard 到 upstream/main，
#                         不在此分支做任何本地改动
#   - main              → 日常开发分支，在 upstream-tracking 基础上 rebase，
#                         保留本地自定义提交，用 --force-with-lease 推送到 origin
#
# 同步流程：
#   1. fetch upstream/main
#   2. upstream-tracking reset --hard 到 upstream/main 并推送到 origin
#   3. 校验 upstream/main、本地 upstream-tracking、origin/upstream-tracking 三方一致
#   4. 把原分支 rebase 到 upstream-tracking 并 force-with-lease 推送到 origin
set -e

if ! git diff-index --quiet HEAD --; then
    echo "❌ 工作区有未提交修改，请先 commit 或 stash 后再同步"
    exit 1
fi

ORIG=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)

# --- Step 1: fetch upstream ---
echo "📥 [1/5] fetch upstream/main ..."
git fetch upstream main

# --- Step 2-3: 同步 upstream-tracking ---
echo "🔀 [2/5] checkout upstream-tracking ..."
git checkout upstream-tracking

echo "⏩ [3/5] reset --hard upstream/main ..."
git reset --hard upstream/main

# --- Step 4: push upstream-tracking ---
echo "📤 [4/5] push origin upstream-tracking ..."
git push origin upstream-tracking

# --- 验证三方同步 ---
H1=$(git rev-parse upstream/main)
H2=$(git rev-parse upstream-tracking)
H3=$(git rev-parse origin/upstream-tracking)
SHORT=$(git rev-parse --short upstream/main)

echo ""
if [ "$H1" = "$H2" ] && [ "$H2" = "$H3" ]; then
    echo "✅ upstream-tracking 三方完全同步 @ $SHORT"
else
    echo "⚠️  三方不一致:"
    echo "   upstream/main             = $H1"
    echo "   upstream-tracking (本地)  = $H2"
    echo "   origin/upstream-tracking  = $H3"
    exit 2
fi

# --- Step 5: 同步原分支到上游 ---
if [ "$ORIG" != "upstream-tracking" ] && [ -n "$ORIG" ]; then
    echo ""
    echo "🔁 [5/6] rebase $ORIG onto upstream-tracking ..."
    git checkout "$ORIG"

    BEFORE=$(git rev-parse HEAD)
    git rebase upstream-tracking || {
        echo ""
        echo "⚠️  rebase 冲突！请手动解决后执行 git rebase --continue"
        echo "   或放弃: git rebase --abort"
        exit 3
    }
    AFTER=$(git rev-parse HEAD)

    echo ""
    echo "✅ $ORIG 已 rebase 到 upstream-tracking"
    if [ "$BEFORE" != "$AFTER" ]; then
        echo "   $BEFORE → $AFTER"
    else
        echo "   (无变化，已是最新)"
    fi

    # --- Step 6: push 原分支到 origin ---
    echo ""
    echo "📤 [6/6] push --force-with-lease origin $ORIG ..."
    git push --force-with-lease origin "$ORIG"
else
    echo ""
    echo "✅ 当前在 upstream-tracking 分支，无需 rebase"
fi

echo ""
echo "🎉 全部分支同步完成"
