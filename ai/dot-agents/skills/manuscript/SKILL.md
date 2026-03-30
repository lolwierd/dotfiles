---
name: manuscript
description: "ONLY INVOKE IF I EXPLICITLY TELL YOU TO INVOKE THIS. Build in the Manuscript visual language — a design system that presents digital content through the grammar of Renaissance natural philosophy treatises, woodblock-printed codices, and scholarly manuscripts. Use when the user asks for 'manuscript design', 'treatise style', 'codex aesthetic', or anything that should feel like a printed document from a world where code and scholarship coexist."
---

# The Manuscript Language

A visual language for presenting digital content as if it were typeset on handmade paper, printed from woodblocks, and annotated by a scholar who couldn't stop writing in the margins.

This is not a retro filter or a period costume. It is a way of asserting that content has **weight**, **history**, and **physical presence** in a medium (the screen) that usually has none. When you build in Manuscript, you are saying: *this was worth printing.*

## Origin

The language emerges from the observation that the visual grammar of pre-modern printed texts — treatises on natural philosophy, woodblock-printed codices, annotated manuscripts — carries an inherent authority that digital media lacks. When GLSL code sits alongside the geometric forms it produces on a page that looks like it was pulled from a sixteenth-century treatise, something changes. The code stops being "a snippet" and becomes a theorem. The ornamental friezes that separate sections aren't decoration — they're the same mathematics rendered as border art.

The key insight: **the form claims the content is serious**. By presenting code (or any subject) through the apparatus of scholarship — section numbers, figure labels, ornamental initials, margin notes, horizontal rules — you give it the gravity of a theorem. You say: this is knowledge, not content.

## The Essence (What It Feels Like)

**A page torn from a book that shouldn't exist.** A medieval optics text that contains fragment shaders. A natural philosophy treatise on Pokémon types. A cartographic survey of a video game world. The subject is contemporary or fictional; the form insists it is ancient and serious. That tension — between the gravity of the presentation and the nature of the content — is the soul of Manuscript.

It feels like:
- Opening a leather-bound volume in the restricted section of a library
- Finding an annotated proof in a dead mathematician's desk
- A page where the ink has weight, the paper has tooth, and the margins are full of someone's handwriting
- The quiet confidence of something that doesn't need to shout because it's *printed*

It does NOT feel like:
- A "vintage" or "retro" Photoshop filter
- A fantasy RPG prop
- A generic "old-timey" aesthetic
- Parchment-and-wax-seal theming for the sake of vibes

## The Grammar (What It's Made Of)

### 1. Paper as Ground Truth

The background is not white. It is **paper** — and paper has texture.

- **Color**: A muted, slightly cool warm grey. Not cream, not beige — the color of handmade cotton/linen stock. Around `#ddd8cf` to `#dfd9d0`. Cooler and greyer than most "parchment" defaults.
- **Grain (optional, only if convincing)**: If you can source or generate a convincing paper texture, use it — a real scanned paper image (grayscale, overlaid at very low opacity ~4-12%, `mix-blend-mode: multiply`) is far better than procedural noise. **Do NOT generate per-pixel random noise via canvas** — this reads as TV static, not paper. Real paper has low-frequency tonal variation with sparse directional fibers, not high-frequency uncorrelated randomness. If you cannot make the grain look convincingly physical, **omit it entirely** — a clean flat paper tone is always better than bad fake texture.
- **Mottling**: Subtle, non-uniform color variation across the page — gentle radial gradients at different positions creating the natural unevenness of handmade paper. This prevents the background from feeling flat/digital. Keep it very subtle — the mottling should be barely perceptible, not competing with the content.
- **Vignette**: A very soft darkening at the edges, as if the page is lit from the center. Barely perceptible, but it gives depth.

The paper is the most important element. If the paper feels digital, nothing else matters. **An honest flat tone with gentle mottling is always preferable to a dishonest texture.**

### 2. Ink, Not Pixels

Text color is not `#000000`. It is **ink** — a warm, deep brown-black (`#151210` to `#1c1917`). On heavy text (titles, section numbers, drop caps), apply a very subtle `text-shadow` to simulate slight ink spread/bleed: `0 0 0.5px rgba(21,18,16,0.3)`. This tiny imperfection makes type feel *printed* rather than *rendered*.

### 3. Serif Prose as the Native Voice

The body text is in a **proper book serif** — warm, readable, with the cadence of scholarly writing. This is non-negotiable. Manuscript does not use monospace for body text. Monospace is reserved strictly for code.

Recommended: **Cormorant Garamond** (Google Fonts) — a display Garamond with sharp contrast and elegant hairlines that works beautifully at body sizes too.

