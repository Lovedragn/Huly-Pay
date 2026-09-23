import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";
import QrToTickAnimation from "../../../public/assets/feature/QrToTickAnimation";
import BellNotificationAnimation from "../../../public/assets/feature/BellNotificationAnimation";
import WifiOfflineAnimation from "../../../public/assets/feature/WifiOfflineAnimation";
import LockJwtAnimation from "../../../public/assets/feature/LockJwtAnimation";
import PieChartAnimation from "../../../public/assets/feature/PieChartAnimation";
import { EXTERNAL_LINKS } from "@/assets/external_data";

export const metadata = {
  title: "Features - HulyPay",
  description: "Explore the core features of HulyPay: QR Scan & Pay, Instant Notifications, Offline-first, JWT security, and Pie Charts.",
};

const FEATURE_LIST = [
  {
    id: "qr-scan",
    tag: "SCANNING",
    title: "QR SCAN & INSTANT PAY",
    description:
      "Integrated scanner designed for high-density, low-contrast, and damaged merchant QR codes. Seamlessly bridges your local payments directly with UPI, banking apps, and decentralized payment rails.",
    highlights: [
      "Hardware-accelerated live camera viewfinder",
      "Instant decode & auto-redirect to payment app",
      "Automatic receipt and transaction extraction",
      "Saved favorite merchant QR codes",
    ],
    animation: <QrToTickAnimation />,
    accent: "#62D800",
  },
  {
    id: "notifications",
    tag: "PARSING",
    title: "INTELLIGENT NOTIFICATION PARSING",
    description:
      "Background listener that detects payment notifications emitted by payment gateways, bank SMS, and finance apps. It automatically parses merchant names, reference IDs, and spent amounts without manual user input.",
    highlights: [
      "Real-time background listener with zero cloud transmission",
      "Smart regex & NLP matching for multi-bank formats",
      "Zero battery drain via efficient OS broadcast receivers",
      "Deduplication against manual QR entries",
    ],
    animation: <BellNotificationAnimation />,
    accent: "#D8FF00",
  },
  {
    id: "offline-first",
    tag: "STORAGE",
    title: "TRUE OFFLINE-FIRST ARCHITECTURE",
    description:
      "Never lose track of your expenses when subterranean or offline. HulyPay writes every single transaction to local SQLite storage instantly, and provides conflict-free sync when you regain internet access.",
    highlights: [
      "Sub-millisecond local write latency",
      "Encrypted SQLite on-device database",
      "Automatic background sync with delta changes",
      "Conflict-free replicated data merge logic",
    ],
    animation: <WifiOfflineAnimation />,
    accent: "#38BDF8",
  },
  {
    id: "jwt-auth",
    tag: "SECURITY",
    title: "AUTHENTICATION & CRYPTO TOKENS",
    description:
      "End-to-end user isolation with cryptographic tokens and secure JWT session handling. Your private financial metrics belong solely to you, protected with industry-standard cryptographic algorithms.",
    highlights: [
      "Hardware Keystore backed token encryption",
      "Biometric app lock (Fingerprint / Face ID)",
      "Zero telemetry & zero third-party trackers",
      "Cryptographically signed payload exchanges",
    ],
    animation: <LockJwtAnimation />,
    accent: "#EF4444",
  },
  {
    id: "smart-charts",
    tag: "ANALYTICS",
    title: "SPENDING VISUALS & PIE CHARTS",
    description:
      "Transform flat transaction logs into actionable visual intelligence. Category breakdown, weekly burn rates, merchant heatmaps, and dot-matrix visual summaries at a glance.",
    highlights: [
      "Interactive SVG pie charts & trend lines",
      "Automated categorization (Groceries, Tech, Food, Bills)",
      "Monthly budget caps & threshold alerts",
      "One-click CSV and JSON data export",
    ],
    animation: <PieChartAnimation />,
    accent: "#FF00F5",
  },
];

