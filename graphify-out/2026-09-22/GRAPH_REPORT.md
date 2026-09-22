# Graph Report - frontend  (2026-09-22)

## Corpus Check
- 23 files · ~78,056 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 100 nodes · 125 edges · 16 communities (9 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `70b24fce`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app/page.js
- package.json
- AnimatedSignature.js
- layout.js
- dependencies
- devDependencies
- scripts
- README.md
- compilerOptions
- next.config.mjs
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- Workflow.js

## God Nodes (most connected - your core abstractions)
1. `react` - 7 edges
2. `gsap` - 6 edges
3. `scripts` - 5 edges
4. `SIGNATURE_STROKE_LENGTH` - 4 edges
5. `AnimatedSignature()` - 3 edges
6. `compilerOptions` - 2 edges
7. `SmoothScroll()` - 2 edges
8. `CardDownload()` - 2 edges
9. `Features()` - 2 edges
10. `Footer()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (16 total, 5 thin omitted)

### Community 0 - "app/page.js"
Cohesion: 0.15
Nodes (8): gsap, CardDownload(), Features(), Footer(), Hero(), PARALLAX_CONFIG, Navbar(), Workflow()

### Community 1 - "package.json"
Cohesion: 0.14
Nodes (13): name, private, version, babel-plugin-react-compiler, eslint, eslint-config-next, @gsap/react, lenis (+5 more)

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

### Community 6 - "scripts"
Cohesion: 0.40
Nodes (5): scripts, build, dev, lint, start

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 15 - "Workflow.js"
Cohesion: 0.70
Nodes (3): Frame143Badge(), Frame144Badge(), Frame145Badge()

## Knowledge Gaps
- **44 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+39 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 58 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `AnimatedSignature.js` to `app/page.js`, `package.json`, `Workflow.js`?**
  _High betweenness centrality (0.251) - this node is a cross-community bridge._
- **Why does `gsap` connect `app/page.js` to `package.json`, `AnimatedSignature.js`, `Workflow.js`?**
  _High betweenness centrality (0.176) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _44 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._