- Body: 400 weight, regular and italic
- Headings: 600–700 weight
- Line height: 1.85–1.9 (generous, airy, like a well-set book page)
- Text indent on non-first paragraphs: `1.5em` (the book convention)

### 4. Widely Letterspaced Titles

Section titles and the main title are set in **uppercase serif with extreme letter-spacing** (0.2em–0.3em). Each letter breathes. This signals formality and gravitas — the typographic equivalent of a title page in a printed volume.

Subtitles are **lowercase italic**, also letterspaced (0.08em–0.12em), functioning as thesis statements: *"being a treatise on the divine mathematics of illumination"*.

### 5. Ornamental Friezes

Full-width horizontal bands of **dense geometric pattern**, drawn in ink on a dark ground. These are the woodblock borders of the treatise — they separate major sections and announce transitions.

Because in Manuscript the code IS the art, friezes should be **generated from signed distance functions (SDFs)**. Mathematical functions evaluate the distance from each pixel to geometric shapes; the boundaries between inside and outside become the paper-colored channels carved into the dark ink mass. The ornament emerges from mathematics, not from hand-placed vertices.

#### What's Fixed vs. What Varies

**Fixed for every Manuscript design** (part of the language grammar):
- Dark ink ground with paper-colored SDF channels (the woodblock logic)
- Band architecture: outer rules → guard lines → central motif zone
- Generated from SDF functions, not hand-placed SVG or drawing commands
- Two frieze weights (tall for major transitions, thin for section breaks)
- Accent color only at intersection nodes, never dominant
- Per-pixel evaluation of a tile, then tiled natively via `createPattern`

**Varies per design** (the creative decision for each project):
- **Which SDF primitives** compose the pattern. The 8-pointed star lattice used on the reference site is ONE example. A site about botany might use petal-curve SDFs. A cartographic project might use compass rose geometry. A music site might derive friezes from waveform SDFs. **The motif should connect to the subject matter.** The ornament isn't arbitrary decoration; it's the mathematical content of the page, rendered as border art.
- **The number and composition of layers.** More layers = denser, more intricate. Fewer layers = cleaner, more architectural. Match the density to the content's character.
- **Tile size and spacing.** Larger tiles = fewer repeats, more monument-like. Smaller tiles = denser tiling, more textile-like.
- **The thin frieze pattern.** It should be a DIFFERENT composition from the tall frieze, not a scaled-down version. But it should share some mathematical DNA — derived from the same family of primitives or the same base construction.

**The goal:** each Manuscript design should have friezes that feel like they belong to *that specific document* — as if a scholar-printer carved woodblocks specifically for this treatise's subject. The SDF approach makes this natural: change the functions, change the ornament.

#### The SDF Approach

A signed distance function returns the shortest distance from a point to the boundary of a shape (negative inside, positive outside). By evaluating SDFs per-pixel and drawing paper-colored channels where |sdf| is small, you produce intricate geometric patterns that are:

- **Mathematically precise** — the geometry comes from real constructions (unions, intersections, rotations), not approximate drawing commands
- **Infinitely layerable** — each SDF layer is independent; you compose them with `min()` (union) and `max()` (intersection) 
- **Resolution-independent** — render the tile at any DPR by simply evaluating more pixels
- **Self-documenting** — the code that generates the ornament can be displayed alongside it as a figure

#### SDF Primitive Library

These are the building blocks. Mix and compose them to create the motif for each design:

- `sdCircle(p, r)` — circle
- `sdBox(p, b)` — axis-aligned rectangle
- `sdSegment(p, a, b)` — line segment
- `min(d1, d2)` — union (combine shapes)
- `max(d1, d2)` — intersection (overlap of shapes)
- `-sdf` — inversion (inside becomes outside)
- `fmod(p, cell)` — tiling repetition
- `mat2(cos, sin, -sin, cos) * p` — rotation

From these primitives, you can derive any geometric motif:

| Construction | Formula | Use case |
|---|---|---|
| 8-pointed star | `min(sdBox(p,s), sdBox(rot45(p),s))` | Islamic geometric tiling |
| Regular octagon | `max(sdBox(p,s), sdBox(rot45(p),s))` | Concentric rings, frames |
| N-pointed star | `min(sdBox(p,s), sdBox(rotN(p),s))` for various N | Varied star lattices |
| Rose curve | `length(p) - r*cos(n*atan2(y,x))` | Floral/petal motifs |
| Diamond/rhombus | `abs(x) + abs(y) - r` (L1 norm) | Corner ornaments, chain links |
| Wave ribbon | `abs(y - A*sin(ωx))` | Guilloche, interlace patterns |
| Gear/cog | `sdCircle - amplitude*cos(n*angle)` | Mechanical/technical subjects |
| Trefoil/quatrefoil | `sdCircle` unions at rotated offsets | Botanical, Gothic motifs |

