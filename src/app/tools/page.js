import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";
import { EXTERNAL_LINKS } from "@/assets/external_data";

export const metadata = {
  title: "Tools & Utilities - HulyPay",
  description: "Developer tooling, transaction exporters, regex parsers, and command-line utilities for the HulyPay ecosystem.",
};

const TOOLS = [
  {
    id: "regex-tester",
    tag: "PARSER",
    title: "SMS & NOTIFICATION REGEX TESTER",
    desc: "An on-device verification suite to test custom notification parsing patterns for new banks, microfinance providers, and payment providers.",
    badge: "CLI & GUI",
    features: [
      "Test against 40+ preloaded banking SMS formats",
      "Real-time token extraction (Amount, Currency, Merchant, RefId)",
      "Submit community patterns via GitHub PR",
    ],
    accent: "#62D800",
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
    accent: "#FF00F5",
  },
];

export default function ToolsPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="ECOSYSTEM"
        title="DEVELOPER & FINANCIAL TOOLS"
        subtitle="A modular suite of utilities designed for power users, engineers, and financial hackers who demand total control over their data."
        accentColor="#62D800"
      />

      <section className="w-full max-w-[1440px] mx-auto px-6 sm:px-10 lg:px-16 py-16 sm:py-24">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {TOOLS.map((tool) => (
            <div
              key={tool.id}
              className="border-4 border-black bg-white p-8 sm:p-10 shadow-[8px_8px_0px_#000000] flex flex-col justify-between hover:-translate-y-1 transition-transform"
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

                <h2 className="text-2xl sm:text-3xl font-bold text-black mb-3">
                  {tool.title}
                </h2>

                <p className="text-sm sm:text-base text-neutral-700 font-sans leading-relaxed mb-6">
                  {tool.desc}
                </p>

                <div className="space-y-2 border-t border-neutral-200 pt-5">
                  <span className="text-xs font-bold text-neutral-500 uppercase tracking-wider block mb-2">
                    Core Capabilities
                  </span>
                  {tool.features.map((feat, i) => (
                    <div key={i} className="flex items-start gap-2.5">
                      <span className="w-1.5 h-1.5 bg-black mt-2 shrink-0" />
                      <span className="text-sm text-neutral-800 font-sans">
                        {feat}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="mt-8 pt-6 border-t border-neutral-100 flex items-center justify-between">
                <span className="text-xs font-mono text-neutral-500">
                  STATUS: OPEN SOURCE (MIT)
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

        {/* Developer Banner */}
        <div className="mt-16 bg-[#FFFFEB] border-4 border-black p-8 sm:p-12 flex flex-col lg:flex-row items-center justify-between gap-8">
          <div>
            <span className="font-mono text-xs text-[#FF0000] font-bold uppercase block mb-1">
              CONTRIBUTE TO HULYPAY
            </span>
            <h3 className="font-doto text-2xl sm:text-4xl font-black text-black">
              WANT TO BUILD A NEW TOOL FOR HULYPAY?
            </h3>
            <p className="text-neutral-700 font-sans text-sm sm:text-base mt-2 max-w-xl">
              We welcome custom parser scripts, chain bridges, and data visualization plugins. Submit a pull request on GitHub.
            </p>
          </div>
          <a
            href={EXTERNAL_LINKS.social.github}
            target="_blank"
            rel="noopener noreferrer"
            className="px-8 py-3.5 bg-black text-white font-pixel font-bold text-base hover:bg-neutral-800 transition-colors shrink-0 shadow-[4px_4px_0px_#62D800]"
          >
            CONTRIBUTE ON GITHUB
          </a>
        </div>
      </section>

      <Footer />
    </main>
  );
}
