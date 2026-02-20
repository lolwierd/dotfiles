---
name: frontend-design
description: "Design and implement distinctive, production-ready frontend interfaces with strong aesthetic direction. Use when asked to create or restyle web pages, components, or applications (HTML/CSS/JS, React, Vue, etc.)."
---

# Frontend Design Skill

Design and build frontend interfaces that feel like **a poet's cluttered desk** — warm, layered, full of meaning, where every object earned its place. The user values **intentionality above all else**. No element exists without a reason. No choice is made because "that's what everyone does."

This skill is about **thinking deeply, then executing with craft**.

## The User's Design Philosophy

Internalize these principles. They override any generic design instinct:

- **Every choice must earn its place.** If you can't articulate *why* this color, *why* this font, *why* this layout — it doesn't belong. The user will notice thoughtless defaults instantly.
- **Originality over trend.** The user explicitly dislikes when sites copy popular aesthetics (Linear was called out by name). Do not replicate trending SaaS styles, even if they "look good." Think from first principles based on what the project *needs*.
- **Minimal but info-rich.** This sounds contradictory but it's the core tension that defines the user's taste. They want *density with clarity* — lots of information presented through clever architecture, progressive disclosure, unique representations, and smart hierarchy so nothing feels overwhelming. Think: a well-organized bookshelf vs. a pile of books.
- **Quiet depth, not loud flash.** Designs should reward attention. The surface is approachable; the details are rich. Layers reveal themselves over time. Don't shout — have something worth saying and let people lean in.
- **A bit of attitude.** Not sterile, not corporate-safe. The design can have personality, grit, edge, a wink. Think Seedhe Maut — there's rawness *and* craft coexisting. The "introspective maiden" has opinions.
- **Both product AND experience.** It should be polished enough to *use* well, and interesting enough to *linger on*. Never sacrifice usability for aesthetics, but never sacrifice soul for usability either.
- **Context dictates everything.** There are no fixed rules on warm vs. cool, serif vs. sans, caps vs. lowercase, geometric vs. organic. The project's purpose, audience, and mood determine the right answer. Always reason from context, never from preset preferences.

## Reference Points

The user admires **ampcode.com** — but for its *principles*, not its pixels. What makes ampcode good:
- Confident typography that carries the personality (large display type, structural labels)
- Warm palette with depth (not cold, not sterile)
- Editorial layout thinking (content dictates its own shape)
- Mixing playful and serious without losing credibility

**⚠️ CRITICAL: ampcode is ONE reference, not THE template.** These are patterns that worked for ampcode's specific context (a developer tool marketing page). They are NOT universal defaults. Do NOT fall into these traps:
- Reaching for serif + monospace on every project. A recipe app, a music player, a weather dashboard — these might want completely different type systems. Ask *what does THIS project's voice sound like?*
- Defaulting to warm dark earthy palettes every time. A pomodoro timer could be stark and minimal. A music page could be vibrant and saturated. A 404 could be cold and eerie. Let the project's mood dictate the color, not a memorized palette.
- Using uppercase mono labels + left border accents as structural defaults on everything. These are specific tools that suit specific contexts — not a universal information architecture.
- Making every page feel like a literary document. Some things should feel like tools. Some should feel like spaces. Some should feel like events.

**The real lesson from ampcode:** they made design choices that are *specific to who they are and what they're selling*. That specificity is what makes it good. Copy the specificity-of-thinking, not the specific choices.

## When to Use

Use this skill when the user wants to:
- Create a new web page, landing page, dashboard, or app UI
- Design or redesign frontend components or screens
- Improve typography, layout, color, motion, or overall visual polish
- Convert a concept or brief into a high-fidelity, coded interface

## Before Writing Code

### 1. Understand the Project

Identify (ask if unclear, but keep it to 2–3 sharp questions max):
- **What is this thing and who is it for?** Purpose, audience, context.
- **What mood/feeling should it evoke?** Not "modern and clean" — something specific.
- **Any hard constraints?** Framework, existing design system, accessibility needs, content requirements.