#### Rendering Pipeline

1. **Choose your motif** based on the project's subject matter
2. **Compose SDF layers** — primary outline, secondary detail, tertiary accents
3. **Render a single tile** by evaluating the SDF per-pixel
4. **Create a canvas pattern** from the tile using `ctx.createPattern(tile, 'repeat')`
5. **Fill the motif zone** of each frieze with the tiled pattern
6. **Draw band architecture** (border rules, guard lines) as standard canvas lines

This is efficient — the SDF evaluation happens once per tile, and the browser's native pattern compositor handles the tiling.

#### Per-Pixel Shading

Each pixel starts as dark ink. Paper-colored channels are drawn where `|sdf| < halfWidth`, using smoothstep for anti-aliasing. Layers are composited with alpha blending at varying opacities to create depth:

```
// For each SDF layer:
distance = abs(sdf) - halfWidth
opacity = smoothstep(0.5, -0.5, distance) * layerOpacity
color = lerp(currentColor, PAPER, opacity)
```

Heavier layers (primary outline) use higher opacity (~0.7) and wider channels (~1.0px halfWidth). Detail layers use lower opacity (~0.2–0.3) and thinner channels. This creates the visual hierarchy of a woodblock print: bold primary carving with fine secondary detail.

#### Band Architecture

Every frieze has structural hierarchy beyond the motif:
- **Outer border rules** (paper-colored, ~0.8px, ~70% opacity)
- **Inner guard lines** (thinner, ~0.3px, ~30% opacity, inset ~3px)
- **Central motif zone** (tiled SDF pattern)

This makes each frieze feel like a designed border strip, not a pattern in a rectangle.

#### What NOT to Do

- ❌ **Do NOT use per-pixel random noise** as a "woodblock" effect. The mathematical precision IS the aesthetic.
- ❌ **Do NOT draw parametric doodles** (spirographs, random curves) and call them friezes. The geometry should come from intentional SDF constructions.
- ❌ **Do NOT use the same pattern at both sizes.** Design separate SDF compositions for tall and thin friezes.
- ❌ **Do NOT reuse the exact same star-lattice motif on every project.** The reference site's 8-pointed star is an example, not a template. Each design should derive its own motif from the subject matter.

#### Accent Color

The burnt umber accent (`#6b260b`) appears as small filled dots at pattern intersections and crossing nodes — never as the dominant color. This evokes the costly second pass of ink in a hand-printed text.

### 6. Drop Caps in Woodcut Frames

The first letter of each major section sits inside a **square frame** with ornamental corner decoration — like an illuminated manuscript initial rendered as a woodblock print.

- Dark ink background, paper-colored letter
- Corner vine/floral ornaments at reduced opacity (0.2–0.3)
- Small decorative dots at the cardinal points
- Pixel noise overlaid for printed texture
- Size: ~58px square

The drop cap is the signature move. It says: *a human composed this page*.

### 7. Margin Notes

Small italic text in the **right margin**, providing scholarly commentary, cross-references, citations, or wry asides. This is the most characterful element of the language.

- Font: body serif in italic, ~0.72rem
- Color: mid-tone (`#767066`)
- Right-aligned
- Positioned alongside the relevant passage

