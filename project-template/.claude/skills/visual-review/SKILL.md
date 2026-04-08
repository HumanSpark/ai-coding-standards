---
name: visual-review
description: Take Playwright screenshots of a local dev site and visually review the rendered output. Use after any HTML, CSS, template, or frontend change to verify it looks correct before shipping.
allowed-tools: Read, Edit, Bash, Glob, Grep
---

# Visual Review

Screenshot a local dev site with Playwright, then visually inspect the output.
Code review alone is insufficient for visual work - always verify rendering.

## When to Use

- After any HTML, CSS, or template change
- After content changes that affect layout (new sections, rewritten copy, removed elements)
- Before claiming frontend work is done
- When the user asks to "check how it looks" or "review the site"

## Dependencies

Requires a Python environment with **Playwright** (screenshots) and optionally
**Pillow** (contact sheets / comparisons). If Pillow is unavailable, use
individual screenshots instead.

**Find or create a usable Python:**

1. **Check SparkForge venv** (if available - typically has both):
   ```bash
   ~/sparkforge/venv/bin/python3 -c "from playwright.sync_api import sync_playwright; from PIL import Image; print('OK')"
   ```

2. **Check project venv** (if the project has one):
   ```bash
   ./venv/bin/python3 -c "from playwright.sync_api import sync_playwright; print('OK')"
   ```

3. **Create a dedicated venv** (if neither exists):
   ```bash
   python3 -m venv ~/.local/share/visual-review/venv && \
   ~/.local/share/visual-review/venv/bin/pip install playwright Pillow && \
   ~/.local/share/visual-review/venv/bin/python3 -m playwright install chromium
   ```

Once resolved, use that Python path as `PYTHON` in all snippets below.

## Setup

Before taking screenshots, determine three values:

1. **PYTHON** - path to a Python with Playwright (see Dependencies above)
2. **SITE_URL** - check project memory, CLAUDE.md, or ask. Common patterns:
   `https://localhost`, `http://localhost:8000`, `http://localhost:3000`
3. **OUTPUT_DIR** - use `output/` in the project root. Create if missing.

## SSL / Self-Signed Certificates

If the dev server uses HTTPS with a self-signed cert (common with
nginx/WordPress), add these flags or Playwright will fail silently or hang:

```python
browser = p.chromium.launch(args=['--ignore-certificate-errors'])
page = browser.new_page(viewport={'width': 1440, 'height': 900}, ignore_https_errors=True)
```

## Screenshot Patterns

### Single page - full + fold

```python
PYTHON -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    browser = p.chromium.launch(args=['--ignore-certificate-errors'])
    page = browser.new_page(viewport={'width': 1440, 'height': 900}, ignore_https_errors=True)
    page.goto('SITE_URL', wait_until='networkidle', timeout=15000)
    page.screenshot(path='OUTPUT_DIR/page-full.png', full_page=True)
    page.screenshot(path='OUTPUT_DIR/page-fold.png', full_page=False)
    page.close()
    browser.close()
"
```

### Multi-page batch

```python
PYTHON -c "
from playwright.sync_api import sync_playwright
pages = {
    'homepage': 'SITE_URL/',
    'about': 'SITE_URL/about/',
    # Add project-specific pages here
}
with sync_playwright() as p:
    browser = p.chromium.launch(args=['--ignore-certificate-errors'])
    for name, url in pages.items():
        page = browser.new_page(viewport={'width': 1440, 'height': 900}, ignore_https_errors=True)
        page.goto(url, wait_until='networkidle', timeout=15000)
        page.screenshot(path=f'OUTPUT_DIR/review-{name}.png', full_page=True)
        page.close()
    browser.close()
"
```

### Section closeup

```python
page.evaluate('window.scrollTo(0, PIXEL_OFFSET)')
page.wait_for_timeout(500)
page.screenshot(path='OUTPUT_DIR/section-name.png',
                clip={'x': 0, 'y': 0, 'width': 1440, 'height': 900})
```

### Mobile viewport

```python
page = browser.new_page(viewport={'width': 375, 'height': 812}, ignore_https_errors=True)
```

## Contact Sheets (Batch Review)

When reviewing 6+ pages, composite multiple screenshots into a single grid
image to keep context manageable. Requires Pillow.

**When to use:** Batch reviews, cross-page consistency checks.
**When NOT to use:** Single page review or debugging a specific section.

