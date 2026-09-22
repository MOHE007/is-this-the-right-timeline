# 论文导出工具链

这台机器上**没有** pandoc、LibreOffice、weasyprint、reportlab。所以导出分两条独立路径，
各自只用本机确实存在的东西：

| 目标 | 路径 | 依赖 |
| --- | --- | --- |
| Word `.docx` | `md_to_docx.py` | python-docx（已装） |
| PDF | `md_to_html.py` + Chrome 无头打印 | Google Chrome |

## 用法

```bash
cd docs/papers

# Word
python3 tools/md_to_docx.py multi-agent-narrative-game-engineering.md \
        multi-agent-narrative-game-engineering.docx

# PDF：先生成打印用 HTML，再用 Chrome 无头模式打印
python3 tools/md_to_html.py multi-agent-narrative-game-engineering.md /tmp/paper.html
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-first-run --user-data-dir=/tmp/chrome-pdf-profile \
  --no-pdf-header-footer --print-to-pdf=multi-agent-narrative-game-engineering.pdf \
  "file:///tmp/paper.html"
```

注意两点（都是踩过的坑）：

1. **新版 Chrome 无头模式打印完不会自己退出**，PDF 写完后进程仍挂着。
   脚本化时要"等文件大小稳定"再 `kill`，不要等进程结束，否则会误判为超时失败。
2. **`--user-data-dir` 必须指向临时目录**，否则会和用户正在使用的 Chrome 配置冲突。

## 字体：本机可用的只有一个粗黑体

标题用黑体、正文用宋体才有层级。但本机（macOS）**没有 PingFang SC**，
且 Chrome 打印时也**匹配不到 `Hiragino Sans GB`**（探针实测：写了等于没写，静默回落）。
CSS 里字体栈的顺序不是随便排的，实测结果：

| CSS 字体名 | 是否匹配 | 实际嵌入 |
| --- | --- | --- |
| `"Heiti SC"` | ✅ | `STHeitiSC-Medium`（粗）/ `STHeitiSC-Light` |
| `"STHeiti"` | ✅ | `STHeiti` |
| `"Heiti TC"` | ✅ | `STHeitiTC-Medium` |
| `"Songti SC"` | ✅ | `STSongti-SC-Regular` |
| `"STSong"` | ✅ | `STSong` |
| `"Hiragino Sans GB"` / `W3` / `W6` | ❌ | — |
| `"PingFang SC"` | ❌ | — |
| `"Microsoft YaHei"` / `"Noto Sans SC"` | ❌ | — |

所以标题栈必须以 `"Heiti SC"` 打头。**字体栈写错的症状很隐蔽**：不报错、不警告，
只是 PDF 里少嵌一个字体、标题悄悄退回正文宋体，粗细层级整个消失。
验证方法是直接查 PDF 里的 `/BaseFont`：

```bash
python3 - <<'EOF'
import re
d = open("multi-agent-narrative-game-engineering.pdf", "rb").read()
print(re.findall(rb"/Count\s+(\d+)", d)[-1])                      # 页数
for f in sorted(set(re.findall(rb"/BaseFont\s*/([A-Za-z0-9+\-]+)", d))):
    print(f.decode())
EOF
```

标题字体在 → `STHeitiSC-Medium` 出现；只有 `STSongti` 就是字体栈配错了。

## Word 侧的两个隐蔽缺陷

这两个都**不报错**，只有在长文档里才显形：

**① 有序列表跨节串号。** python-docx 默认模板里所有 `List Number` 样式段落共用
同一个样式级 `numId`，Word 会把它当成**一个连续列表**：§3.5 的 1-3 之后，
§7.1 会从 4 开始、§8.3 会从 16 开始——而论文每一节都必须从 1 重新计数。

排查方法：`document.xml` 里搜不到 `numPr`，说明编号来自样式；再看 `styles.xml`
发现 `ListNumber → numId=5` 全局唯一，即确诊。

修法是**不用列表样式**，改「字面序号 + 悬挂缩进」，编号完全由 Markdown 原文决定。

**② 标题没有大纲结构。** 标题若输出成普通加粗段落，Word 导航窗格是空的，
长篇文档无法跳转。必须用真正的 `Heading N` 样式，再在 run 层覆盖字体、字号与配色
（否则会带回模板自带的蓝色与西文字体）。

另一个细节：紧跟在 H1 后的 H3（"——以……为例"这类副标题）**不是章节标题**，
按 Heading 3 输出会让它以"3 级标题"混进导航窗格，因此单独居中排版、不进大纲。

## Word 侧的中文字体

`.docx` 里用 `宋体`（正文）/ `黑体`（标题）这两个**中文规范名**，而不是 macOS 的
`Songti SC` / `Heiti SC`：Word、WPS 在 Windows 与 macOS 上都有对应的替换表，
用规范名两端都能正确落地，用平台名则换到另一端就丢字体。
两套脚本都显式写 `w:eastAsia`，否则中文会掉进默认字体。

## 转换后必须做的核验

不要靠肉眼看 PDF（尤其在无法读图的终端环境里）。逐项比对 Markdown 与产物的结构计数：

```bash
python3 - <<'EOF'
import re, pathlib
md   = pathlib.Path("multi-agent-narrative-game-engineering.md").read_text(encoding="utf-8")
html = pathlib.Path("/tmp/paper.html").read_text(encoding="utf-8")
print("标题  ", len(re.findall(r"^#{1,6}\s+", md, re.M)), len(re.findall(r"<h[1-6]>", html)))
print("列表  ", len(re.findall(r"^\s*(?:[-*]|\d+\.)\s+", md, re.M)), len(re.findall(r"<li>", html)))
print("代码块", len(re.findall(r"^```", md, re.M)) // 2, len(re.findall(r"<pre>", html)))
EOF
```

表格要单独比：Markdown 的 `|` 行数包含 `|---|---|` 分隔行，不能直接和 HTML 的
`<tr>` 数比，必须先滤掉分隔行。曾经因为直接比而误判成"内容丢失"。

正文文本可以做逐字符 diff，但**必须先把 Markdown 的行内标记（`**`、`` ` ``、表格竖线）
归一化掉**，否则 diff 里会刷出几百行"差异"，实际上一个字都没丢。

### 更可靠的做法：分类逐条比对

计数只能发现"少了/多了"，发现不了"换成别的字了"。真正可靠的是**把文档拆成五类，
每类逐条比对文本**：标题、表格单元、列表项、代码块、散文。
本项目实测五类全部逐字符一致。

写这个核验脚本时有个反直觉的坑：**清洗两侧文本的顺序必须不同**。

- HTML 侧：**先**剥标签 → **再**反转义（`&lt;` → `<`）
- Markdown 侧：只去 Markdown 标记，**绝对不要去尖括号**

因为正文里存在 `<base>`、`handoff=<码>` 这类**字面文本**。如果 md 侧也做
"去掉 `<...>`"，这些内容会被当成 HTML 标签删掉，于是 diff 报出差异——
但那是**核验脚本的 bug，不是文档的 bug**。我为此白查了两轮。
