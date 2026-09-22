"use client";

import Link from "next/link";
import Image from "next/image";

export default function DashboardPage() {
  return (
    <div className="min-h-screen bg-white font-pixel flex flex-col">
      {/* Top Navbar */}
      <header className="w-full border-b border-[#D4D4D8] bg-white h-20 flex items-center justify-between px-6 sm:px-10 lg:px-16 sticky top-0 z-40">
        <div className="flex items-center gap-3">
          <div className="w-7 h-7 relative flex items-center justify-center">
            <Image
              src="/assets/logo-Light.svg"
              alt="Huly Pay Logo"
              width={28}
              height={28}
              className="w-7 h-7 object-contain"
            />
          </div>
          <span className="text-xl tracking-wider text-black select-none">
            HULYPAY
          </span>
          <span className="text-xs bg-neutral-100 text-neutral-600 px-2 py-0.5 rounded border border-neutral-300 ml-2">
            Dashboard
          </span>
        </div>

        {/* Back to Home Navigation Button (triggers Codegrid GSAP Page Transition) */}
        <Link
          href="/"
          className="flex items-center gap-2 px-4 py-2 bg-black text-white text-[13px] hover:bg-neutral-800 transition-colors cursor-pointer select-none"
        >
          <svg
            className="w-4 h-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
          <span>Back to Landing</span>
        </Link>
      </header>

      {/* Main Dashboard Content */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-6 sm:p-10">
        {/* Welcome Section */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight text-neutral-900">
            Overview
          </h1>
          <p className="text-sm text-neutral-500 mt-1">
            Real-time balance, payments, and global settlement stream.
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="p-5 border border-[#D4D4D8] bg-neutral-50 rounded-none">
            <span className="text-xs text-neutral-500 uppercase tracking-wider block">
              Total Volume
            </span>
            <div className="text-2xl font-bold text-black mt-2 font-mono">
              $1,489,230.00
            </div>
            <span className="text-xs text-emerald-600 mt-1 block">
              +14.2% from last month
            </span>
          </div>

          <div className="p-5 border border-[#D4D4D8] bg-neutral-50 rounded-none">
            <span className="text-xs text-neutral-500 uppercase tracking-wider block">
              Active Streams
            </span>
            <div className="text-2xl font-bold text-black mt-2 font-mono">
              2,841
            </div>
            <span className="text-xs text-emerald-600 mt-1 block">
              +8.7% new users
            </span>
          </div>

          <div className="p-5 border border-[#D4D4D8] bg-neutral-50 rounded-none">
            <span className="text-xs text-neutral-500 uppercase tracking-wider block">
              Success Rate
            </span>
            <div className="text-2xl font-bold text-black mt-2 font-mono">
              99.98%
            </div>
            <span className="text-xs text-neutral-500 mt-1 block">
              Global SLA tier 1
            </span>
          </div>

          <div className="p-5 border border-[#D4D4D8] bg-neutral-50 rounded-none">
            <span className="text-xs text-neutral-500 uppercase tracking-wider block">
              Settlement Speed
            </span>
            <div className="text-2xl font-bold text-black mt-2 font-mono">
              ~420ms
            </div>
            <span className="text-xs text-emerald-600 mt-1 block">
              Instant on Solana/Base
            </span>
          </div>
        </div>

        {/* Recent Transactions Table Preview */}
        <div className="border border-[#D4D4D8]">
          <div className="px-6 py-4 border-b border-[#D4D4D8] flex items-center justify-between">
            <h2 className="text-base font-semibold text-black">
              Recent Transactions
            </h2>
            <span className="text-xs text-neutral-400">Live feed</span>
          </div>
          <div className="divide-y divide-neutral-200 text-sm">
            {[
              { id: "TX-9902", from: "0x8F...392A", amount: "$3,400.00", status: "Settled", time: "2 mins ago" },
              { id: "TX-9901", from: "0x2A...810B", amount: "$150.00", status: "Settled", time: "5 mins ago" },
              { id: "TX-9900", from: "0x7C...99DF", amount: "$12,850.00", status: "Settled", time: "12 mins ago" },
              { id: "TX-9899", from: "0x11...44CA", amount: "$780.00", status: "Settled", time: "18 mins ago" },
            ].map((tx) => (
              <div key={tx.id} className="px-6 py-4 flex items-center justify-between hover:bg-neutral-50">
                <div className="flex items-center gap-4">
                  <span className="font-mono text-xs font-semibold text-black">{tx.id}</span>
                  <span className="text-xs text-neutral-500 font-mono">{tx.from}</span>
                </div>
                <div className="flex items-center gap-6">
                  <span className="font-mono font-semibold text-black">{tx.amount}</span>
                  <span className="text-xs px-2 py-0.5 bg-emerald-50 text-emerald-700 border border-emerald-200">
                    {tx.status}
                  </span>
                  <span className="text-xs text-neutral-400 hidden sm:inline">{tx.time}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
