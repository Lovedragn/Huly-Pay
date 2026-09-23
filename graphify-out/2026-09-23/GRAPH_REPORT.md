# Graph Report - frontend  (2026-09-23)

## Corpus Check
- 32 files · ~66,932 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 129 nodes · 171 edges · 17 communities (10 shown, 5 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cb896ba7`
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
- gsap

## God Nodes (most connected - your core abstractions)
1. `react` - 9 edges
2. `gsap` - 8 edges
3. `scripts` - 5 edges
4. `EXTERNAL_LINKS` - 4 edges
5. `SIGNATURE_STROKE_LENGTH` - 4 edges
6. `AnimatedSignature()` - 3 edges
7. `compilerOptions` - 2 edges
8. `NAV_BG_SVGS` - 2 edges
9. `SmoothScroll()` - 2 edges
10. `BellNotificationAnimation()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (17 total, 5 thin omitted)

### Community 0 - "app/page.js"
Cohesion: 0.10
Nodes (11): NAV_BG_SVGS, CardDownload(), EXTERNAL_LINKS, Features(), Footer(), Navbar(), CIPHER_ITEMS, CIPHER_TEXT (+3 more)

### Community 1 - "package.json"
Cohesion: 0.11
Nodes (18): name, private, scripts, build, dev, lint, start, version (+10 more)

### Community 2 - "AnimatedSignature.js"
Cohesion: 0.30
Nodes (9): react, AnimatedSignature(), SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH (+1 more)

### Community 3 - "layout.js"
Cohesion: 0.20
Nodes (8): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), InitialLoader(), TransitionProvider()

### Community 4 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, gsap, @gsap/react, lenis, next, next-transition-router, react, react-dom

### Community 5 - "devDependencies"
Cohesion: 0.33
Nodes (6): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss

### Community 6 - "Features.js"
Cohesion: 0.23
Nodes (7): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation()

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 15 - "Workflow.js"
Cohesion: 0.53
Nodes (4): Workflow(), Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 16 - "gsap"
Cohesion: 0.40
Nodes (3): gsap, Hero(), PARALLAX_CONFIG

## Knowledge Gaps
- **49 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+44 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 69 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `AnimatedSignature.js` to `app/page.js`, `package.json`, `Features.js`, `Workflow.js`, `gsap`?**
  _High betweenness centrality (0.290) - this node is a cross-community bridge._
- **Why does `gsap` connect `gsap` to `app/page.js`, `package.json`, `AnimatedSignature.js`, `Features.js`, `Workflow.js`?**
  _High betweenness centrality (0.222) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _49 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app/page.js` be split into smaller, more focused modules?**
  _Cohesion score 0.09788359788359788 - nodes in this community are weakly interconnected._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._