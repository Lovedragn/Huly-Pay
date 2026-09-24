# Graph Report - frontend  (2026-09-24)

## Corpus Check
- 42 files · ~47,317 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 160 nodes · 267 edges · 17 communities (9 shown, 6 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `30c7522f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- navBgIcons.js
- package.json
- react
- design/page.js
- dependencies
- layout.js
- Features.js
- README.md
- compilerOptions
- next.config.mjs
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- app/page.js
- features/page.js

## God Nodes (most connected - your core abstractions)
1. `react` - 13 edges
2. `gsap` - 9 edges
3. `EXTERNAL_LINKS` - 7 edges
4. `Footer()` - 7 edges
5. `Navbar()` - 7 edges
6. `PageBanner()` - 6 edges
7. `scripts` - 5 edges
8. `DEFAULT_BLOCK_COUNT` - 5 edges
9. `BellNotificationAnimation()` - 3 edges
10. `LockJwtAnimation()` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (17 total, 6 thin omitted)

### Community 1 - "package.json"
Cohesion: 0.08
Nodes (24): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss, name, private (+16 more)

### Community 2 - "react"
Cohesion: 0.20
Nodes (16): react, AnimatedSignature(), SIGNATURE_FILL_PATH, SIGNATURE_HEIGHT, SIGNATURE_MASK_PATH, SIGNATURE_STROKE_LENGTH, SIGNATURE_VIEWBOX, SIGNATURE_WIDTH (+8 more)

### Community 3 - "design/page.js"
Cohesion: 0.33
Nodes (6): metadata, PALETTE, PRINCIPLES, Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 4 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, gsap, @gsap/react, lenis, next, next-transition-router, react, react-dom

### Community 5 - "layout.js"
Cohesion: 0.22
Nodes (7): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), InitialLoader()

### Community 6 - "Features.js"
Cohesion: 0.23
Nodes (7): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation()

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 15 - "app/page.js"
Cohesion: 0.17
Nodes (9): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), gsap, CardDownload(), Features(), Hero(), PARALLAX_CONFIG (+1 more)

### Community 16 - "features/page.js"
Cohesion: 0.17
Nodes (11): FEATURE_LIST, metadata, metadata, FAQ_DATA, metadata, TECH_STACK_CATEGORIES, TOOLS, EXTERNAL_LINKS (+3 more)

## Knowledge Gaps
- **58 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+53 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 83 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `package.json`, `design/page.js`, `Features.js`, `app/page.js`, `features/page.js`?**
  _High betweenness centrality (0.294) - this node is a cross-community bridge._
- **Why does `gsap` connect `app/page.js` to `package.json`, `react`, `design/page.js`, `Features.js`, `features/page.js`?**
  _High betweenness centrality (0.207) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _58 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._