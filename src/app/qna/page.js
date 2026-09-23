"use client";

import { useState } from "react";
import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";
import { EXTERNAL_LINKS } from "@/assets/external_data";

const FAQ_DATA = [
  {
    category: "General",
    questions: [
      {
        q: "What exactly is HulyPay?",
        a: "HulyPay is a self-sovereign, open-source personal payment scanner and expense analytics application. It allows you to scan merchant QR codes, bridge into your payment apps, detect bank SMS/push notifications automatically, and view rich visual charts—all without surrendering your private financial data to third-party ad networks.",
      },
      {
        q: "Is HulyPay free and open source?",
        a: "Yes! HulyPay is 100% free and open-source under a permissive license. The source code is publicly accessible on GitHub, allowing anyone to audit the security, contribute features, or self-host their own backend sync instance.",
      },
      {
        q: "Which platforms are currently supported?",
        a: "We currently provide a native Android APK build with full background notification listener support. An iOS companion app and cross-platform desktop developer tools are currently in active development.",
      },
    ],
  },
  {
    category: "Privacy & Storage",
    questions: [
      {
        q: "Does HulyPay send my bank details or notifications to external servers?",
        a: "No. The notification parser executes 100% on-device using local regular expressions and pattern matching. Your transaction data is written to an encrypted local SQLite database. No logs, device IDs, or SMS texts are uploaded or sold to data brokers.",
      },
      {
        q: "How does offline-first mode work?",
        a: "All operations—including logging payments, updating categories, viewing pie charts, and generating reports—run directly against your local database. When you have internet connectivity, optional background synchronization syncs delta updates with your self-hosted or authenticated HulyPay server.",
      },
      {
        q: "Can I export or delete all my data?",
        a: "Absolutely. You can export your full transaction log into CSV or JSON format at any time from the settings screen. You can also wipe the local database with one tap.",
      },
    ],
  },
  {
    category: "Security & Permissions",
    questions: [
      {
        q: "Why does HulyPay request notification access on Android?",
        a: "Notification access is strictly required to detect payment receipts emitted by apps like Google Pay, PhonePe, Paytm, or bank SMS alerts. This enables automatic expense tracking without tedious manual data entry.",
      },
      {
        q: "How does JWT authentication work with the dashboard?",
        a: "Sessions with the web dashboard or sync endpoints are secured via industry-standard JSON Web Tokens (JWT). Private keys and authorization tokens are stored in the device's hardware-backed Keystore / Keychain.",
      },
      {
        q: "What happens if I lose my phone?",
        a: "Your local database is encrypted with hardware-backed keys. If you use biometric lock (fingerprint/face), nobody can open your transaction history without your biometric verification.",
      },
    ],
  },
];

export default function QnaPage() {
  const [activeCategory, setActiveCategory] = useState("General");
  const [openItems, setOpenItems] = useState({ "General-0": true });

  const toggleItem = (key) => {
    setOpenItems((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  const currentQuestions =
    FAQ_DATA.find((cat) => cat.category === activeCategory)?.questions || [];

  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="KNOWLEDGE BASE"
        title="QUESTIONS & ANSWERS"
        subtitle="Everything you need to know about HulyPay architecture, local privacy guarantees, supported platforms, and setup."
        accentColor="#D8FF00"
      />

      <section className="w-full max-w-[1200px] mx-auto px-4 sm:px-10 lg:px-16 py-10 sm:py-24">
        {/* Category Tabs */}
        <div className="flex flex-wrap gap-2 sm:gap-3 mb-8 sm:mb-12">
          {FAQ_DATA.map((cat) => {
            const isActive = activeCategory === cat.category;
            return (
              <button
                key={cat.category}
                type="button"
                onClick={() => setActiveCategory(cat.category)}
                className={`px-4 py-2 sm:px-6 sm:py-3 font-pixel text-xs sm:text-base font-bold transition-all border-2 border-black cursor-pointer select-none ${
                  isActive
                    ? "bg-black text-white shadow-[3px_3px_0px_#FF0000] sm:shadow-[4px_4px_0px_#FF0000]"
                    : "bg-white text-black hover:bg-neutral-100"
                }`}
              >
                {cat.category}
              </button>
            );
          })}
        </div>

        {/* Questions Accordion List */}
        <div className="space-y-3 sm:space-y-4">
          {currentQuestions.map((item, idx) => {
            const itemKey = `${activeCategory}-${idx}`;
            const isOpen = !!openItems[itemKey];

            return (
              <div
                key={idx}
                className="border-[3px] sm:border-4 border-black bg-white shadow-[4px_4px_0px_#000000] sm:shadow-[6px_6px_0px_#000000] overflow-hidden transition-all"
              >
                <button
                  type="button"
                  onClick={() => toggleItem(itemKey)}
                  className="w-full px-4 sm:px-8 py-3.5 sm:py-6 flex items-center justify-between text-left gap-3 sm:gap-4 hover:bg-neutral-50 cursor-pointer select-none"
                >
                  <span className="font-pixel text-base sm:text-2xl font-bold text-black leading-snug">
                    {item.q}
                  </span>
                  <div
                    className={`w-7 h-7 sm:w-8 sm:h-8 rounded-full border-2 border-black flex items-center justify-center shrink-0 font-mono text-base sm:text-lg font-bold transition-transform ${
                      isOpen ? "bg-[#FF0000] text-white rotate-45" : "bg-neutral-100 text-black"
                    }`}
                  >
                    +
                  </div>
                </button>

                {isOpen && (
                  <div className="px-4 sm:px-8 pb-4 sm:pb-8 pt-2 border-t-2 border-dashed border-neutral-200">
                    <p className="font-sans text-sm sm:text-lg text-neutral-700 leading-relaxed">
                      {item.a}
                    </p>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Community Help Card */}
        <div className="mt-12 sm:mt-16 p-5 sm:p-8 border-[3px] sm:border-4 border-black bg-[#FFFFEB] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 sm:gap-6 shadow-[4px_4px_0px_#000000] sm:shadow-none">
          <div>
            <h3 className="font-pixel text-lg sm:text-2xl font-bold text-black">
              Have another question not answered here?
            </h3>
            <p className="font-sans text-xs sm:text-base text-neutral-600 mt-1">
              Open an issue or start a discussion on our community repository.
            </p>
          </div>
          <a
            href={`${EXTERNAL_LINKS.social.github}/issues`}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto text-center px-6 py-3 bg-black text-white font-pixel font-bold text-xs sm:text-sm hover:bg-neutral-800 transition-colors shrink-0 shadow-[4px_4px_0px_#CC0000]"
          >
            ASK ON GITHUB
          </a>
        </div>
      </section>

      <Footer />
    </main>
  );
}