### 2. Think From First Principles

Do NOT reach for a pre-baked aesthetic ("let's go brutalist" / "let's do glassmorphism"). Instead, reason through:

- **What is the soul of this project?** A finance dashboard has different DNA than a poetry site. Start there.
- **What would be the *unexpected but right* choice?** The obvious choice is probably what everyone else would do. Push past it. What's the choice that makes someone pause and think "oh, that's interesting"?
- **What's the one thing someone should remember?** Every great design has a hook — a single element or idea that sticks. Find it before you start coding.

Then define your system:
1. **Concept** — one sentence that captures the *why* behind the visual direction (not just "dark and moody" but *why* dark and moody serves this project)
2. **The hook** — the memorable thing, the detail people notice
3. **Typography** — chosen to match the project's voice, not because the font is trendy
4. **Color** — derived from the concept, not a random palette generator
5. **Information architecture** — how density and clarity coexist in this specific design
6. **Motion** — subtle, meaningful, rewarding (the user loves subtle animations)

### 3. The "Would Everyone Else Do This?" Test

Before finalizing any major design decision, ask: *"If 10 other developers got this same brief, would 7 of them make this same choice?"* If yes, dig deeper. Find the choice that's still *right* for the project but isn't the default answer.

This doesn't mean being weird for weird's sake. It means thinking harder.

## Implementation

- **Working code that runs as-is.** HTML/CSS/JS or whatever framework is appropriate.
- **Semantic & accessible.** Proper headings, labels, focus states, keyboard navigation. Accessibility is non-negotiable.
- **Responsive.** Fluid layouts, sensible breakpoints, responsive typography.
- **Tokenized.** CSS variables for colors, spacing, type scale, radii, shadows. Make the system easy to tweak.
- **Modern CSS.** Grid, Flex, container queries, clamp(), custom properties. No float hacks or brittle absolute positioning.
- **Light AND dark mode.** The user uses light by day, dark by night. Implement both with `prefers-color-scheme` and ensure both feel intentional (dark mode is not just "invert the colors").

## Design Execution

### Typography
- **The font pairing must be derived from the project, not from a default instinct.** A cooking app might want a warm humanist sans + handwritten accent. A CLI tool might want monospace everywhere. A literary site might want serif. A music player might want a bold geometric display face. Don't default to serif + mono just because it worked before.
- **Display type should be confident.** Whatever the typeface, don't be timid with heading sizes. Let the typography carry personality and set the voice.
- **Always justify the font choice.** If you can't explain *why this font for this project*, you haven't thought hard enough. "Because it looks nice" is not a reason. "Because this is a technical document and monospace is native to the subject matter" IS a reason.
- **Variety across projects matters.** If building multiple things, actively resist using the same pairing twice. The user values originality — seeing the same serif + mono on a pomodoro timer AND a recipe page AND a wiki defeats the purpose.
- Build hierarchy through whatever tools the chosen typeface offers: size, weight, spacing, case, color, position. There are many ways to create hierarchy beyond "big serif heading, small mono label."

### Color
- **The palette must emerge from the project's concept.** A timer counting down might use stark contrast and a single warning color. A recipe page might use spice tones. A 404 could be almost monochromatic. Don't default to "warm earthy tones" on everything.
- **Range is good.** The user appreciates warm palettes but also cool, saturated, desaturated, monochromatic, high-contrast — when there's a *reason*. A music player could be vibrant. A CLI docs page could be cold phosphor green. An event page could use bold accent colors.
- **Dark mode should feel intentional for THAT project**, not just "warm and enveloping" every time. A technical tool's dark mode might be cool and precise. A literary page's dark mode might be warm and soft. Match the mood.
- **Light mode should feel intentional too** — not always warm off-white. A clean tool might want crisp white. A recipe page might want cream. A wiki might want cool gray.
- Avoid palettes that feel like they came from a generator (5 evenly-spaced hues with no relationship to the content).
- Both light and dark variants should feel considered, not auto-generated.

