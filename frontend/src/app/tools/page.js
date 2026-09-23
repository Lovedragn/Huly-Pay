import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";
import { EXTERNAL_LINKS } from "@/assets/external_data";

export const metadata = {
  title: "Tools & Ecosystem - HulyPay",
  description:
    "Explore HulyPay's technology stack (Flutter, Dart, Spring Boot, Next.js), Google Gemini AI integration, API keys, and developer utilities.",
};

const TECH_STACK_CATEGORIES = [
  {
    category: "LANGUAGES & CORE",
    color: "#FF0000",
    items: [
      {
        name: "Dart",
        type: "Language",
        desc: "Type-safe, fast sound-null compiled language powering mobile business logic and cross-platform UI rendering.",
        badge: "v3.x",
      },
      {
        name: "Java / Kotlin",
        type: "Backend & Android",
        desc: "High-throughput Java 21 LTS runtime alongside Kotlin for hardware Keystore cryptography and native OS listeners.",
        badge: "Java 21",
      },
      {
        name: "JavaScript / TypeScript",
        type: "Frontend Web",
        desc: "Modern ECMAScript standard driving interactive landing experiences, GSAP canvas animations, and web dashboards.",
        badge: "ESNext",
      },
      {
        name: "SQL (SQLite & Postgres)",
        type: "Database Query",
        desc: "Relational querying for zero-latency local-first device storage and enterprise PostgreSQL reporting replicas.",
        badge: "SQL-92",
      },
    ],
  },
  {
    category: "FRAMEWORKS & RUNTIMES",
    color: "#62D800",
    items: [
      {
        name: "Flutter",
        type: "Mobile Client",
        desc: "High-performance multi-platform UI framework rendering 60/120fps pixel-perfect design on Android and iOS.",
        badge: "Mobile UI",
      },
      {
        name: "Spring Boot",
        type: "Enterprise Backend",
        desc: "Production-grade microservice architecture handling JWT authentication, rate-limiting, and webhook bridges.",
        badge: "v3.3+",
      },
      {
        name: "Next.js",
        type: "Web Application",
        desc: "React 19 framework featuring server components, Lenis smooth scrolling, GSAP page transitions, and SEO optimization.",
        badge: "v15 App Router",
      },
      {
        name: "Tailwind CSS v4",
        type: "Design System",
        desc: "Ultra-fast utility CSS engine enforcing retro-futuristic borders, monospaced typography, and strict color tokens.",
        badge: "Styling",
      },
    ],
  },
  {
    category: "AI, APIS & KEYS",
    color: "#FF00F5",
    items: [
      {
        name: "Google Gemini AI API",
        type: "LLM Intelligence",
        desc: "Gemini 1.5 Flash / Pro model integration for semantic receipt parsing, OCR bill summarization, and natural language spend queries.",
        badge: "Gemini API",
      },
      {
        name: "API Keys & Environment",
        type: "Security & Config",
        desc: "Stored securely in .env / system vaults. Client-side builds never leak backend credentials or Gemini API private keys.",
        badge: "GEMINI_API_KEY",
      },
      {
        name: "JWT & Crypto Rail",
        type: "Auth & Tokens",
        desc: "HMAC-SHA256 and RSA-signed JSON Web Tokens protecting private endpoint routes and user session handshakes.",
        badge: "Bearer Auth",
      },
      {
        name: "UPI / EMVCo Standard",
        type: "Payment Protocol",
        desc: "Open payment string protocol parsing merchant virtual payment addresses (VPA), invoice amounts, and transaction references.",
        badge: "QR Rail",
      },
    ],
  },
];

