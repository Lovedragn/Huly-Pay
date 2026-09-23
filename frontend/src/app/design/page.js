import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Image from "next/image";
import { Frame145Badge, Frame143Badge, Frame144Badge } from "@/components/landing/WorkflowBadges";

export const metadata = {
  title: "Design System - HulyPay",
  description: "Explore the design philosophy, typography, chromatic hierarchy, and pixel-art components that power HulyPay.",
};

const PALETTE = [
  { name: "Brand Red", hex: "#FF0000", rgb: "255, 0, 0", border: "#CC0000", usage: "Action CTAs, highlight dots, accents" },
  { name: "Terminal Lime", hex: "#62D800", rgb: "98, 216, 0", border: "#459700", usage: "Speed & scanner metrics, step 1 status" },
  { name: "Cyber Yellow", hex: "#D8FF00", rgb: "216, 255, 0", border: "#97B300", usage: "Security status badges, highlights" },
  { name: "Neon Magenta", hex: "#FF00F5", rgb: "255, 0, 245", border: "#B300AC", usage: "Visual analytics, data accents" },
  { name: "Chalk Background", hex: "#FFFFEB", rgb: "255, 255, 235", border: "#E6E6CC", usage: "Warm vintage paper landing background" },
  { name: "Monolith Black", hex: "#000000", rgb: "0, 0, 0", border: "#333333", usage: "Cards, borders, dark mega menus, workflow" },
];

const PRINCIPLES = [
  {
    num: "01",
    title: "RETRO-FUTURIST PIXEL PRECISION",
    desc: "Drawing inspiration from 90s cyberdecks and dot-matrix receipt printers, every button, outline, and divider uses crisp integer border widths and zero blur.",
  },
  {
    num: "02",
    title: "IMMEDIATE TACTILE FEEDBACK",
    desc: "Hover and press interactions must feel snappy and mechanical. Fast GSAP easing curves (power2.inOut, back.out) replace floaty gradients with crisp state shifts.",
  },
  {
    num: "03",
    title: "ZERO VISUAL CLUTTER",
    desc: "Financial data is stressful when buried in dense tables. We use high-contrast color codes, huge typography, and geometric badge motifs to make data scannable in 300ms.",
  },
];

