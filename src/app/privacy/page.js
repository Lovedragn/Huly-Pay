import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";

export const metadata = {
  title: "Privacy Policy - HulyPay",
  description: "Learn about HulyPay's zero-tracker, local-first data architecture and how your financial privacy is protected.",
};

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="DATA GOVERNANCE"
        title="PRIVACY POLICY & ZERO-KNOWLEDGE PLEDGE"
        subtitle="Last revised: September 2026. HulyPay is designed from the ground up to respect your financial sovereignty."
        accentColor="#62D800"
      />

      <section className="w-full max-w-[1000px] mx-auto px-6 sm:px-10 lg:px-16 py-16 sm:py-24">
        {/* Core Guarantee Callout */}
        <div className="p-8 border-4 border-black bg-[#FFFFEB] shadow-[6px_6px_0px_#000000] mb-12">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-3 h-3 bg-[#62D800] rounded-full inline-block" />
            <span className="font-bold text-base sm:text-lg text-black uppercase tracking-wider">
              OUR PRIVACY COMMITMENT
            </span>
          </div>
          <p className="font-sans text-base sm:text-lg text-neutral-800 leading-relaxed">
            HulyPay does not harvest, store, or monetize your payment histories,
            device IDs, or personal financial details. We operate on a strict
            local-first model: your data remains on your physical hardware.
          </p>
        </div>

        {/* Detailed Policy Sections */}
        <div className="space-y-12 text-black font-sans">
          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              1. Information We DO NOT Collect
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              Unlike traditional fintech apps, HulyPay does not maintain a central
              database of your bank transactions, account balances, merchant names,
              or contact lists. We do not use third-party analytics trackers,
              behavioral adSDKs (such as Facebook Pixel, Google AdMob, or AppsFlyer),
              or fingerprinting scripts.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              2. On-Device Processing &amp; Notification Access
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              On Android, HulyPay requests notification listening permission
              solely to extract payment confirmations emitted by your banking or
              UPI applications. This parsing happens entirely within your device&apos;s
              local memory space. The parsed contents are immediately stored into an
              on-device encrypted SQLite database. None of this data is transmitted
              over the internet during normal usage.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              3. Device Camera Permission
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              The camera viewfinder is activated strictly when you open the QR
              scanner. Camera image streams are processed locally in real-time
              to detect QR barcode matrices and are never recorded, saved to disk,
              or uploaded to any remote server.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              4. Optional Cloud Synchronization
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              If you choose to enable cloud sync or connect with a self-hosted
              HulyPay backend instance, all network payloads are transmitted over
              TLS with authenticated JSON Web Tokens (JWT). You retain full
              ownership of your server credentials and encryption keys.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              5. Data Retention &amp; Right to Erasure
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              Because your data resides on your phone, you have 100% control over
              it at all times. Uninstalling the app or selecting &quot;Clear Database&quot;
              in settings completely and irreversibly removes all stored records
              from your device storage.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              6. Open Source Verification
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              You do not have to take our word for it. All source code is open
              and publicly inspectable at{" "}
              <a
                href="https://github.com/Lovedragn/Huly-Pay"
                target="_blank"
                rel="noopener noreferrer"
                className="text-[#FF0000] underline font-pixel font-bold"
              >
                github.com/Lovedragn/Huly-Pay
              </a>
              . Anyone can compile and audit the application directly from source.
            </p>
          </section>
        </div>
      </section>

      <Footer />
    </main>
  );
}