```python
PYTHON -c "
from playwright.sync_api import sync_playwright
from PIL import Image
from pathlib import Path

SITE_URL = 'SITE_URL'
OUTPUT_DIR = Path('OUTPUT_DIR')
OUTPUT_DIR.mkdir(exist_ok=True)

pages = {
    'homepage': '/',
    'about': '/about/',
    'services': '/services/',
    'blog': '/blog/',
}

# 1. Screenshot each page (fold only for grid)
page_images = []
with sync_playwright() as p:
    browser = p.chromium.launch(args=['--ignore-certificate-errors'])
    for name, path in pages.items():
        pg = browser.new_page(viewport={'width': 1440, 'height': 900}, ignore_https_errors=True)
        pg.goto(f'{SITE_URL}{path}', wait_until='networkidle', timeout=15000)
        img_path = OUTPUT_DIR / f'page-{name}.png'
        pg.screenshot(path=str(img_path), full_page=False)
        page_images.append(img_path)
        pg.close()
    browser.close()

# 2. Composite into 3x2 grid (max 1900px - safety margin below 2000px limit)
cols, rows, gap = 3, 2, 10
sample = Image.open(page_images[0])
pw, ph = sample.size
sample.close()
cell_w = (1900 - (cols + 1) * gap) // cols
cell_h = int(cell_w * (ph / pw))
canvas_w = cols * cell_w + (cols + 1) * gap
canvas_h = rows * cell_h + (rows + 1) * gap
if canvas_h > 1900:
    cell_h = (1900 - (rows + 1) * gap) // rows
    cell_w = int(cell_h / (ph / pw))
    canvas_w = cols * cell_w + (cols + 1) * gap
    canvas_h = rows * cell_h + (rows + 1) * gap

per_sheet = cols * rows
for i in range(0, len(page_images), per_sheet):
    batch = page_images[i:i + per_sheet]
    canvas = Image.new('RGB', (canvas_w, canvas_h), (255, 255, 255))
    for j, img_path in enumerate(batch):
        x = gap + (j % cols) * (cell_w + gap)
        y = gap + (j // cols) * (cell_h + gap)
        img = Image.open(img_path).resize((cell_w, cell_h), Image.LANCZOS)
        canvas.paste(img, (x, y))
        img.close()
    canvas.save(str(OUTPUT_DIR / f'contact-sheet-{i // per_sheet + 1}.png'), optimize=True)

for p in page_images:
    p.unlink()
print('Done')
"
```

Read the contact sheet(s) with the Read tool. Each sheet shows up to 6 pages
in a 3x2 grid. Check for cross-page consistency in headers, footers, and
component styles.

## Before/After Comparison

Screenshot the same pages before and after a change, then composite side by side:

```python
from PIL import Image
before = Image.open('OUTPUT_DIR/before.png')
after = Image.open('OUTPUT_DIR/after.png')
gap = 10
# Resize each half so combined image stays under 1900px
half_w = (1900 - gap) // 2
for img in [before, after]:
    img.thumbnail((half_w, 1900), Image.LANCZOS)
w = before.width + after.width + gap
h = max(before.height, after.height)
canvas = Image.new('RGB', (w, h), (255, 255, 255))
canvas.paste(before, (0, 0))
canvas.paste(after, (before.width + gap, 0))
canvas.save('OUTPUT_DIR/comparison.png')
```

## Review Process

1. **Take screenshots** of all changed pages (full-page at minimum)
2. **Read each screenshot** with the Read tool to visually inspect
3. **For batch reviews** (6+ pages), use contact sheets instead of individual screenshots
4. **Check for issues:**
   - Text overlapping or cut off
   - Broken layout / unexpected stacking
   - Missing elements or blank sections
   - Colour / contrast problems
   - Spacing inconsistencies
   - Mobile breakpoint issues (if applicable)
   - Cross-page inconsistencies (headers, footers, card styles, typography)
5. **If issues found:** fix and re-screenshot until clean
6. **If clean:** report to user with a brief summary of what was verified

## Design Evaluation Dimensions

For thorough reviews (not quick sanity checks), evaluate against:

- **Typography** - hierarchy, size, weight, readability
- **Spacing** - section padding, element gaps, breathing room
- **Visual hierarchy** - what draws the eye first, is the flow logical
- **Brand consistency** - colours, tone, component style
- **Colour variety** - enough contrast between sections, not monotone
- **Temperature rhythm** - alternation between warm/cool, light/dark sections
- **Cross-page consistency** - repeated elements look identical everywhere

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Screenshot is blank | Add `wait_until='networkidle'` and increase timeout |
| SSL error / connection refused | Add `--ignore-certificate-errors` and `ignore_https_errors=True` |
| Port 80 returns 404 | Server may only serve on 443. Switch to `https://` |
| Timeout on `goto()` | Increase `timeout=30000`. Check server is running. |
| Fonts differ from browser | Playwright uses its own Chromium. Minor differences expected. |
| Pillow not available | Install in SparkForge or project venv, or use individual screenshots |

## Image Size Limit — CRITICAL

**NEVER create or read any image >= 2000px on either dimension.** Images at or
above 2000px break the conversation context and kill the session. This applies
to screenshots, contact sheets, PDF page extractions, before/after comparisons,
and any other image passed to the Read tool.

Before reading any generated image, verify its dimensions. When generating:
- Viewport screenshots: keep width <= 1440, height <= 1800
- Contact sheets: cap grid to 1900×1900 max
- PDF page PNGs: render at a DPI/scale that keeps the longest side under 2000px
- Before/after composites: resize each half so the combined image stays under 2000px

If an image exceeds the limit, resize it with Pillow before reading:
```python
from PIL import Image
img = Image.open('OUTPUT_DIR/page.png')
img.thumbnail((1900, 1900), Image.LANCZOS)
img.save('OUTPUT_DIR/page.png')
```

## Anti-Patterns

- Do NOT create or read images >= 2000px on any dimension - breaks the conversation
- Do NOT skip visual review for "small" CSS changes - they often have knock-on effects
- Do NOT review only the changed page - check adjacent pages for consistency
- Do NOT use full-page screenshots in contact sheets - fold-only keeps the grid readable
- Do NOT take screenshots without `wait_until='networkidle'` - partial renders mislead
- Do NOT forget SSL flags for HTTPS dev servers - Playwright fails silently