export default function DesignPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="DESIGN SYSTEM"
        title="THE VISUAL LANGUAGE OF HULYPAY"
        subtitle="Bridging raw cybernetic hardware aesthetics with contemporary micro-interactions and high-legibility typographic tokens."
        accentColor="#FF00F5"
      />

      <section className="w-full max-w-[1440px] mx-auto px-6 sm:px-10 lg:px-16 py-16 sm:py-24 space-y-20">
        {/* Core Principles */}
        <div>
          <div className="mb-10">
            <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase">
              PHILOSOPHY
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-black mt-1">
              DESIGN PRINCIPLES
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {PRINCIPLES.map((item) => (
              <div
                key={item.num}
                className="p-8 border-4 border-black bg-neutral-50 shadow-[6px_6px_0px_#000000] flex flex-col justify-between"
              >
                <div>
                  <span className="font-doto text-4xl font-black text-[#FF0000] block mb-4">
                    {item.num}
                  </span>
                  <h3 className="text-xl font-bold text-black mb-3">
                    {item.title}
                  </h3>
                  <p className="text-sm sm:text-base text-neutral-700 font-sans leading-relaxed">
                    {item.desc}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Color Palette Grid */}
        <div>
          <div className="mb-10">
            <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase">
              CHROMATIC TOKENS
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-black mt-1">
              COLOR ARCHITECTURE
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {PALETTE.map((c) => (
              <div
                key={c.name}
                className="border-4 border-black bg-white shadow-[6px_6px_0px_#000000] overflow-hidden"
              >
                <div
                  className="h-28 w-full border-b-4 border-black flex items-end p-4"
                  style={{ backgroundColor: c.hex }}
                >
                  <span
                    className="font-mono text-xs px-2 py-1 bg-black text-white font-bold"
                  >
                    {c.hex}
                  </span>
                </div>
                <div className="p-5">
                  <h3 className="text-lg font-bold text-black">{c.name}</h3>
                  <p className="text-xs text-neutral-500 font-mono mt-1">
                    RGB({c.rgb})
                  </p>
                  <p className="text-sm text-neutral-700 font-sans mt-3">
                    {c.usage}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Typography Showcase */}
        <div>
          <div className="mb-10">
            <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase">
              FOUNDRY
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-black mt-1">
              TYPOGRAPHIC HIERARCHY
            </h2>
          </div>

          <div className="border-4 border-black bg-[#FFFFEB] p-8 sm:p-12 shadow-[8px_8px_0px_#000000] space-y-10">
            {/* Pixelify Sans */}
            <div className="border-b-2 border-neutral-300 pb-8">
              <div className="flex items-center justify-between gap-4 mb-2">
                <span className="font-mono text-xs text-[#FF0000] uppercase font-bold">
                  PRIMARY BRAND FONT: PIXELIFY SANS
                </span>
                <span className="text-xs font-mono text-neutral-500">
                  font-pixel
                </span>
              </div>
              <p className="font-pixel text-4xl sm:text-6xl font-bold tracking-wider text-black">
                PAY. TRACK. GROW.
              </p>
              <p className="font-pixel text-base sm:text-lg text-neutral-600 mt-2">
                The quick brown fox jumps over the lazy dog 0123456789
              </p>
            </div>

            {/* Doto Font */}
            <div>
              <div className="flex items-center justify-between gap-4 mb-2">
                <span className="font-mono text-xs text-[#62D800] uppercase font-bold">
                  METRICS & NUMERICS: DOTO FONT
                </span>
                <span className="text-xs font-mono text-neutral-500">
                  font-doto
                </span>
              </div>
              <p className="font-doto text-4xl sm:text-6xl font-black text-black">
                $1,489,230.00 / 99.98% SLA
              </p>
              <p className="font-doto text-base sm:text-lg text-neutral-600 mt-2">
                FAST DATA MATRICES & SETTLEMENT COUNTERS
              </p>
            </div>
          </div>
        </div>

        {/* Vector Badge Glyphs */}
        <div>
          <div className="mb-10">
            <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase">
              ICONOGRAPHY & GLYPHS
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-black mt-1">
              PIXEL BADGE MOTIFS
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-black text-white p-8 border-4 border-black rounded-[20px] flex flex-col items-center text-center">
              <div className="w-28 h-28 flex items-center justify-center mb-6">
                <Frame145Badge className="w-full h-full object-contain" />
              </div>
              <h3 className="text-xl font-bold mb-2">Frame 145: Scan Code</h3>
              <p className="text-xs text-neutral-400 font-sans">
                Dynamic QR matrix with reactive finder brackets that animate to terminal lime on scroll trigger.
              </p>
            </div>

            <div className="bg-black text-white p-8 border-4 border-black rounded-[20px] flex flex-col items-center text-center">
              <div className="w-28 h-28 flex items-center justify-center mb-6">
                <Frame143Badge className="w-full h-full object-contain" />
              </div>
              <h3 className="text-xl font-bold mb-2">Frame 143: Secure Chevron</h3>
              <p className="text-xs text-neutral-400 font-sans">
                Double descending directional chevron representing transaction validation and verification.
              </p>
            </div>

            <div className="bg-black text-white p-8 border-4 border-black rounded-[20px] flex flex-col items-center text-center">
              <div className="w-28 h-28 flex items-center justify-center mb-6">
                <Frame144Badge className="w-full h-full object-contain" />
              </div>
              <h3 className="text-xl font-bold mb-2">Frame 144: Visual Shield</h3>
              <p className="text-xs text-neutral-400 font-sans">
                Eight-point starburst inside geometric shield for insights, analytics, and visual synthesis.
              </p>
            </div>
          </div>
        </div>

        {/* Figma Design View */}
        <div>
          <div className="mb-10">
            <span className="text-xs font-bold tracking-widest text-neutral-500 uppercase">
              SPECIFICATION & CANVAS
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-black mt-1">
              FIGMA DESIGN VIEW
            </h2>
          </div>

          <div className="w-full border-4 border-black bg-neutral-50 shadow-[8px_8px_0px_#000000] p-3 sm:p-6 rounded-[12px] overflow-hidden">
            <div className="w-full relative aspect-[16/9] min-h-[450px] sm:min-h-[550px] md:min-h-[650px] rounded-[6px] overflow-hidden border border-black/10">
              <iframe
                className="w-full h-full border-0 absolute inset-0"
                src="https://embed.figma.com/design/xBakmB5ztVqw1mj0lmRTvr/HulyPay?embed-host=share"
                allowFullScreen
              />
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
