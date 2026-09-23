# Graph Report - frontend  (2026-09-23)

## Corpus Check
- 38 files · ~45,878 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 151 nodes · 236 edges · 16 communities (8 shown, 6 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `45546512`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- navBgIcons.js
- package.json
- layout.js
- design/page.js
- dependencies
- features/page.js
- README.md
- compilerOptions
- next.config.mjs
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- app/page.js
- Navbar.js

## God Nodes (most connected - your core abstractions)
1. `react` - 10 edges
2. `gsap` - 8 edges
3. `EXTERNAL_LINKS` - 7 edges
4. `Footer()` - 7 edges
5. `Navbar()` - 7 edges
6. `PageBanner()` - 6 edges
7. `scripts` - 5 edges
8. `BellNotificationAnimation()` - 3 edges
9. `LockJwtAnimation()` - 3 edges
10. `PieChartAnimation()` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (16 total, 6 thin omitted)

### Community 1 - "package.json"
Cohesion: 0.08
Nodes (24): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss, name, private (+16 more)

### Community 2 - "layout.js"
Cohesion: 0.13
Nodes (17): gsap, dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature() (+9 more)

### Community 3 - "design/page.js"
Cohesion: 0.33
Nodes (6): metadata, PALETTE, PRINCIPLES, Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 4 - "dependencies"
Cohesion: 0.25
Nodes (8): dependencies, gsap, @gsap/react, lenis, next, next-transition-router, react, react-dom

### Community 6 - "features/page.js"
Cohesion: 0.23
Nodes (9): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation(), FEATURE_LIST (+1 more)

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 15 - "app/page.js"
Cohesion: 0.17
Nodes (9): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), react, CardDownload(), Features(), Hero(), PARALLAX_CONFIG (+1 more)

### Community 16 - "Navbar.js"
Cohesion: 0.18
Nodes (10): metadata, FAQ_DATA, metadata, TECH_STACK_CATEGORIES, TOOLS, EXTERNAL_LINKS, NAV_BG_SVGS, PageBanner() (+2 more)

## Knowledge Gaps
- **58 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+53 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 84 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `app/page.js` to `package.json`, `layout.js`, `design/page.js`, `features/page.js`, `Navbar.js`?**
  _High betweenness centrality (0.291) - this node is a cross-community bridge._
- **Why does `gsap` connect `layout.js` to `package.json`, `design/page.js`, `features/page.js`, `app/page.js`, `Navbar.js`?**
  _High betweenness centrality (0.185) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.080) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _58 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `layout.js` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._