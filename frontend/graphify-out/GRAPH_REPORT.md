# Graph Report - frontend  (2026-09-24)

## Corpus Check
- 47 files · ~53,180 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 200 nodes · 347 edges · 17 communities (10 shown, 6 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d716fe5a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- navBgIcons.js
- package.json
- layout.js
- design/page.js
- dependencies
- react
- features/page.js
- README.md
- compilerOptions
- next.config.mjs
- AGENTS.md
- eslint.config.mjs
- postcss.config.mjs
- dashboard/page.js
- app/page.js
- Navbar.js

## God Nodes (most connected - your core abstractions)
1. `react` - 18 edges
2. `gsap` - 9 edges
3. `ChartTooltipContent` - 8 edges
4. `DashboardPage()` - 7 edges
5. `EXTERNAL_LINKS` - 7 edges
6. `Footer()` - 7 edges
7. `Navbar()` - 7 edges
8. `ChartLegendContent` - 7 edges
9. `recharts` - 6 edges
10. `fetchData()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `DashboardPage()` --calls--> `getCategoryBreakdown()`  [EXTRACTED]
  src/app/dashboard/page.js → src/lib/api.js
- `DashboardPage()` --calls--> `getDailySpending()`  [EXTRACTED]
  src/app/dashboard/page.js → src/lib/api.js
- `DashboardPage()` --calls--> `getExpenses()`  [EXTRACTED]
  src/app/dashboard/page.js → src/lib/api.js
- `DashboardPage()` --calls--> `getMonthlySpending()`  [EXTRACTED]
  src/app/dashboard/page.js → src/lib/api.js
- `DashboardPage()` --calls--> `getSpendingSummary()`  [EXTRACTED]
  src/app/dashboard/page.js → src/lib/api.js

## Import Cycles
- None detected.

## Communities (17 total, 6 thin omitted)

### Community 1 - "package.json"
Cohesion: 0.07
Nodes (27): devDependencies, babel-plugin-react-compiler, eslint, eslint-config-next, tailwindcss, @tailwindcss/postcss, name, private (+19 more)

### Community 2 - "layout.js"
Cohesion: 0.13
Nodes (16): dotoFont, geistMono, geistSans, metadata, pixelifySans, SmoothScroll(), AnimatedSignature(), InitialLoader() (+8 more)

### Community 3 - "design/page.js"
Cohesion: 0.33
Nodes (6): metadata, PALETTE, PRINCIPLES, Frame143Badge(), Frame144Badge(), Frame145Badge()

### Community 4 - "dependencies"
Cohesion: 0.17
Nodes (12): dependencies, clsx, gsap, @gsap/react, lenis, lucide-react, next, next-transition-router (+4 more)

### Community 5 - "react"
Cohesion: 0.17
Nodes (18): react, recharts, AreaChartSpending(), chartConfig, BarChartMonthly(), chartConfig, chartConfig, PieChartCategories() (+10 more)

### Community 6 - "features/page.js"
Cohesion: 0.23
Nodes (9): BellNotificationAnimation(), LockJwtAnimation(), PieChartAnimation(), EXTRA_PIXELS, MORPH_PIXELS, QrToTickAnimation(), WifiOfflineAnimation(), FEATURE_LIST (+1 more)

### Community 7 - "README.md"
Cohesion: 0.50
Nodes (3): Deploy on Vercel, Getting Started, Learn More

### Community 13 - "dashboard/page.js"
Cohesion: 0.23
Nodes (16): DashboardPage(), fetchData(), BackendStatusBar(), verify(), checkBackendHealth(), getCategoryBreakdown(), getDailySpending(), getExpenses() (+8 more)

### Community 15 - "app/page.js"
Cohesion: 0.17
Nodes (9): CIPHER_FLOW, PLAIN_FLOW, VeinTextFlow(), gsap, CardDownload(), Features(), Hero(), PARALLAX_CONFIG (+1 more)

### Community 16 - "Navbar.js"
Cohesion: 0.18
Nodes (10): metadata, FAQ_DATA, metadata, TECH_STACK_CATEGORIES, TOOLS, EXTERNAL_LINKS, NAV_BG_SVGS, PageBanner() (+2 more)

## Knowledge Gaps
- **73 isolated node(s):** `eslintConfig`, `paths`, `nextConfig`, `name`, `version` (+68 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 98 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `react` to `package.json`, `layout.js`, `design/page.js`, `features/page.js`, `dashboard/page.js`, `app/page.js`, `Navbar.js`?**
  _High betweenness centrality (0.452) - this node is a cross-community bridge._
- **Why does `gsap` connect `app/page.js` to `package.json`, `layout.js`, `design/page.js`, `features/page.js`, `Navbar.js`?**
  _High betweenness centrality (0.139) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **What connects `eslintConfig`, `paths`, `nextConfig` to the rest of the system?**
  _73 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package.json` be split into smaller, more focused modules?**
  _Cohesion score 0.07142857142857142 - nodes in this community are weakly interconnected._
- **Should `layout.js` be split into smaller, more focused modules?**
  _Cohesion score 0.12681159420289856 - nodes in this community are weakly interconnected._