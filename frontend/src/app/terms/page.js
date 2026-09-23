import Navbar from "@/components/landing/Navbar";
import Footer from "@/components/landing/Footer";
import PageBanner from "@/components/common/PageBanner";
import Link from "next/link";

export const metadata = {
  title: "Terms of Service - HulyPay",
  description: "Terms of service, open-source license information, and financial disclaimers for using HulyPay.",
};

export default function TermsPage() {
  return (
    <main className="min-h-screen bg-white w-full flex flex-col font-pixel">
      <Navbar />

      <PageBanner
        tag="LEGAL"
        title="TERMS OF SERVICE &amp; SOFTWARE LICENSE"
        subtitle="Last revised: September 2026. Please read these terms carefully prior to using the HulyPay client or related tools."
        accentColor="#EF4444"
      />

      <section className="w-full max-w-[1000px] mx-auto px-6 sm:px-10 lg:px-16 py-16 sm:py-24">
        {/* Open Source License Box */}
        <div className="p-8 border-4 border-black bg-neutral-50 shadow-[6px_6px_0px_#000000] mb-12">
          <div className="flex items-center justify-between gap-4 mb-2">
            <span className="font-bold text-base sm:text-lg text-black uppercase tracking-wider">
              OPEN SOURCE SOFTWARE LICENSE
            </span>
            <span className="font-mono text-xs font-bold bg-black text-white px-2 py-0.5">
              MIT / APACHE 2.0
            </span>
          </div>
          <p className="font-sans text-base sm:text-lg text-neutral-800 leading-relaxed">
            HulyPay is distributed as free, open-source software. You are free to
            inspect, modify, fork, or run your own private instances subject to
            standard open-source licensing terms.
          </p>
        </div>

        {/* Detailed Terms */}
        <div className="space-y-12 text-black font-sans">
          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              1. Non-Custodial Financial Disclaimer
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              HulyPay is an interface and personal bookkeeping utility. HulyPay
              is NOT a bank, credit union, depository institution, or money
              transmitter. HulyPay never holds, custodies, transfers, or escrows
              your funds. When you scan a QR code to make a payment, the actual
              settlement is executed exclusively by your authorized banking or UPI
              applications.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              2. Acceptable Use
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              You agree to use HulyPay solely for lawful personal or business
              expense tracking purposes. You may not utilize the software or its
              APIs in connection with unlawful financial structuring, fraudulent
              transaction masking, or money laundering activities.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              3. Disclaimer of Warranties
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg font-mono text-sm bg-neutral-100 p-4 border-2 border-neutral-300">
              THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY
              KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
              OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
              NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
              BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              4. Accuracy of Calculations &amp; Reporting
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              While HulyPay strives to accurately parse notification messages and
              generate precise spending graphs, parsing anomalies or bank format
              changes may occasionally occur. You remain solely responsible for
              verifying your official bank account statements and tax obligations.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              5. Modifications to Terms &amp; Software
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              As an open-source project, HulyPay evolves continuously. We reserve
              the right to update these terms as new features or protocol bridges
              are introduced. Continued use of the application indicates your
              acceptance of any updated guidelines.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="font-pixel text-2xl sm:text-3xl font-bold tracking-tight text-black">
              6. Contact &amp; Community Governance
            </h2>
            <p className="text-neutral-700 leading-relaxed text-base sm:text-lg">
              For security disclosures or legal inquiries, reach out through our
              official GitHub repository at{" "}
              <a
                href="https://github.com/Lovedragn/Huly-Pay"
                target="_blank"
                rel="noopener noreferrer"
                className="text-[#FF0000] underline font-pixel font-bold"
              >
                github.com/Lovedragn/Huly-Pay
              </a>
              .
            </p>
          </section>
        </div>
      </section>

      <Footer />
    </main>
  );
}
