# Graph Report - frontend  (2026-09-22)

## Corpus Check
- 28 files · ~81,644 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 112 nodes · 153 edges · 16 communities (9 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1d3ebefd`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app/page.js
- package.json
- AnimatedSignature.js
- layout.js
- dependencies
- devDependencies
- Features.js
- README.md
- compilerOptions
- next.config.mjs
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- Workflow.js

## God Nodes (most connected - your core abstractions)
1. `react` - 12 edges
2. `gsap` - 11 edges
3. `scripts` - 5 edges
4. `SIGNATURE_STROKE_LENGTH` - 4 edges
5. `AnimatedSignature()` - 3 edges
6. `compilerOptions` - 2 edges
7. `SmoothScroll()` - 2 edges
8. `BellNotificationAnimation()` - 2 edges
9. `CardDownload()` - 2 edges
10. `Features()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (16 total, 5 thin omitted)

### Community 0 - "app/page.js"
Cohesion: 0.16
Nodes (7): CardDownload(), Features(), Footer(), Hero(), PARALLAX_CONFIG, Navbar(), Workflow()

### Community 1 - "package.json"
Cohesion: 0.11
Nodes (18): name, private, scripts, build, dev, lint, start, version (+10 more)

### Community 2 - "AnimatedSignature.js"
Cohesion: 0.27
Nodes (9): AnimatedSignature(), SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH, TransitionContext (+1 more)

### Community 3 - "layout.js"
Cohesion: 0.22
Nodes (7): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), InitialLoader()

### Community 4 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, gsap, @gsap/react, lenis, next, next-transition-router, react, react-dom

### Community 5 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss

### Community 6 - "Features.js"
Cohesion: 0.27
Nodes (9): gsap, react, BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation() (+1 more)

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 15 - "Workflow.js"
Cohesion: 0.70
Nodes (3): Frame143Badge(), Frame144Badge(), Frame145Badge()

## Knowledge Gaps
- **45 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+40 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 59 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `Features.js` to `app/page.js`, `package.json`, `AnimatedSignature.js`, `Workflow.js`?**
  _High betweenness centrality (0.272) - this node is a cross-community bridge._
- **Why does `gsap` connect `Features.js` to `app/page.js`, `package.json`, `AnimatedSignature.js`, `Workflow.js`?**
  _High betweenness centrality (0.200) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _45 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._