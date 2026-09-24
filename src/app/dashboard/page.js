"use client";

import * as React from "react";
import Link from "next/link";
import Image from "next/image";
import AreaChartSpending from "@/components/dashboard/AreaChartSpending";
import BarChartMonthly from "@/components/dashboard/BarChartMonthly";
import PieChartCategories from "@/components/dashboard/PieChartCategories";
import RadarChartPerformance from "@/components/dashboard/RadarChartPerformance";
import BackendStatusBar from "@/components/dashboard/BackendStatusBar";
import TransactionsTable from "@/components/dashboard/TransactionsTable";
import { useAuth } from "@/context/AuthContext";
import {
  syncAllDashboardData,
  getSpendingSummary,
  getCategoryBreakdown,
  getDailySpending,
  getMonthlySpending,
  getExpenses,
  MOCK_RADAR_METRICS,
} from "@/lib/api";

export default function DashboardPage() {
  const { user, isAuthenticated, signOut, session } = useAuth();
  const [summary, setSummary] = React.useState(null);
  const [categoryData, setCategoryData] = React.useState([]);
  const [dailyData, setDailyData] = React.useState([]);
  const [monthlyData, setMonthlyData] = React.useState([]);
  const [expenses, setExpenses] = React.useState([]);
  const [radarData, setRadarData] = React.useState(MOCK_RADAR_METRICS);
  const [selectedCategory, setSelectedCategory] = React.useState(null);
  const [dataSource, setDataSource] = React.useState("live_supabase");
  const [recordsCount, setRecordsCount] = React.useState(55);
  const [lastSynced, setLastSynced] = React.useState("");
  const [isLoading, setIsLoading] = React.useState(true);
  const [currency, setCurrency] = React.useState("INR");

  const handleRefresh = React.useCallback(async () => {
    setIsLoading(true);
    try {
      const token = session?.access_token || null;
      const userId = user?.id || null;
      const result = await syncAllDashboardData(token, userId);

      if (result) {
        setSummary(result.summary);
        setCategoryData(result.categoryData || []);
        setDailyData(result.dailyData || []);
        setMonthlyData(result.monthlyData || []);
        setExpenses(result.expenses || []);
        if (result.radarMetrics) setRadarData(result.radarMetrics);
        setDataSource(result.source || "live_supabase");
        setRecordsCount(result.recordsCount || result.expenses?.length || 0);
        setLastSynced(result.lastSynced || new Date().toLocaleTimeString());
      }
    } catch (err) {
      console.error("Dashboard sync error:", err);
    } finally {
      setIsLoading(false);
    }
  }, [session, user]);

  React.useEffect(() => {
    let ignore = false;

    async function loadData() {
      try {
        const token = session?.access_token || null;
        const userId = user?.id || null;
        const result = await syncAllDashboardData(token, userId);

        if (!ignore && result) {
          setSummary(result.summary);
          setCategoryData(result.categoryData || []);
          setDailyData(result.dailyData || []);
          setMonthlyData(result.monthlyData || []);
          setExpenses(result.expenses || []);
          if (result.radarMetrics) setRadarData(result.radarMetrics);
          setDataSource(result.source || "live_supabase");
          setRecordsCount(result.recordsCount || result.expenses?.length || 0);
          setLastSynced(result.lastSynced || new Date().toLocaleTimeString());
          setIsLoading(false);
        }
      } catch (err) {
        console.error("Failed to load initial sync data:", err);
        if (!ignore) {
          setIsLoading(false);
        }
      }
    }

    loadData();

    return () => {
      ignore = true;
    };
  }, [session, user]);

  // Format currency helpers
  const formatMoney = (val) => {
    if (!val && val !== 0) return currency === "INR" ? "₹0" : "$0.00";
    const num = Number(val) || 0;
    const isUnderlyingInr = summary?.currency === "INR";
    if (currency === "INR") {
      const inrVal = isUnderlyingInr ? num : Math.round(num * 83.5);
      return `₹${Math.round(inrVal).toLocaleString("en-IN")}`;
    }
    const usdVal = isUnderlyingInr ? num / 83.5 : num;
    return `$${usdVal.toLocaleString("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  };

  return (
    <div className="min-h-screen bg-[#FFFFEB]/40 font-pixel flex flex-col text-black antialiased selection:bg-[#FF0000] selection:text-white">
      {/* Top Cyberdeck Navbar */}
      <header className="w-full border-b-[3px] border-black bg-white h-16 sm:h-20 flex items-center justify-between px-4 sm:px-8 lg:px-12 sticky top-0 z-40">
        <div className="flex items-center gap-3 sm:gap-4">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-7 h-7 sm:w-8 sm:h-8 relative flex items-center justify-center shrink-0 border border-black bg-black p-1 shadow-[2px_2px_0px_#FF0000]">
              <Image
                src="/assets/logo-Light.svg"
                alt="Huly Pay Logo"
                width={32}
                height={32}
                className="w-full h-full object-contain invert"
              />
            </div>
            <span className="text-xl sm:text-2xl font-black tracking-wider text-black select-none">
              HULYPAY
            </span>
          </Link>
          <span className="text-xs font-mono font-bold bg-[#D8FF00] text-black px-2 py-0.5 border border-black shadow-[2px_2px_0px_#000000]">
            TERMINAL v2.4
          </span>
        </div>

        {/* Center Navigation Links */}
        <nav className="hidden md:flex items-center gap-1 font-mono text-xs">
          <Link
            href="/features"
            className="px-3 py-1.5 hover:bg-neutral-100 border border-transparent hover:border-black transition-colors"
          >
            Features
          </Link>
          <Link
            href="/design"
            className="px-3 py-1.5 hover:bg-neutral-100 border border-transparent hover:border-black transition-colors"
          >
            Design Spec
          </Link>
          <Link
            href="/tools"
            className="px-3 py-1.5 hover:bg-neutral-100 border border-transparent hover:border-black transition-colors"
          >
            Developer Tools
          </Link>
          <Link
            href="/qna"
            className="px-3 py-1.5 hover:bg-neutral-100 border border-transparent hover:border-black transition-colors"
          >
            Q&A
          </Link>
        </nav>

        {/* Right CTA */}
        <div className="flex items-center gap-2.5 sm:gap-3">
          {isAuthenticated ? (
            <div className="flex items-center gap-2 sm:gap-3">
              <div className="flex items-center gap-2 px-3 py-1.5 bg-neutral-100 border border-black font-mono text-xs">
                {user?.avatarUrl ? (
                  <Image
                    src={user.avatarUrl}
                    alt={user.fullName || "User"}
                    width={20}
                    height={20}
                    unoptimized
                    className="w-5 h-5 rounded-full object-cover"
                  />
                ) : (
                  <span className="w-5 h-5 rounded-full bg-black text-white flex items-center justify-center text-[10px] font-bold">
                    {(user?.fullName || user?.email || "U")[0].toUpperCase()}
                  </span>
                )}
                <span className="max-w-[100px] sm:max-w-[130px] truncate font-bold text-black">
                  {user?.fullName || user?.email?.split("@")[0] || "User"}
                </span>
              </div>
              <button
                type="button"
                onClick={() => signOut()}
                className="px-3 py-1.5 border border-red-300 text-red-600 hover:bg-red-50 text-xs font-mono transition-colors cursor-pointer"
              >
                Sign Out
              </button>
            </div>
          ) : (
            <Link
              href="/login"
              className="flex items-center gap-1.5 px-3 sm:px-4 py-2 bg-black text-white text-xs font-bold border-2 border-black hover:bg-neutral-800 transition-colors shadow-[2px_2px_0px_#62D800]"
            >
              <span>Sign In</span>
            </Link>
          )}

          <Link
            href="/"
            className="flex items-center gap-2 px-3.5 sm:px-5 py-2 bg-white text-black text-xs sm:text-sm font-bold border-2 border-black hover:bg-neutral-100 transition-transform active:translate-x-0.5 active:translate-y-0.5 shadow-[3px_3px_0px_#000000]"
          >
            <svg
              className="w-3.5 h-3.5 sm:w-4 sm:h-4"
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
            <span>Landing Page</span>
          </Link>
        </div>
      </header>


      {/* Main Container */}
      <main className="flex-1 max-w-[1440px] w-full mx-auto p-4 sm:p-8 lg:p-10 space-y-6 sm:space-y-8">
        {/* Backend Server Status & Health Bar */}
        <BackendStatusBar
          dataSource={dataSource}
          onRefresh={handleRefresh}
          isSyncing={isLoading}
          lastSynced={lastSynced}
          recordsCount={recordsCount}
          currency={currency}
          onToggleCurrency={setCurrency}
        />

        {/* Overview Header & Controls */}
        <div className="border-[3px] border-black bg-white p-5 sm:p-8 shadow-[6px_6px_0px_#000000] flex flex-col lg:flex-row lg:items-center justify-between gap-6">
          <div>
            <div className="flex items-center gap-2">
              <span className="font-mono text-xs font-bold text-[#FF0000] uppercase tracking-widest">
                FINANCIAL OPERATIONS CONSOLE
              </span>
              <span className="text-neutral-400">•</span>
              <span className="font-mono text-xs text-neutral-500">
                SPRING BOOT REST + RECHARTS
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-black mt-1">
              FINANCIAL ANALYTICS & SETTLEMENT
            </h1>
            <p className="text-sm sm:text-base text-neutral-600 font-sans mt-2 max-w-3xl leading-relaxed">
              Real-time cashflow telemetry, UPI auto-reconciliation, multi-currency
              breakdown, and network risk indices. Powered by reactive shadcn/ui charts.
            </p>
          </div>

          {/* Quick Actions */}
          <div className="flex flex-wrap items-center gap-2 sm:gap-3 shrink-0">
            <button
              onClick={() => {
                const jsonStr = JSON.stringify(
                  { summary, categoryData, dailyData, monthlyData, expenses },
                  null,
                  2
                );
                const blob = new Blob([jsonStr], { type: "application/json" });
                const url = URL.createObjectURL(blob);
                const a = document.createElement("a");
                a.href = url;
                a.download = `hulypay-telemetry-${new Date().toISOString().slice(0, 10)}.json`;
                a.click();
              }}
              className="px-3.5 py-2 border-2 border-black bg-neutral-100 hover:bg-neutral-200 text-xs font-mono font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              <span>Export JSON</span>
            </button>

            <button
              onClick={handleRefresh}
              className="px-4 py-2 border-2 border-black bg-[#62D800] hover:bg-[#52b600] text-black text-xs font-mono font-black flex items-center gap-1.5 transition-colors cursor-pointer shadow-[3px_3px_0px_#000000]"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              <span>Sync Telemetry</span>
            </button>
          </div>
        </div>

        {/* 4 Core Financial KPI Metric Cards (With Doto Font & Neo-Brutalist Frame) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {/* KPI 1: Total Volume */}
          <div className="p-5 sm:p-6 border-[3px] border-black bg-white shadow-[5px_5px_0px_#000000] flex flex-col justify-between relative overflow-hidden group hover:translate-x-0.5 hover:-translate-y-0.5 transition-transform">
            <div className="absolute top-0 right-0 w-12 h-12 bg-[#FF0000]/10 rounded-bl-full flex items-start justify-end p-2">
              <span className="w-2.5 h-2.5 bg-[#FF0000]" />
            </div>
            <div>
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-neutral-500 block">
                Total Outflow Volume
              </span>
              <div className="font-doto text-2xl sm:text-3xl lg:text-4xl font-black text-black mt-2">
                {formatMoney(summary?.totalSpent || 184520)}
              </div>
            </div>
            <div className="mt-4 pt-3 border-t border-neutral-200 flex items-center justify-between text-xs font-mono">
              <span className="text-[#058a00] font-bold">+18.4% MoM</span>
              <span className="text-neutral-400">Spring Boot Sync</span>
            </div>
          </div>

          {/* KPI 2: Transaction Count */}
          <div className="p-5 sm:p-6 border-[3px] border-black bg-white shadow-[5px_5px_0px_#000000] flex flex-col justify-between relative overflow-hidden group hover:translate-x-0.5 hover:-translate-y-0.5 transition-transform">
            <div className="absolute top-0 right-0 w-12 h-12 bg-[#62D800]/15 rounded-bl-full flex items-start justify-end p-2">
              <span className="w-2.5 h-2.5 bg-[#62D800]" />
            </div>
            <div>
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-neutral-500 block">
                Reconciled Transactions
              </span>
              <div className="font-doto text-2xl sm:text-3xl lg:text-4xl font-black text-black mt-2">
                {summary?.transactionCount || 312}
              </div>
            </div>
            <div className="mt-4 pt-3 border-t border-neutral-200 flex items-center justify-between text-xs font-mono">
              <span className="text-neutral-800 font-bold">100% Verified</span>
              <span className="text-neutral-400">SMS Parser</span>
            </div>
          </div>

          {/* KPI 3: Average Ticket */}
          <div className="p-5 sm:p-6 border-[3px] border-black bg-white shadow-[5px_5px_0px_#000000] flex flex-col justify-between relative overflow-hidden group hover:translate-x-0.5 hover:-translate-y-0.5 transition-transform">
            <div className="absolute top-0 right-0 w-12 h-12 bg-[#FF00F5]/10 rounded-bl-full flex items-start justify-end p-2">
              <span className="w-2.5 h-2.5 bg-[#FF00F5]" />
            </div>
            <div>
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-neutral-500 block">
                Average Transaction
              </span>
              <div className="font-doto text-2xl sm:text-3xl lg:text-4xl font-black text-black mt-2">
                {formatMoney(summary?.averageTransaction || 591.41)}
              </div>
            </div>
            <div className="mt-4 pt-3 border-t border-neutral-200 flex items-center justify-between text-xs font-mono">
              <span className="text-neutral-700 font-bold">Normal Distribution</span>
              <span className="text-neutral-400">Micro & Bulk</span>
            </div>
          </div>

          {/* KPI 4: Settlement SLA */}
          <div className="p-5 sm:p-6 border-[3px] border-black bg-white shadow-[5px_5px_0px_#000000] flex flex-col justify-between relative overflow-hidden group hover:translate-x-0.5 hover:-translate-y-0.5 transition-transform">
            <div className="absolute top-0 right-0 w-12 h-12 bg-[#D8FF00]/30 rounded-bl-full flex items-start justify-end p-2">
              <span className="w-2.5 h-2.5 bg-[#D8FF00] border border-black" />
            </div>
            <div>
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-neutral-500 block">
                Settlement Latency & SLA
              </span>
              <div className="font-doto text-2xl sm:text-3xl lg:text-4xl font-black text-black mt-2">
                ~380ms
              </div>
            </div>
            <div className="mt-4 pt-3 border-t border-neutral-200 flex items-center justify-between text-xs font-mono">
              <span className="text-[#058a00] font-bold">99.98% Uptime</span>
              <span className="text-neutral-400">Solana / UPI</span>
            </div>
          </div>
        </div>

        {/* CHARTS SECTION 1: AREA CHART & BAR CHART */}
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 bg-black inline-block" />
            <span className="font-mono text-xs font-black uppercase tracking-wider text-black">
              SHADCN CHART MODULES 01 & 02: TEMPORAL DYNAMICS
            </span>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Chart 1: Area Chart (Daily Spending / Settlement Velocity) */}
            <AreaChartSpending data={dailyData} currency={currency} />

            {/* Chart 2: Bar Chart (Monthly Outflow vs Budget Cap) */}
            <BarChartMonthly data={monthlyData} currency={currency} />
          </div>
        </div>

        {/* CHARTS SECTION 2: PIE / DONUT CHART & RADAR CHART */}
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 bg-black inline-block" />
            <span className="font-mono text-xs font-black uppercase tracking-wider text-black">
              SHADCN CHART MODULES 03 & 04: DISTRIBUTION & HEALTH RADAR
            </span>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Chart 3: Pie / Donut Chart (Category Distribution & Filter) */}
            <PieChartCategories
              data={categoryData}
              selectedCategory={selectedCategory}
              onSelectCategory={setSelectedCategory}
              currency={currency}
            />

            {/* Chart 4: Radar Chart (System & Operational Risk Benchmark) */}
            <RadarChartPerformance data={radarData} />
          </div>
        </div>

        {/* BACKEND TRANSACTIONS & RECONCILED LEDGER */}
        <div className="space-y-4 pt-2">
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 bg-[#FF0000] inline-block" />
            <span className="font-mono text-xs font-black uppercase tracking-wider text-black">
              LEDGER AUDIT & EXPENSE ENTITY RECORD
            </span>
          </div>

          <TransactionsTable
            expenses={expenses}
            selectedCategory={selectedCategory}
            onClearCategory={() => setSelectedCategory(null)}
            currency={currency}
          />
        </div>

        {/* Architecture Spec Card */}
        <div className="border-[3px] border-black bg-neutral-900 text-white p-6 sm:p-8 shadow-[6px_6px_0px_#000000] space-y-4">
          <div className="flex items-center justify-between border-b border-neutral-700 pb-3">
            <div className="flex items-center gap-2">
              <span className="w-2.5 h-2.5 bg-[#62D800]" />
              <span className="font-mono text-xs font-bold text-[#62D800] uppercase tracking-wider">
                BACKEND INTEGRATION MAP & DATA CONTRACTS
              </span>
            </div>
            <span className="font-mono text-xs text-neutral-400">
              Spring Boot 3.x / Java 21 / PostgreSQL
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 font-mono text-xs">
            <div className="space-y-1.5">
              <span className="text-[#FF00F5] font-bold block">
                01. ANALYTICS API (CONTROLLER)
              </span>
              <p className="text-neutral-400 font-sans text-xs leading-relaxed">
                <code className="text-white">AnalyticsController.java</code> exposes
                aggregations computed in SQL via{" "}
                <code className="text-white">ExpenseRepository</code>: daily spending,
                monthly rollups, category group-by, and summary totals.
              </p>
            </div>

            <div className="space-y-1.5">
              <span className="text-[#62D800] font-bold block">
                02. EXPENSES & PAYMENTS ENTITY
              </span>
              <p className="text-neutral-400 font-sans text-xs leading-relaxed">
                Stores UUIDs, UPI Transaction IDs, GPS latitude/longitude, merchant
                metadata, and execution timestamps. Reconciled via SMS parser
                pattern matching.
              </p>
            </div>

            <div className="space-y-1.5">
              <span className="text-[#D8FF00] font-bold block">
                03. SHADCN / RECHARTS ENGINE
              </span>
              <p className="text-neutral-400 font-sans text-xs leading-relaxed">
                Rendered with CSS variables (<code className="text-white">--color-*</code>)
                and responsive SVG viewports, styled with Pixelify Sans and Doto
                matrix typography.
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* Retro Cyberdeck Footer */}
      <footer className="w-full border-t-[3px] border-black bg-white py-6 px-4 sm:px-8 lg:px-12 mt-12 flex flex-col sm:flex-row items-center justify-between gap-4 font-mono text-xs">
        <div className="flex items-center gap-3">
          <span className="w-2 h-2 bg-[#62D800]" />
          <span className="font-bold text-black">HULYPAY FINANCIAL NETWORK</span>
          <span className="text-neutral-400">•</span>
          <span className="text-neutral-500">SYSTEM ALL SYSTEMS NOMINAL</span>
        </div>
        <div className="flex items-center gap-4 text-neutral-600">
          <Link href="/" className="hover:text-black hover:underline">
            Landing
          </Link>
          <Link href="/features" className="hover:text-black hover:underline">
            Features
          </Link>
          <Link href="/design" className="hover:text-black hover:underline">
            Design
          </Link>
          <Link href="/tools" className="hover:text-black hover:underline">
            Tools
          </Link>
        </div>
      </footer>
    </div>
  );
}
