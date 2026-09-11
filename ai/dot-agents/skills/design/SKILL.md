---
name: design
description: Design, critique, or refine any designed artifact — interfaces, apps, dashboards, websites, mobile screens, CLI/TUI surfaces, diagrams, slides, documents, data visualizations. Covers direction, structure, surface, craft, and complete implementation. Use whenever something visual or experiential is being made and generic defaults should be replaced by specific, intentional design.
---

# Design

Everything worth making should carry thought that a motivated observer could extract from the artifact itself. That is the entire philosophy. The rest of this file is the procedure that makes it real.

Design is judgment, not decoration. There is no house style to apply and no personal taste to satisfy — good design is good design, and context is the only legitimate source of any choice. For every major decision you must be able to complete the sentence: "X, because this project specifically needs Y." If the honest completion is "because it's the convention" or "because it worked last time," no choice has been made — one has been skipped. Convention often survives this interrogation: convention chosen on purpose is design; convention by reflex is not. The same cuts the other way — deviating from convention just to be different is the identical failure with better PR. Originality comes from specificity, never from novelty theater.

## The Method — five gates, in order

Structure cannot be rescued by surface, and surface cannot be judged before it is rendered, so the gates are ordered. Scale the ceremony to the stakes — a quick diagram passes through every gate in seconds, a product page takes the full apparatus — but never skip a gate outright.

### Gate 1 — Understand, then commit

From the material available (ask only questions whose answers would change the design):

- What is this? Who uses it, in what medium, how often, and at what stakes — trust, speed, delight, density, persuasion?
- What is fixed, what can be inferred, what is genuinely open?

Then commit, before any visual decision:

- **The concept.** One sentence: what this should feel like and why that serves the people using it. It must be specific enough that someone could disagree with it. "Clean and modern" is not a concept — it is the absence of one. "A dense ops dashboard that stays calm under incident pressure" is a concept. Every later choice must trace back to this sentence.
- **The hook.** The single authored decision a stranger would remember. Structural, typographic, spatial, tonal, or behavioral — it does not need to be loud. It needs to be authored, and it must serve the concept rather than perform personality.

### Gate 2 — Structure before surface

Decide the information architecture before any styling: what belongs together, what deserves emphasis, what hides until needed, what order the eye should travel, what each interaction costs. Proximity is meaning — related things sit close, unrelated things sit apart — and hierarchy is decided here, not later with font sizes. If the structure is weak, styling will only disguise the problem.

### Gate 3 — Derive the surface

Type, color, spacing, motion, texture: each derived from the concept, none imported from habit.

- **Typography** speaks in the concept's voice. Choose deliberately: a limited scale (usually ≤5 sizes), few weights, body line length 45–75 characters. The industry-default font is not banned; it is just not chosen until you can say why it belongs *here*.
- **Color** is a set of jobs before it is a mood: surface layers, text hierarchy, one accent that means "act here," semantic states. Every color must be able to state its job. A dominant field with sharp accents outperforms a timid, evenly distributed palette.
- **Spacing** is one scale applied everywhere. Spacing sets pace and grouping: intentional density reads as composed, unintentional density as chaos, and inconsistent spacing as cheapness.
- **Motion** exists to clarify state and direct attention. One orchestrated moment beats scattered micro-twitches. Respect reduced-motion.
- **Effort matches vision.** Maximalism demands elaborate execution; minimalism demands precision. A distinctive concept executed sloppily reads worse than a plain one executed immaculately.

### Gate 4 — Render, look, judge

You have not designed anything until you have looked at the rendered artifact. Not the code — the render. Open it in a browser and screenshot it; run the TUI; export the slide. The material talks back — palettes turn muddy in context, type pairings fight the layout, concepts fall apart on contact — and that feedback only arrives if you look. Run these passes on what you actually see, and each pass must return an observation — what the render showed — not a verdict. A pass that produces no finding was recited, not run:

1. **Squint pass.** Blur it. Does the hierarchy survive — is the first thing you notice the most important thing? Hierarchy works pre-attentively or not at all.
2. **Count pass.** Sloppiness hides in code and shows in render, so count literally: distinct spacing values (one scale?), type sizes (≤5?), colors (each with a nameable job?), alignment (optical, not merely mathematical?). Every unexplained variant is craft debt.
3. **Reality pass.** Swap in realistic content: long names, empty lists, awkward wrapping. A design that only works with ideal placeholder content is undesigned.
4. **Voice pass.** Read every visible word. One author, speaking in the concept's voice?
5. **Stranger pass.** Thirty seconds, then gone. Does anything stay? Would they think *"someone really thought about this"*? If not, the fix is never more elements — it is more conviction: at least one decision that could not exist in any other project.
6. **Diagnose.** Name the nearest failure mode (below), fix it, re-render. Trust the render over your rationale — a justification cannot outvote what your eyes report.

If a treatment fails but the concept holds, adjust within the system. If the material keeps resisting — the mood is wrong at the root — return to Gate 1 and rethink; do not patch your way to a different idea. Either way, identify what is working and protect it.

### Gate 5 — Complete

Done means real, not "the happy path screenshots well":

- Every interactive element has hover, focus-visible, active, and disabled states.
- Every view has loading, empty, error, and overflow behavior.
- Responsive: rendered *and measured* at each breakpoint, not assumed — a screenshot hides a 12px bleed, a measurement cannot (on the web: no horizontal overflow, `scrollWidth === clientWidth`; in a terminal: nothing wraps at the declared width). Dark mode where the context has one.
- Accessible as a property of quality, not a pass at the end: semantic structure, keyboard traversal, body contrast ≥ 4.5:1, legible sizes, reduced-motion honored.
- Systematic: tokens/variables (or the medium's equivalent) so it can be tweaked without unraveling.
- Working, complete output — the real thing, never a description of it.

## Failure modes — name the nearest one

This is taste made operational: every draft sits closest to one of these, and naming it tells you what to fix. They are definitions, not examples, on purpose — examples become tics.

- **The Template.** Could ship under any logo; assembled from whatever is safe in this medium. Test: would 7 of 10 competent designers produce roughly this from the same brief? Your own habits count too — the pattern *you* reach for most often is also a template. Fix with specificity, never strangeness.
- **The Costume.** Personality worn as decoration — flourishes the concept never asked for. Distinctiveness that does not serve comprehension is noise.
- **The Furniture.** Every choice justified, nothing alive. The process is complete and the stranger pass still fails. Fix with one conviction, not more parts.
- **The Facade.** Beautiful until touched — breaks on hover, on mobile, on real data, on a long email address. Gate 5 was skipped.
- **The Shrug.** Right idea, careless hand: nine spacing values, seven grays doing three jobs, centered but not optically centered. Craft debt reads as cheapness regardless of concept.

## Embedded intent

The reasoning must be recoverable from the artifact itself, without a companion explanation. Name tokens for their role in this design, not their position in a list. Comment at decision points — why the pattern breaks here — never at obvious lines. Let structure mirror the content's logic so hierarchy is visible without labels. For substantial work, add a `DESIGN.md`: the design's inner monologue — what it is trying to feel like, what was rejected and why, the details nobody will notice that you placed anyway. That is the deep layer for the motivated; the artifact must still reward curiosity on its own.

## Pushing back

A lazy brief produces lazy work, so challenge it: name the weakness, explain its cost, propose a stronger alternative anchored to the actual problem. Requested ingredients are never forbidden — unexamined ones are. If a requested pattern survives scrutiny, use it deliberately and without apology.

**North star: a stranger looks at it and thinks, "someone really thought about this."**
