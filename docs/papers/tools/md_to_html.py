#!/usr/bin/env python3
"""把论文 Markdown 转成适合打印的 HTML（供 Chrome 无头模式导出 PDF）。

用法:
    python3 md_to_html.py <input.md> <output.html>

之所以走 HTML，是因为本机没有 pandoc / LibreOffice / weasyprint，
而 Chrome 的 --print-to-pdf 是唯一可控且离线的排版路径。
CSS 针对 A4 打印做了分页保护（标题不孤行、表格不跨页断裂）。
"""
from __future__ import annotations

import html
import re
import sys
from pathlib import Path

CSS = """
@page { size: A4; margin: 20mm 18mm 18mm 18mm; }
* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body {
  font-family: "Songti SC", "Noto Serif CJK SC", "Source Han Serif SC", serif;
  font-size: 10.5pt; line-height: 1.75; color: #1b1a18;
  margin: 0; padding: 0;
}
/* 字体栈经探针实测（本机缺失 PingFang SC / Hiragino 与 Chrome 不匹配）：
   只有 "Heiti SC" 能在 Chrome 打印时提供粗字面 STHeitiSC-Medium，
   放错顺序会让标题静默回落到正文宋体、丢失层级。 */
h1, h2, h3, h4, h5 {
  font-family: "Heiti SC", "STHeiti", "Hiragino Sans GB", "Microsoft YaHei",
               "Noto Sans CJK SC", "PingFang SC", sans-serif;
  color: #8a3a26; line-height: 1.35; break-after: avoid; page-break-after: avoid;
}
h1 { font-size: 20pt; text-align: center; margin: 0 0 6pt; letter-spacing: 0.5pt; }
h1 + h3 { text-align: center; color: #6b6259; font-weight: 500;
          font-size: 11.5pt; margin: 0 0 18pt; }
h2 { font-size: 14.5pt; margin: 20pt 0 8pt; padding-bottom: 4pt;
     border-bottom: 1px solid #d9d2c6; }
h3 { font-size: 12pt; margin: 14pt 0 6pt; color: #6d2f1f; }
h4 { font-size: 11pt; margin: 12pt 0 5pt; color: #3a3733; }
p { margin: 0 0 7pt; text-align: justify; }
strong { font-family: "Heiti SC", "STHeiti", "Microsoft YaHei", "Noto Sans SC", sans-serif; font-weight: 600; }
code { font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 9pt;
       color: #8a3a26; background: #f6f3ed; padding: 0 2pt; border-radius: 2pt; }
pre {
  font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 8.6pt; line-height: 1.55;
  background: #f7f5f0; border: 1px solid #e3ddd1; border-radius: 3pt;
  padding: 7pt 9pt; margin: 7pt 0 10pt; white-space: pre-wrap; word-break: break-word;
  break-inside: avoid; page-break-inside: avoid;
}
pre code { background: none; color: #2b2823; padding: 0; font-size: 8.6pt; }
table { width: 100%; border-collapse: collapse; margin: 7pt 0 12pt;
        font-size: 9pt; break-inside: auto; }
thead { display: table-header-group; }
tr { break-inside: avoid; page-break-inside: avoid; }
th, td { border: 1px solid #cfc7b8; padding: 3.5pt 5pt; text-align: left;
         vertical-align: top; line-height: 1.5; }
th { background: #f0ece2; font-family: "Heiti SC", "STHeiti", "Microsoft YaHei", "Noto Sans SC", sans-serif;
     font-weight: 600; }
tbody tr:nth-child(even) td { background: #faf8f4; }
blockquote { margin: 7pt 0 7pt 10pt; padding: 3pt 0 3pt 9pt;
             border-left: 2.5pt solid #c9b9a4; color: #4a463f; font-style: italic; }
ul, ol { margin: 0 0 8pt; padding-left: 18pt; }
li { margin-bottom: 2.5pt; }
hr { border: none; border-top: 1px solid #ded7ca; margin: 12pt 0; }
"""