const TOOLS = [
  {
    id: "regex-tester",
    tag: "PARSER",
    title: "SMS & NOTIFICATION REGEX TESTER",
    desc: "An on-device verification suite to test custom notification parsing patterns for new banks, microfinance providers, and payment gateways.",
    badge: "CLI & GUI",
    features: [
      "Test against 40+ preloaded banking SMS formats",
      "Real-time token extraction (Amount, Currency, Merchant, RefId)",
      "Submit community patterns via GitHub PR",
    ],
    accent: "#62D800",
  },
  {
    id: "gemini-parser",
    tag: "AI TOOL",
    title: "GEMINI RECEIPT & BILL PARSER",
    desc: "Leverage Google Gemini API to extract itemized expenditures, taxes, and merchant categories from camera snapshots or text receipts.",
    badge: "AI EXTENSION",
    features: [
      "Gemini 1.5 Flash multimodal zero-shot OCR extraction",
      "Structured JSON output mapping directly to SQLite schema",
      "Bring-Your-Own API Key (BYOK) stored strictly in device Keystore",
    ],
    accent: "#FF00F5",
  },
  {
    id: "sqlite-inspector",
    tag: "DATABASE",
    title: "SQLITE LOCAL SCHEMA INSPECTOR",
    desc: "A developer tool to inspect, backup, and query the local SQLite storage tables used across Android and Flutter engines.",
    badge: "DEV TOOL",
    features: [
      "View indexes for high-speed offline lookups",
      "Perform raw SQL queries for debugging",
      "Validate zero telemetry write operations",
    ],
    accent: "#38BDF8",
  },
  {
    id: "data-exporter",
    tag: "EXPORT",
    title: "TRANSACTION EXPORT & SYNC BRIDGE",
    desc: "Export your ledger data into open accounting formats including standard CSV, JSON-LD, and ledger-cli compatible plain text files.",
    badge: "STANDALONE",
    features: [
      "Zero vendor lock-in with one-click full backup",
      "Custom date range and tag filtering",
      "Direct integration with personal spreadsheets",
    ],
    accent: "#D8FF00",
  },
  {
    id: "qr-generator",
    tag: "TEST SUITE",
    title: "MERCHANT QR STRESS SIMULATOR",
    desc: "Simulate and generate dynamic test QR codes under varying contrast, inverted colors, and synthetic camera motion blur.",
    badge: "BENCHMARK",
    features: [
      "Test ISO/IEC 18004 compliance",
      "Benchmark camera viewfinder decode speeds",
      "Validate UPI / EMVCo / Lightning invoice strings",
    ],
    accent: "#FF0000",
  },
  {
    id: "backend-bridge",
    tag: "BACKEND",
    title: "SPRING BOOT MICROSERVICE BRIDGE",
    desc: "A headless Spring Boot companion service to handle heavy background aggregation, multi-device backup, and encrypted JWT relays.",
    badge: "SPRING BOOT",
    features: [
      "RESTful and WebSocket APIs for instant sync",
      "Configurable via application.yml or environment variables",
      "Containerized Docker & docker-compose ready",
    ],
    accent: "#62D800",
  },
];