### Layout & Information Architecture
- This is where the user's "minimal but info-rich" philosophy lives.
- **Clever information density:** progressive disclosure, well-structured tables, smart use of hover/focus states to reveal detail, compact but readable layouts.
- **Unique representations:** Don't default to "card grid" for everything. Consider: editorial layouts, data-driven compositions, asymmetric grids, timeline structures, nested/collapsible sections, spatial arrangements that match the content's logic.
- **Whitespace is a tool, not a rule.** Use enough to breathe, not so much that the page feels empty. The balance point is: "I can see everything I need without feeling overwhelmed."

### Detail & Texture
- Add detail that rewards closer inspection — subtle textures, thoughtful micro-interactions, considered border treatments, unexpected but purposeful decorative elements.
- Every detail should connect back to the concept. No random noise overlays or gratuitous grain.
- Consider the *materiality* of the design — should it feel like paper? like a screen? like something physical? like something ethereal?

### Motion & Animation
- The user loves subtle animations. Lean into this.
- **Meaningful transitions:** state changes, reveals, hover responses that feel alive.
- **Subtle ambient motion:** gentle breathing effects, soft parallax, elements that feel like they exist in a living space.
- **Never gratuitous.** Every animation should either communicate state, guide attention, or add warmth. If it does none of these, cut it.
- Honor `prefers-reduced-motion` always.

## Hard Avoids

These will immediately make the user think "this looks like everything else":

- ❌ **The Linear/generic SaaS look:** dark gradient background, floating cards with subtle borders, purple-blue accent, blur effects, the "glowing orb" behind the hero. Everyone copies this. Don't.
- ❌ **Cookie-cutter layouts:** hero section → 3 feature cards → testimonial → CTA. Think about what layout the *content* actually needs.
- ❌ **Default font stacks:** Inter, system-ui, Roboto as the "safe choice." If you're going sans-serif, at least pick one with character. But also don't default to sans-serif — let the project decide.
- ❌ **Unmotivated decoration:** gradient blobs, random geometric shapes, floating circles that don't mean anything. If a decorative element exists, it should connect to the design's concept.
- ❌ **Thoughtless component library look:** shadcn/Radix/Material defaults without customization. These are tools, not aesthetics. If using a component library, restyle it until it doesn't look like the library anymore.
- ❌ **"Clean and modern"** as a design direction. That's not a direction. That's the absence of one.
- ❌ **Falling into a house style.** If every project uses serif + mono, warm dark earthy colors, uppercase mono labels, and left-border accents — that's not "intentional design," that's a template. Each project should look like it was designed *for itself*. If you catch yourself reaching for the same patterns, stop and ask: "am I choosing this because it's right for THIS project, or because it's comfortable?"

## Deliverables

- Full working code with clear file names and component boundaries.
- CSS variables / design tokens that make customization easy.
- Both light and dark mode.
- Inline SVGs or generative CSS patterns instead of placeholder images.
- If the design direction involves a non-obvious choice, include a brief comment explaining the *why* (the user appreciates thought).

## Self-Validation Checklist

Before delivering, verify:
- [ ] Could I explain *why* for every major design choice? (color, font, layout, spacing)
- [ ] Would this look different from what 7/10 developers would build for the same brief?
- [ ] **Does this look different from the LAST thing I built?** (If the same patterns keep appearing — same font pairing, same color temperature, same structural elements — something is wrong. Each project should have its own visual DNA.)
- [ ] Is there a hook — one memorable thing about this design?
- [ ] Information is dense but clear — nothing feels overwhelming OR empty
- [ ] Subtle animations exist and feel purposeful
- [ ] Light and dark modes both feel intentional
- [ ] It works as a product (usable) AND as an experience (worth lingering on)
- [ ] It has a bit of personality/edge — it's not sterile
- [ ] Code runs as provided, is responsive, and is accessible

**The north star:** build something where a stranger would look at it and think *"someone really thought about this."*
