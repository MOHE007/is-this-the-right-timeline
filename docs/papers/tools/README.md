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