Margin notes do several things at once: they add information density without cluttering the main text, they create the feeling of an annotated document, and they allow a secondary voice (the scholar's personal observations) to coexist with the primary text.

On mobile/narrow screens, margin notes can be hidden (the main text should be self-sufficient) or folded inline as parentheticals.

### 8. The Text + Margin Layout

The page uses a **two-column grid**: a main text column (~38rem) and a margin column (~11rem) on the right, with a gap (~3rem) between them. This is the defining layout of a scholarly printed page.

```
┌─────────────────────────────────────────┐
│  [text column, ~65%]  │ gap │ [margin]  │
│  Body prose flows      │     │ notes,   │
│  here in serif at      │     │ citations│
│  comfortable width     │     │ asides   │
└─────────────────────────────────────────┘
```

### 9. Section Numbering

Sections are numbered with the **§ symbol** (§1, §2.1, §3) in a large serif, positioned before or above the section title. This is the folio convention — it makes the document feel structured and navigable, like a real text with a table of contents.

### 10. Code as Formal Proof

When code appears, it sits **below a thin horizontal rule**, with **line numbers** on the left, in monospace at a smaller size than body text. It is not a "code block" in a README — it is a **mathematical demonstration**, like the geometric construction that proves a theorem.

- Font: JetBrains Mono or similar, 300 weight, ~0.78rem
- Line numbers in a muted color, non-selectable
- Comments in italic mid-tone
- Keywords in regular weight ink
- Preceded and followed by horizontal rules

### 11. Figure Labels

Diagrams and illustrations are labeled with italic figure captions: *fig. 1 — Diagrammatic projection of the known waters*. The italic "fig." prefix is the academic convention. Figures are centered in the text column.

### 12. Horizontal Rules

Thin (`1px`), in a muted color (`var(--mid-light)`), at reduced opacity. They separate thoughts and delineate code from prose. They are the paragraph marks of a printed page — structural, not decorative.

### 13. The Printer's Mark

A colophon at the end of the document, featuring a **printer's mark** — a small geometric device that serves as the maker's signature. The default Manuscript mark is a four-petal glyph: two elongated horizontal petals, two shorter vertical petals, with dots at the tips. But like the frieze motif, the printer's mark can be adapted per design — derived from the same SDF family as the friezes, or from the subject matter of the document. It is the stamp that says: *this was composed with intention*.

## Color System

| Token | Value | Purpose |
|-------|-------|---------|
| `--paper` | `#ddd8cf` | Background — handmade linen stock |
| `--paper-light` | `#e4dfd7` | Lighter paper variant |
| `--paper-dark` | `#ccc6bb` | Darker paper variant |
| `--ink` | `#151210` | Primary text — warm brown-black |
| `--ink-soft` | `#262220` | Secondary text, code |
| `--mid` | `#767066` | Margin notes, labels, comments |
| `--mid-light` | `#a9a198` | Rules, separators, line numbers |
| `--accent` | `#6b260b` | Burnt umber — friezes, marks, sparing emphasis |

The palette is almost monochromatic. The accent appears only in the friezes and the printer's mark — a single color that says *this was hand-printed with a second pass of ink*.

## Voice & Tone

The writing voice in Manuscript is that of **a scholar who is precise and wondering in equal measure**. Not dry, not cold — but never casual. Sentences have the structure of formal prose. The author uses "it is observed that" and "the mechanism remains unknown" but also, in the margins, writes "the author declines to offer a rational explanation."

Think: the way Robert Hooke described cells in *Micrographia*. The way Darwin described barnacles. Clinical attention to detail, married to quiet awe at what's being described.

## What This Is NOT

- ❌ **A period costume.** Don't fake ye olde English or use blackletter fonts or add wax seal clip art. The language is contemporary — it borrows the *structure* of old printed texts, not their surface decorations.
- ❌ **Dark mode.** Manuscript is a light-background language. The paper IS the design. Dark mode would negate the entire point.
- ❌ **A theme you apply.** It's a way of *thinking about content* — that it deserves the same care as a printed book. If you're just wrapping a standard web page in paper texture, you've missed the point.
- ❌ **Maximalist.** The page should breathe. Wide margins, generous line height, ample space between sections. Density comes from the *content* (margin notes, code, diagrams), not from cramming elements together.

## When to Use

Use Manuscript when building:
- Documentation or reference sites that should feel authoritative
- Fan wikis or compendiums that recontextualise their subject as scholarship
- Portfolio pieces or case studies that want gravitas
- Long-form articles or essays
- Any project where the user says "manuscript", "treatise", "codex", or "printed-page aesthetic"

## Checklist

Before delivering a Manuscript design, verify:

- [ ] Background feels like paper — either convincing physical grain (from a real scan) or an honest flat tone with gentle mottling. No per-pixel canvas noise.
- [ ] Background has subtle mottling/color variation — not perfectly uniform
- [ ] Text is in a proper book serif, not monospace (unless it's code)
- [ ] Titles are widely letterspaced uppercase
- [ ] At least one ornamental frieze is present — SDF-generated with band architecture (rules, guard lines, motif zone)
- [ ] Friezes feel like carved woodblock: dark ink mass with paper-colored SDF channels, not thin strokes or parametric doodles
- [ ] Drop caps are present at section openings
- [ ] Margin notes exist and add a secondary voice
- [ ] The layout has a text column + margin column (on desktop)
- [ ] Code blocks have line numbers and sit below horizontal rules
- [ ] Heavy text has subtle ink-bleed shadow
- [ ] A printer's mark / colophon appears at the end
- [ ] The overall feel is *printed*, not *rendered*