export default function FeaturesPage() {
  return (
    <main className="min-h-screen bg-[#FFFFEB] w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="CAPABILITIES"
        title="BUILT FOR SPEED. ENGINEERED FOR CLARITY."
        subtitle="HulyPay combines frictionless mobile payment scanning, zero-latency local-first data storage, and crisp visual spending metrics into one open-source package."
        accentColor="#FF0000"
      />

      {/* Main Features Deep-Dive Section */}
      <section className="w-full max-w-[1440px] mx-auto px-4 sm:px-10 lg:px-16 py-10 sm:py-24">
        <div className="space-y-10 sm:space-y-24">
          {FEATURE_LIST.map((feat, idx) => (
            <div
              key={feat.id}
              className="bg-white border-4 border-black rounded-[20px] sm:rounded-[32px] p-5 sm:p-10 lg:p-12 shadow-[6px_6px_0px_#000000] sm:shadow-[8px_8px_0px_#000000] flex flex-col lg:flex-row items-center justify-between gap-6 sm:gap-10 hover:-translate-y-1 transition-transform"
            >
              {/* Left Column: Details */}
              <div className="flex-1 w-full">
                <div className="flex items-center gap-3 mb-4">
                  <span className="font-doto text-xl font-black text-black">
                    0{idx + 1}
                  </span>
                  <span
                    className="text-xs uppercase tracking-widest px-2.5 py-0.5 border border-black font-semibold text-black"
                    style={{ backgroundColor: `${feat.accent}33` }}
                  >
                    {feat.tag}
                  </span>
                </div>

                <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold tracking-tight text-black mb-4">
                  {feat.title}
                </h2>

                <p className="text-base sm:text-lg text-neutral-700 leading-relaxed mb-6 font-sans">
                  {feat.description}
                </p>

                <div className="space-y-2.5 border-t border-neutral-200 pt-6">
                  <h3 className="text-sm font-bold tracking-wider text-black uppercase mb-3">
                    Key Highlights:
                  </h3>
                  {feat.highlights.map((item, i) => (
                    <div key={i} className="flex items-start gap-3">
                      <span className="w-2 h-2 bg-black mt-2 shrink-0" />
                      <span className="text-sm sm:text-base text-neutral-800">
                        {item}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Right Column: Visual Animation Component */}
              <div className="w-full lg:w-[420px] h-[220px] sm:h-[280px] lg:h-[320px] bg-[#E6E6E6] border-2 border-black rounded-[14px] sm:rounded-[18px] flex items-center justify-center p-4 sm:p-6 shrink-0 relative overflow-hidden">
                <div className="scale-85 sm:scale-100 flex items-center justify-center">
                  {feat.animation}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA Card */}
        <div className="mt-14 sm:mt-20 bg-black text-white border-4 border-black rounded-[20px] sm:rounded-[28px] p-6 sm:p-14 text-center flex flex-col items-center">
          <h2 className="font-doto text-2xl sm:text-5xl font-black tracking-wide mb-3 sm:mb-4">
            EXPERIENCE HULYPAY TODAY
          </h2>
          <p className="text-neutral-400 max-w-xl text-sm sm:text-lg mb-6 sm:mb-8 font-sans">
            Download the Android release or build directly from our open-source
            GitHub repository.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 sm:gap-4 w-full sm:w-auto">
            <a
              href={EXTERNAL_LINKS.downloads.androidApk}
              download={EXTERNAL_LINKS.downloads.apkFilename}
              className="w-full sm:w-auto text-center px-6 sm:px-8 py-3 sm:py-3.5 bg-[#FF0000] text-white font-bold text-sm sm:text-base hover:bg-[#CC0000] transition-colors rounded-none shadow-[4px_4px_0px_#FFFFFF]"
            >
              DOWNLOAD APK
            </a>
            <a
              href={EXTERNAL_LINKS.social.github}
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto text-center px-6 sm:px-8 py-3 sm:py-3.5 bg-white text-black font-bold text-sm sm:text-base hover:bg-neutral-200 transition-colors rounded-none shadow-[4px_4px_0px_#FF0000]"
            >
              VIEW ON GITHUB
            </a>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