export default function ToolsPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="ECOSYSTEM & TOOLS"
        title="TECH STACK, APIS & DEVELOPER UTILITIES"
        subtitle="Explore the languages, frameworks, backend services, AI integrations (Google Gemini), and standalone utilities powering the HulyPay platform."
        accentColor="#62D800"
      />

      <section className="w-full max-w-[1440px] mx-auto px-4 sm:px-10 lg:px-16 py-10 sm:py-24 space-y-14 sm:space-y-20">
        {/* ===================================================================== */}
        {/* SECTION 1: ARCHITECTURE & TECH STACK OVERVIEW */}
        {/* ===================================================================== */}
        <div>
          <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-3 sm:gap-4 mb-8 sm:mb-10 pb-4 border-b-2 border-black">
            <div>
              <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase block">
                CORE ARCHITECTURE
              </span>
              <h2 className="text-2xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-black mt-1">
                TECHNOLOGY STACK
              </h2>
            </div>
            <span className="font-mono text-xs text-neutral-600 bg-neutral-100 px-3 py-1.5 border border-black self-start sm:self-auto">
              MODULAR &bull; LOCAL-FIRST &bull; SECURE
            </span>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
            {TECH_STACK_CATEGORIES.map((cat, idx) => (
              <div
                key={idx}
                className="border-[3px] sm:border-4 border-black bg-white p-5 sm:p-8 shadow-[4px_4px_0px_#000000] sm:shadow-[6px_6px_0px_#000000] flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center gap-2 mb-6 pb-3 border-b border-neutral-200">
                    <span
                      className="w-3 h-3 rounded-full shrink-0"
                      style={{ backgroundColor: cat.color }}
                    />
                    <h3 className="font-pixel text-lg sm:text-xl font-bold text-black tracking-wide">
                      {cat.category}
                    </h3>
                  </div>

                  <div className="space-y-6">
                    {cat.items.map((item, itemIdx) => (
                      <div key={itemIdx} className="space-y-1">
                        <div className="flex items-center justify-between gap-2">
                          <span className="font-pixel text-base font-bold text-black">
                            {item.name}
                          </span>
                          <span className="font-mono text-[11px] font-bold bg-black text-white px-2 py-0.5">
                            {item.badge}
                          </span>
                        </div>
                        <span className="text-xs font-mono text-neutral-500 block">
                          {item.type}
                        </span>
                        <p className="text-xs sm:text-sm text-neutral-700 font-sans leading-relaxed pt-0.5">
                          {item.desc}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="mt-8 pt-4 border-t border-neutral-100 flex items-center justify-between text-[11px] font-mono text-neutral-500">
                  <span>PRODUCTION READY</span>
                  <span className="font-bold text-black">&#x2713; ACTIVE</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ===================================================================== */}
        {/* SECTION 2: API KEYS & ENVIRONMENT CONFIGURATION */}
        {/* ===================================================================== */}
        <div className="border-[3px] sm:border-4 border-black bg-[#FFFFEB] p-5 sm:p-12 shadow-[5px_5px_0px_#000000] sm:shadow-[8px_8px_0px_#000000]">
          <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 sm:gap-6 mb-6 sm:mb-8 pb-5 sm:pb-6 border-b-2 border-black">
            <div>
              <span className="text-xs font-mono text-[#FF0000] font-bold uppercase tracking-wider block mb-1">
                SECURITY &amp; ENVIRONMENT CONFIGURATION
              </span>
              <h3 className="font-pixel text-xl sm:text-4xl font-bold text-black">
                API KEYS &amp; CREDENTIAL MANAGEMENT
              </h3>
            </div>
            <span className="font-mono text-xs font-bold bg-black text-[#62D800] px-3 py-1.5 self-start lg:self-auto">
              ZERO CLIENT LEAKAGE
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-6 font-sans">
            <div className="bg-white border-2 border-black p-4 sm:p-5 shadow-[3px_3px_0px_#000000] sm:shadow-[4px_4px_0px_#000000]">
              <span className="font-mono text-xs font-bold text-black bg-[#FF00F5]/20 px-2 py-0.5 block w-max mb-2">
                GEMINI_API_KEY
              </span>
              <h4 className="font-pixel text-lg font-bold text-black mb-1">
                Google Gemini API
              </h4>
              <p className="text-xs sm:text-sm text-neutral-700 leading-relaxed">
                Empowers smart receipt OCR, categorized spending suggestions,
                and financial insights. Stored securely in on-device Keystore or server environment variables.
              </p>
            </div>

            <div className="bg-white border-2 border-black p-5 shadow-[4px_4px_0px_#000000]">
              <span className="font-mono text-xs font-bold text-black bg-[#62D800]/25 px-2 py-0.5 block w-max mb-2">
                JWT_SECRET_KEY
              </span>
              <h4 className="font-pixel text-lg font-bold text-black mb-1">
                Spring Boot Auth
              </h4>
              <p className="text-xs sm:text-sm text-neutral-700 leading-relaxed">
                Cryptographically signed 256-bit secret for authenticating
                requests between Flutter client apps and self-hosted Spring Boot backend endpoints.
              </p>
            </div>

            <div className="bg-white border-2 border-black p-5 shadow-[4px_4px_0px_#000000]">
              <span className="font-mono text-xs font-bold text-black bg-[#D8FF00]/40 px-2 py-0.5 block w-max mb-2">
                NEXT_PUBLIC_*
              </span>
              <h4 className="font-pixel text-lg font-bold text-black mb-1">
                Next.js Web Client
              </h4>
              <p className="text-xs sm:text-sm text-neutral-700 leading-relaxed">
                Strict segregation ensures only non-sensitive visual toggles and
                external repository endpoints are bundled into static frontend builds.
              </p>
            </div>
          </div>
        </div>

        {/* ===================================================================== */}
        {/* SECTION 3: DEVELOPER UTILITIES & TOOLS SUITE */}
        {/* ===================================================================== */}
        <div>
          <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-3 sm:gap-4 mb-8 sm:mb-10 pb-4 border-b-2 border-black">
            <div>
              <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase block">
                DEVELOPER TOOLING
              </span>
              <h2 className="text-2xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-black mt-1">
                ECOSYSTEM UTILITIES
              </h2>
            </div>
            <span className="font-mono text-xs text-neutral-600">
              6 TOOLS AVAILABLE
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            {TOOLS.map((tool) => (
              <div
                key={tool.id}
                className="border-[3px] sm:border-4 border-black bg-white p-5 sm:p-8 shadow-[5px_5px_0px_#000000] sm:shadow-[8px_8px_0px_#000000] flex flex-col justify-between hover:-translate-y-1 transition-transform"
              >
                <div>
                  <div className="flex items-center justify-between gap-4 mb-4">
                    <span
                      className="text-xs font-bold uppercase tracking-widest px-2.5 py-1 border border-black"
                      style={{ backgroundColor: `${tool.accent}33` }}
                    >
                      {tool.tag}
                    </span>
                    <span className="font-mono text-xs font-bold bg-black text-white px-2 py-0.5">
                      {tool.badge}
                    </span>
                  </div>

                  <h3 className="text-xl sm:text-2xl font-bold text-black mb-3">
                    {tool.title}
                  </h3>

                  <p className="text-xs sm:text-sm text-neutral-700 font-sans leading-relaxed mb-6">
                    {tool.desc}
                  </p>

                  <div className="space-y-2 border-t border-neutral-200 pt-5">
                    <span className="text-xs font-bold text-neutral-500 uppercase tracking-wider block mb-2">
                      Core Capabilities
                    </span>
                    {tool.features.map((feat, i) => (
                      <div key={i} className="flex items-start gap-2.5">
                        <span className="w-1.5 h-1.5 bg-black mt-1.5 shrink-0" />
                        <span className="text-xs sm:text-sm text-neutral-800 font-sans">
                          {feat}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="mt-8 pt-6 border-t border-neutral-100 flex items-center justify-between">
                  <span className="text-xs font-mono text-neutral-500">
                    STATUS: MIT
                  </span>
                  <a
                    href={EXTERNAL_LINKS.social.github}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-pixel text-xs sm:text-sm font-bold text-black hover:text-[#FF0000] transition-colors flex items-center gap-1.5"
                  >
                    <span>SOURCE CODE</span>
                    <span>&rarr;</span>
                  </a>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ===================================================================== */}
        {/* SECTION 4: CALL TO ACTION BANNER */}
        {/* ===================================================================== */}
        <div className="bg-[#FFFFEB] border-[3px] sm:border-4 border-black p-5 sm:p-12 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6 sm:gap-8 shadow-[5px_5px_0px_#000000] sm:shadow-[8px_8px_0px_#000000]">
          <div>
            <span className="font-mono text-xs text-[#FF0000] font-bold uppercase block mb-1">
              CONTRIBUTE TO HULYPAY
            </span>
            <h3 className="font-doto text-xl sm:text-4xl font-black text-black">
              WANT TO EXPAND THE HULYPAY ECOSYSTEM?
            </h3>
            <p className="text-neutral-700 font-sans text-xs sm:text-base mt-2 max-w-xl">
              We welcome custom Flutter widgets, Spring Boot microservice modules,
              Gemini AI prompt chains, and payment regex parser plugins. Submit a pull request on GitHub.
            </p>
          </div>
          <a
            href={EXTERNAL_LINKS.social.github}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto text-center px-6 sm:px-8 py-3 sm:py-3.5 bg-black text-white font-pixel font-bold text-sm sm:text-base hover:bg-neutral-800 transition-colors shrink-0 shadow-[4px_4px_0px_#62D800]"
          >
            CONTRIBUTE ON GITHUB
          </a>
        </div>
      </section>

      <Footer />
    </main>
  );
}
