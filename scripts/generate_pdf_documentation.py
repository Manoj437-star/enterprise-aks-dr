"""
Generate FINAL_PROJECT_DOCUMENTATION.pdf using markdown and headless Edge / Chrome print-to-pdf.
"""

import os
import subprocess
import re

def markdown_to_html(md_text):
    # Basic markdown to clean HTML parser for reporting
    lines = md_text.split('\n')
    html_lines = []
    in_table = False
    in_code = False
    in_ul = False
    in_ol = False

    for line in lines:
        stripped = line.strip()

        # Code block
        if stripped.startswith('```'):
            if in_code:
                html_lines.append('</code></pre>')
                in_code = False
            else:
                lang = stripped[3:].strip()
                html_lines.append(f'<pre><code class="language-{lang}">')
                in_code = True
            continue

        if in_code:
            html_lines.append(line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'))
            continue

        # Close lists or tables if necessary
        if in_ul and not stripped.startswith('- ') and not stripped.startswith('* '):
            html_lines.append('</ul>')
            in_ul = False
        if in_ol and not re.match(r'^\d+\.\s', stripped):
            html_lines.append('</ol>')
            in_ol = False
        if in_table and not stripped.startswith('|'):
            html_lines.append('</tbody></table>')
            in_table = False

        # Headings
        if stripped.startswith('# '):
            html_lines.append(f'<h1>{stripped[2:]}</h1>')
            continue
        elif stripped.startswith('## '):
            html_lines.append(f'<h2>{stripped[3:]}</h2>')
            continue
        elif stripped.startswith('### '):
            html_lines.append(f'<h3>{stripped[4:]}</h3>')
            continue
        elif stripped.startswith('#### '):
            html_lines.append(f'<h4>{stripped[5:]}</h4>')
            continue

        # Blockquotes / Alerts
        if stripped.startswith('> [!IMPORTANT]'):
            html_lines.append('<div class="alert alert-important"><strong>CRITICAL DISCLOSURE:</strong>')
            continue
        elif stripped.startswith('> '):
            content = stripped[2:]
            html_lines.append(f'<p class="blockquote-content">{content}</p>')
            continue
        elif line.startswith('>'):
            continue

        # Horizontal Rule
        if stripped in ['---', '***', '___']:
            html_lines.append('<hr/>')
            continue

        # Tables
        if stripped.startswith('|'):
            cells = [c.strip() for c in stripped.strip('|').split('|')]
            if all(re.match(r'^:?-+:?$', c) for c in cells):
                # separator line
                continue
            if not in_table:
                html_lines.append('<table><thead><tr>')
                for c in cells:
                    html_lines.append(f'<th>{c}</th>')
                html_lines.append('</tr></thead><tbody>')
                in_table = True
            else:
                html_lines.append('<tr>')
                for c in cells:
                    html_lines.append(f'<td>{c}</td>')
                html_lines.append('</tr>')
            continue

        # Lists
        if stripped.startswith('- ') or stripped.startswith('* '):
            if not in_ul:
                html_lines.append('<ul>')
                in_ul = True
            item_text = stripped[2:]
            html_lines.append(f'<li>{item_text}</li>')
            continue

        if re.match(r'^\d+\.\s', stripped):
            if not in_ol:
                html_lines.append('<ol>')
                in_ol = True
            item_text = re.sub(r'^\d+\.\s', '', stripped)
            html_lines.append(f'<li>{item_text}</li>')
            continue

        if stripped == '':
            html_lines.append('<br/>')
            continue

        # Images
        if re.search(r'!\[(.*?)\]\((.*?)\)', stripped):
            def img_repl(m):
                alt = m.group(1)
                src = m.group(2)
                if not src.startswith("http") and not src.startswith("file:"):
                    src = f"file:///D:/DevOps/enterprise-aks-dr/{src.lstrip('/')}"
                return f'<div style="text-align:center; margin:12px 0;"><img src="{src}" style="max-width:90%; border:1px solid #ccc; border-radius:6px; box-shadow:0 1px 4px rgba(0,0,0,0.1);"/><br/><em style="font-size:8.5pt; color:#666;">{alt}</em></div>'
            p_text = re.sub(r'!\[(.*?)\]\((.*?)\)', img_repl, stripped)
            html_lines.append(p_text)
            continue

        # Paragraph
        p_text = stripped
        # inline bold
        p_text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', p_text)
        # inline code
        p_text = re.sub(r'`(.+?)`', r'<code>\1</code>', p_text)
        # inline links
        p_text = re.sub(r'\[(.+?)\]\((.+?)\)', r'<a href="\2">\1</a>', p_text)
        html_lines.append(f'<p>{p_text}</p>')

    if in_table:
        html_lines.append('</tbody></table>')
    if in_ul:
        html_lines.append('</ul>')
    if in_ol:
        html_lines.append('</ol>')
    if in_code:
        html_lines.append('</code></pre>')

    return '\n'.join(html_lines)

def build_pdf():
    base_dir = os.path.dirname(os.path.dirname(__file__))
    md_path = os.path.join(base_dir, "FINAL_PROJECT_DOCUMENTATION.md")
    html_out = os.path.join(base_dir, "docs", "FINAL_PROJECT_DOCUMENTATION.html")
    pdf_out = os.path.join(base_dir, "FINAL_PROJECT_DOCUMENTATION.pdf")

    with open(md_path, "r", encoding="utf-8") as f:
        md_text = f.read()

    body_html = markdown_to_html(md_text)

    full_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Enterprise AKS Disaster Recovery Documentation</title>
  <style>
    @page {{
      margin: 1.5cm;
      size: A4;
    }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
      line-height: 1.5;
      color: #24292e;
      margin: 0;
      padding: 0;
      font-size: 10pt;
    }}
    h1 {{
      color: #0078D4;
      font-size: 20pt;
      border-bottom: 2px solid #0078D4;
      padding-bottom: 8px;
      margin-top: 0;
    }}
    h2 {{
      color: #0078D4;
      font-size: 14pt;
      border-bottom: 1px solid #e1e4e8;
      padding-bottom: 6px;
      margin-top: 20px;
    }}
    h3 {{
      color: #1a202c;
      font-size: 11pt;
      margin-top: 14px;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
      font-size: 9pt;
      page-break-inside: avoid;
    }}
    th {{
      background-color: #0078D4;
      color: white;
      text-align: left;
      padding: 6px 8px;
      font-weight: bold;
    }}
    td {{
      border: 1px solid #e1e4e8;
      padding: 5px 8px;
    }}
    tr:nth-child(even) td {{
      background-color: #f8f9fa;
    }}
    code {{
      font-family: Consolas, "Courier New", monospace;
      background: #f3f4f6;
      padding: 2px 4px;
      border-radius: 4px;
      font-size: 8.5pt;
      color: #d63384;
    }}
    pre {{
      background: #f6f8fa;
      padding: 10px;
      border-radius: 6px;
      border: 1px solid #e1e4e8;
      overflow-x: auto;
      font-size: 8pt;
      page-break-inside: avoid;
    }}
    pre code {{
      color: #24292e;
      background: none;
      padding: 0;
    }}
    .alert-important {{
      background: #e6f2fb;
      border-left: 4px solid #0078D4;
      padding: 10px 14px;
      margin: 14px 0;
      border-radius: 0 4px 4px 0;
    }}
    hr {{
      border: 0;
      border-top: 1px solid #e1e4e8;
      margin: 16px 0;
    }}
    ul, ol {{
      padding-left: 20px;
      margin: 6px 0;
    }}
    li {{
      margin-bottom: 4px;
    }}
  </style>
</head>
<body>
{body_html}
</body>
</html>
"""

    with open(html_out, "w", encoding="utf-8") as f:
        f.write(full_html)
    print(f"[+] Wrote HTML template: {html_out}")

    # Edge print-to-pdf
    edge_exe = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    cmd = [
        edge_exe,
        "--headless",
        "--disable-gpu",
        f"--print-to-pdf={pdf_out}",
        html_out
    ]
    print(f"[*] Running Edge PDF generation: {' '.join(cmd)}")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if os.path.exists(pdf_out):
        print(f"[+] Successfully generated PDF: {pdf_out} ({os.path.getsize(pdf_out)} bytes)")
    else:
        print(f"[-] Failed to generate PDF. Edge stderr: {res.stderr}")

if __name__ == "__main__":
    build_pdf()
