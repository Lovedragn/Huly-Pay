import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";

export const metadata = {
  title: "Privacy & Terms - HulyPay",
  description:
    "Review HulyPay's zero-knowledge privacy policy, local-first data architecture, open-source software license, and terms of service.",
};

export default function PrivacyAndTermsPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="LEGAL & GOVERNANCE"
        title="PRIVACY & TERMS"
        subtitle="Last revised: September 2026. Everything you need to know about our local-first privacy architecture, open-source license, and terms of use."
        accentColor="#62D800"
      />

      <section className="w-full max-w-[1000px] mx-auto px-4 sm:px-10 lg:px-16 py-10 sm:py-24 space-y-12 sm:space-y-16">
        {/* Quick Summary Highlights */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
          {/* Privacy Callout */}
          <div className="p-5 sm:p-8 border-[3px] sm:border-4 border-black bg-[#FFFFEB] shadow-[4px_4px_0px_#000000] sm:shadow-[6px_6px_0px_#000000] flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-2 mb-3">
                <span className="w-3 h-3 bg-[#62D800] rounded-full inline-block" />
                <span className="font-bold text-sm sm:text-base text-black uppercase tracking-wider">
                  Zero-Knowledge Commitment
                </span>
              </div>
              <p className="font-sans text-sm sm:text-base text-neutral-800 leading-relaxed">
                HulyPay never harvests, stores, or sells your transaction logs or
                financial details. All parsing and metrics calculation execute
                strictly inside your device&apos;s memory.
              </p>
            </div>
            <a
              href="#privacy-policy"
              className="mt-6 inline-flex items-center gap-2 font-pixel text-xs sm:text-sm font-bold text-black uppercase tracking-wider underline hover:text-[#62D800] transition-colors"
            >
              Jump to Privacy Policy &darr;
            </a>
          </div>

          {/* Terms Callout */}
          <div className="p-5 sm:p-8 border-[3px] sm:border-4 border-black bg-neutral-50 shadow-[4px_4px_0px_#000000] sm:shadow-[6px_6px_0px_#000000] flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between gap-2 mb-3">
                <span className="font-bold text-sm sm:text-base text-black uppercase tracking-wider">
                  Open-Source &amp; Non-Custodial
                </span>
                <span className="font-mono text-xs font-bold bg-black text-white px-2 py-0.5">
                  MIT LICENSE
                </span>
              </div>
              <p className="font-sans text-sm sm:text-base text-neutral-800 leading-relaxed">
                HulyPay is a self-custody bookkeeping client. We do not hold,
                custody, or transmit money. Payment settlements occur directly
                through your banking and UPI apps.
              </p>
            </div>
            <a
              href="#terms-of-service"
              className="mt-6 inline-flex items-center gap-2 font-pixel text-xs sm:text-sm font-bold text-black uppercase tracking-wider underline hover:text-[#EF4444] transition-colors"
            >
              Jump to Terms of Service &darr;
            </a>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* SECTION 1: PRIVACY POLICY */}
        {/* ========================================================================= */}
        <div id="privacy-policy" className="pt-8 border-t-2 border-black/10">
          <div className="flex items-center gap-3 mb-6">
            <span className="px-3 py-1 bg-[#62D800] text-black font-pixel font-bold text-xs uppercase tracking-wider">
              Part I
            </span>
            <h2 className="font-pixel text-2xl sm:text-4xl font-bold tracking-tight text-black">
              PRIVACY POLICY
            </h2>
          </div>

          <div className="space-y-10 text-black font-sans">
            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                1. Information We DO NOT Collect
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                Unlike traditional fintech apps, HulyPay does not maintain a
                central database of your bank transactions, account balances,
                merchant names, or contact lists. We do not use third-party
                analytics trackers, behavioral ad SDKs (such as Facebook Pixel,
                Google AdMob, or AppsFlyer), or fingerprinting scripts.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                2. On-Device Processing &amp; Notification Access
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                On Android, HulyPay requests notification listening permission
                solely to extract payment confirmations emitted by your banking or
                UPI applications. This parsing happens entirely within your
                device&apos;s local memory space. The parsed contents are
                immediately stored into an on-device encrypted SQLite database.
                None of this data is transmitted over the internet during normal
                usage.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                3. Device Camera Permission
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                The camera viewfinder is activated strictly when you open the QR
                scanner. Camera image streams are processed locally in real-time
                to detect QR barcode matrices and are never recorded, saved to
                disk, or uploaded to any remote server.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                4. Optional Cloud Synchronization
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                If you choose to enable cloud sync or connect with a self-hosted
                HulyPay backend instance, all network payloads are transmitted
                over TLS with authenticated JSON Web Tokens (JWT). You retain
                full ownership of your server credentials and encryption keys.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                5. Data Retention &amp; Right to Erasure
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                Because your data resides on your phone, you have 100% control
                over it at all times. Uninstalling the app or selecting
                &quot;Clear Database&quot; in settings completely and
                irreversibly removes all stored records from your device storage.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                6. Open Source Verification
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                You do not have to take our word for it. All source code is open
                and publicly inspectable at{" "}
                <a
                  href="https://github.com/Lovedragn/Huly-Pay"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#FF0000] underline font-pixel font-bold hover:text-black transition-colors break-all"
                >
                  github.com/Lovedragn/Huly-Pay
                </a>
                . Anyone can compile and audit the application directly from
                source.
              </p>
            </section>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* SECTION 2: TERMS OF SERVICE */}
        {/* ========================================================================= */}
        <div id="terms-of-service" className="pt-12 border-t-4 border-black">
          <div className="flex items-center gap-3 mb-6">
            <span className="px-3 py-1 bg-[#EF4444] text-white font-pixel font-bold text-xs uppercase tracking-wider">
              Part II
            </span>
            <h2 className="font-pixel text-2xl sm:text-4xl font-bold tracking-tight text-black">
              TERMS OF SERVICE
            </h2>
          </div>

          <div className="space-y-10 text-black font-sans">
            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                1. Non-Custodial Financial Disclaimer
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                HulyPay is an interface and personal bookkeeping utility.
                HulyPay is NOT a bank, credit union, depository institution, or
                money transmitter. HulyPay never holds, custodies, transfers, or
                escrows your funds. When you scan a QR code to make a payment,
                the actual settlement is executed exclusively by your authorized
                banking or UPI applications.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                2. Acceptable Use
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                You agree to use HulyPay solely for lawful personal or business
                expense tracking purposes. You may not utilize the software or
                its APIs in connection with unlawful financial structuring,
                fraudulent transaction masking, or money laundering activities.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                3. Disclaimer of Warranties
              </h3>
              <p className="text-neutral-700 leading-relaxed text-xs sm:text-base font-mono bg-neutral-100 p-3 sm:p-4 border-2 border-neutral-300 break-words">
                THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF
                ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
                WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
                AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                4. Accuracy of Calculations &amp; Reporting
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                While HulyPay strives to accurately parse notification messages
                and generate precise spending graphs, parsing anomalies or bank
                format changes may occasionally occur. You remain solely
                responsible for verifying your official bank account statements
                and tax obligations.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                5. Modifications to Terms &amp; Software
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                As an open-source project, HulyPay evolves continuously. We
                reserve the right to update these terms as new features or
                protocol bridges are introduced. Continued use of the
                application indicates your acceptance of any updated
                guidelines.
              </p>
            </section>

            <section className="space-y-3">
              <h3 className="font-pixel text-xl sm:text-2xl font-bold tracking-tight text-black">
                6. Contact &amp; Community Governance
              </h3>
              <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
                For security disclosures or legal inquiries, reach out through
                our official GitHub repository at{" "}
                <a
                  href="https://github.com/Lovedragn/Huly-Pay"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#FF0000] underline font-pixel font-bold hover:text-black transition-colors"
                >
                  github.com/Lovedragn/Huly-Pay
                </a>
                .
              </p>
            </section>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