def inline(text: str) -> str:
    out = html.escape(text)
    out = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", out)
    out = re.sub(r"`(.+?)`", r"<code>\1</code>", out)
    out = re.sub(r"(?<![\w*])\*([^*]+?)\*(?![\w*])", r"<em>\1</em>", out)
    return out


def convert(md_path: Path, html_path: Path) -> None:
    lines = md_path.read_text(encoding="utf-8").split("\n")
    body: list[str] = []
    i = 0
    in_code = False
    in_frontmatter = False
    in_table = False
    in_list = None  # "ul" | "ol"

    def close_list():
        nonlocal in_list
        if in_list:
            body.append(f"</{in_list}>")
            in_list = None

    def close_table():
        nonlocal in_table
        if in_table:
            body.append("</tbody></table>")
            in_table = False

    title = "文档"

    while i < len(lines):
        line = lines[i].rstrip()

        if i == 0 and line.strip() == "---":
            in_frontmatter = True
            i += 1
            continue
        if in_frontmatter:
            if line.strip() == "---":
                in_frontmatter = False
            i += 1
            continue

        if line.startswith("```"):
            close_list(); close_table()
            if in_code:
                body.append("<pre><code>" + html.escape("\n".join(buf)) + "</code></pre>")
                in_code = False
            else:
                in_code = True
                buf: list[str] = []
            i += 1
            continue
        if in_code:
            buf.append(line)
            i += 1
            continue

        if line.startswith("|") and line.endswith("|"):
            close_list()
            cells = [c.strip() for c in line.strip("|").split("|")]
            if all(re.fullmatch(r":?-{2,}:?", c) for c in cells):
                i += 1
                continue
            if not in_table:
                body.append("<table><thead><tr>"
                            + "".join(f"<th>{inline(c)}</th>" for c in cells)
                            + "</tr></thead><tbody>")
                in_table = True
            else:
                body.append("<tr>" + "".join(f"<td>{inline(c)}</td>" for c in cells) + "</tr>")
            i += 1
            continue
        close_table()

        stripped = line.strip()
        if not stripped:
            close_list()
            i += 1
            continue
        if re.fullmatch(r"-{3,}", stripped):
            close_list()
            body.append("<hr>")
            i += 1
            continue

        m = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if m:
            close_list()
            level = len(m.group(1))
            text = m.group(2)
            if level == 1:
                title = re.sub(r"<[^>]+>", "", text)
            body.append(f"<h{level}>{inline(text)}</h{level}>")
            i += 1
            continue

        if stripped.startswith(">"):
            close_list()
            body.append(f"<blockquote>{inline(stripped.lstrip('> ').strip())}</blockquote>")
            i += 1
            continue

        m = re.match(r"^[-*]\s+(.*)$", stripped)
        if m:
            if in_list != "ul":
                close_list(); body.append("<ul>"); in_list = "ul"
            body.append(f"<li>{inline(m.group(1))}</li>")
            i += 1
            continue
        m = re.match(r"^\d+\.\s+(.*)$", stripped)
        if m:
            if in_list != "ol":
                close_list(); body.append("<ol>"); in_list = "ol"
            body.append(f"<li>{inline(m.group(1))}</li>")
            i += 1
            continue

        close_list()
        body.append(f"<p>{inline(stripped)}</p>")
        i += 1

    close_list(); close_table()
    if in_code and buf:
        body.append("<pre><code>" + html.escape("\n".join(buf)) + "</code></pre>")

    doc = f"""<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8">
<title>{html.escape(title)}</title>
<style>{CSS}</style></head>
<body>
{chr(10).join(body)}
</body></html>
"""
    html_path.parent.mkdir(parents=True, exist_ok=True)
    html_path.write_text(doc, encoding="utf-8")
    print(f"wrote {html_path} ({len(doc.encode('utf-8'))} bytes)")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        raise SystemExit(1)
    convert(Path(sys.argv[1]), Path(sys.argv[2]))
