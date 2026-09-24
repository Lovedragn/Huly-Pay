"use client";

import * as React from "react";
import Link from "next/link";
import Image from "next/image";
import AreaChartSpending from "@/components/dashboard/AreaChartSpending";
import BarChartMonthly from "@/components/dashboard/BarChartMonthly";
import PieChartCategories from "@/components/dashboard/PieChartCategories";
import RadarChartPerformance from "@/components/dashboard/RadarChartPerformance";
import TransactionsTable from "@/components/dashboard/TransactionsTable";
import ThemeToggle from "@/components/ThemeToggle";
import { useAuth } from "@/context/AuthContext";
import {
  syncAllDashboardData,
  deleteTransaction,
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
  const [dailyTheaterMode, setDailyTheaterMode] = React.useState(false);
  const [showUserMenu, setShowUserMenu] = React.useState(false);
  const userMenuRef = React.useRef(null);
  const chartsContainerRef = React.useRef(null);

  // Preference keys
  // localStorage: Theater mode, Currency, Metric (amount/avg), Time range, Benchmark, Category/Merchant
  // sessionStorage: Transaction logs visible count (clears when browser session closes)
  const PREF_KEYS = React.useMemo(
    () => ({
      THEATER: "hulypay_pref_theater_mode",
      CURRENCY: "hulypay_pref_currency",
      METRIC: "hulypay_pref_chart_metric",
      TIME_RANGE: "hulypay_pref_time_range",
      BENCHMARK: "hulypay_pref_benchmark",
      VIEW_MODE: "hulypay_pref_view_mode",
      TX_COUNT: "hulypay_pref_tx_visible_count",
    }),
    []
  );

  // Load initial preferences on client mount
  React.useEffect(() => {
    try {
      const savedTheater = localStorage.getItem(PREF_KEYS.THEATER);
      if (savedTheater !== null) {
        setDailyTheaterMode(savedTheater === "true");
      }

      const savedCurrency = localStorage.getItem(PREF_KEYS.CURRENCY);
      if (savedCurrency === "INR" || savedCurrency === "USD") {
        setCurrency(savedCurrency);
      }
    } catch (e) {
      console.warn("Could not read preferences from localStorage:", e);
    }
  }, [PREF_KEYS]);

  // Persist currency
  const handleCurrencyChange = React.useCallback(
    (newCurrency) => {
      setCurrency(newCurrency);
      try {
        localStorage.setItem(PREF_KEYS.CURRENCY, newCurrency);
      } catch (e) {
        console.warn("Could not save currency preference:", e);
      }
    },
    [PREF_KEYS]
  );

  // Persist theater mode
  const handleToggleTheater = React.useCallback(() => {
    setDailyTheaterMode((prev) => {
      const next = !prev;
      try {
        localStorage.setItem(PREF_KEYS.THEATER, String(next));
      } catch (e) {
        console.warn("Could not save theater mode preference:", e);
      }
      return next;
    });
  }, [PREF_KEYS]);

  // Synchronize and observe embedded chart preferences (Metric, Range, Benchmark, Category/Merchant)
  // and transaction table 'More' count (stored in sessionStorage so it clears on browser close)
  React.useEffect(() => {
    const root = typeof document !== "undefined" ? document : null;
    if (!root) return;

    // 1. Initial restoration of child component controls
    try {
      // Metric (Amount / Average)
      const savedMetric = localStorage.getItem(PREF_KEYS.METRIC);
      if (savedMetric) {
        const metricBtns = root.querySelectorAll("button");
        for (const btn of metricBtns) {
          const txt = btn.textContent?.trim().toLowerCase();
          if (
            (savedMetric === "average" && txt === "average") ||
            (savedMetric === "amount" && txt === "amount")
          ) {
            // Check if not already active
            if (!btn.className.includes("bg-black")) {
              btn.click();
            }
            break;
          }
        }
      }

      // Timeframe Range (7D, 1M, 4M, 6M, 1Y, ALL)
      const savedRange = localStorage.getItem(PREF_KEYS.TIME_RANGE);
      if (savedRange) {
        const buttons = root.querySelectorAll("button");
        for (const btn of buttons) {
          const txt = btn.textContent?.trim().toLowerCase();
          if (txt === savedRange.toLowerCase()) {
            if (!btn.className.includes("bg-[#62D800]")) {
              btn.click();
            }
            break;
          }
        }
      }

      // Benchmark ON / OFF
      const savedBenchmark = localStorage.getItem(PREF_KEYS.BENCHMARK);
      if (savedBenchmark !== null) {
        const shouldBeOn = savedBenchmark === "true";
        const buttons = root.querySelectorAll("button");
        for (const btn of buttons) {
          const txt = btn.textContent?.trim();
          if (txt && txt.startsWith("Benchmark:")) {
            const isCurrentlyOn = txt.includes("ON");
            if (isCurrentlyOn !== shouldBeOn) {
              btn.click();
            }
            break;
          }
        }
      }

      // Category / Merchandise View Mode
      const savedViewMode = localStorage.getItem(PREF_KEYS.VIEW_MODE);
      if (savedViewMode) {
        const buttons = root.querySelectorAll("button");
        for (const btn of buttons) {
          const txt = btn.textContent?.trim().toLowerCase();
          if (
            (savedViewMode === "merchant" && txt.includes("merchandise")) ||
            (savedViewMode === "category" && txt.includes("category") && !txt.includes("breakdown"))
          ) {
            if (!btn.className.includes("bg-black")) {
              btn.click();
            }
            break;
          }
        }
      }

      // Transaction logs 'More' visible count (sessionStorage - clears when browser closes)
      const savedTxCount = sessionStorage.getItem(PREF_KEYS.TX_COUNT);
      if (savedTxCount) {
        const targetCount = parseInt(savedTxCount, 10);
        if (!isNaN(targetCount) && targetCount > 5) {
          // Find the "More" button in transactions table and click as needed to restore count
          const clicksNeeded = Math.min(Math.ceil((targetCount - 5) / 10), 20);
          for (let i = 0; i < clicksNeeded; i++) {
            const moreBtn = Array.from(root.querySelectorAll("button")).find(
              (b) => b.textContent?.includes("More") && b.textContent?.includes("+10")
            );
            if (moreBtn) {
              moreBtn.click();
            } else {
              break;
            }
          }
        }
      }
    } catch (e) {
      console.warn("Could not restore child component preferences:", e);
    }

    // 2. Global click listener to track user interactions and update preferences immediately
    function handleGlobalClick(e) {
      const target = e.target;
      if (!target) return;
      const btn = target.closest("button");
      if (!btn) return;

      const txt = btn.textContent?.trim() || "";
      const lower = txt.toLowerCase();

      try {
        // Metric: Amount / Average
        if (lower === "amount") {
          localStorage.setItem(PREF_KEYS.METRIC, "amount");
        } else if (lower === "average") {
          localStorage.setItem(PREF_KEYS.METRIC, "average");
        }

        // Time Range: 7d, 1m, 4m, 6m, 1y, all
        const validRanges = ["7d", "1m", "4m", "6m", "1y", "all"];
        if (validRanges.includes(lower)) {
          localStorage.setItem(PREF_KEYS.TIME_RANGE, lower);
        }

        // Benchmark toggle button ("Benchmark: ON" / "Benchmark: OFF")
        if (txt.startsWith("Benchmark:")) {
          // Notice: button click will flip the benchmark, so if it currently was ON, it will become false
          const currentlyOn = txt.includes("ON");
          localStorage.setItem(PREF_KEYS.BENCHMARK, String(!currentlyOn));
        }

        // Category vs Merchandise
        if (lower.includes("category") && !lower.includes("breakdown") && !lower.includes("filter")) {
          localStorage.setItem(PREF_KEYS.VIEW_MODE, "category");
        } else if (lower.includes("merchandise")) {
          localStorage.setItem(PREF_KEYS.VIEW_MODE, "merchant");
        }

        // Transactions table More button: +10 records
        if (txt.includes("More") && txt.includes("+10")) {
          const currentCount = parseInt(
            sessionStorage.getItem(PREF_KEYS.TX_COUNT) || "5",
            10
          );
          sessionStorage.setItem(
            PREF_KEYS.TX_COUNT,
            String((isNaN(currentCount) ? 5 : currentCount) + 10)
          );
        }
      } catch (err) {
        console.warn("Could not save preference:", err);
      }
    }

    window.addEventListener("click", handleGlobalClick, true);
    return () => {
      window.removeEventListener("click", handleGlobalClick, true);
    };
  }, [dailyData, expenses, categoryData, PREF_KEYS]);

  React.useEffect(() => {
    function handleClickOutside(e) {
      if (userMenuRef.current && !userMenuRef.current.contains(e.target)) {
        setShowUserMenu(false);
      }
    }
    if (showUserMenu) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [showUserMenu]);

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

  const handleDeleteTransaction = React.useCallback(
    async (tx) => {
      const token = session?.access_token || null;
      await deleteTransaction(tx, token);

      // Optimistically remove from state
      setExpenses((prev) =>
        prev.filter(
          (item) =>
            item.id !== tx.id && (!tx.expenseId || item.id !== tx.expenseId)
        )
      );
      setRecordsCount((prev) => Math.max(0, prev - 1));

      setSummary((prev) => {
        if (!prev) return prev;
        const removedAmt = Number(tx.amount) || 0;
        const newSpent = Math.max(0, (Number(prev.totalSpent) || 0) - removedAmt);
        const newCount = Math.max(0, (Number(prev.transactionCount) || 0) - 1);
        const newAvg = newCount > 0 ? newSpent / newCount : 0;
        return {
          ...prev,
          totalSpent: Math.round(newSpent * 100) / 100,
          transactionCount: newCount,
          averageTransaction: Math.round(newAvg * 100) / 100,
        };
      });

      // Background refresh from Supabase to re-calculate all aggregated charts
      handleRefresh();
    },
    [session, handleRefresh]
  );

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
      {/* Top Cyberdeck Navbar - Attached to page */}
      <header className="w-full border-b-[3px] border-black bg-white h-16 sm:h-20 flex items-center justify-between pl-4 sm:pl-8 lg:pl-12 pr-0">
        <div className="flex items-center gap-3 sm:gap-4">
          <Link href="/" className="flex items-center">
            <div className="w-7 h-7 sm:w-8 sm:h-8 relative flex items-center justify-center shrink-0">
              <Image
                src="/assets/logo-Light.svg"
                alt="Huly Pay Logo"
                width={32}
                height={32}
                priority
                className="w-full h-full object-contain dark:hidden"
              />
              <Image
                src="/assets/Logo-Dark.svg"
                alt="Huly Pay Logo"
                width={32}
                height={32}
                priority
                className="w-full h-full object-contain hidden dark:block"
              />
            </div>
          </Link>
          <span className="text-xs font-mono font-bold bg-[#D8FF00] text-black px-2 py-0.5 border border-black shadow-[2px_2px_0px_#000000]">
            v2.4
          </span>
        </div>

        {/* Right CTA - Theme Toggle & Account / Login */}
        <div className="flex items-center h-full">
          <ThemeToggle fullHeight />
          {isAuthenticated ? (
            <div ref={userMenuRef} className="relative h-full">
              <button
                type="button"
                onClick={() => setShowUserMenu((prev) => !prev)}
                className="h-full px-4 sm:px-6 bg-neutral-100 hover:bg-neutral-200 transition-colors flex items-center gap-2.5 sm:gap-3 border-l-[3px] border-black font-mono text-xs cursor-pointer select-none"
              >
                {user?.avatarUrl ? (
                  <Image
                    src={user.avatarUrl}
                    alt={user.fullName || "User"}
                    width={28}
                    height={28}
                    unoptimized
                    className="w-7 h-7 sm:w-8 sm:h-8 rounded-full object-cover border border-black shrink-0"
                  />
                ) : (
                  <span className="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-black text-white flex items-center justify-center text-xs font-bold shrink-0">
                    {(user?.fullName || user?.email || "U")[0].toUpperCase()}
                  </span>
                )}
                <div className="flex flex-col text-left">
                  <span className="max-w-[100px] sm:max-w-[150px] truncate font-bold text-black font-pixel text-xs sm:text-sm leading-tight">
                    {user?.fullName || user?.email?.split("@")[0] || "User"}
                  </span>
                  <span className="text-[10px] font-mono text-neutral-500 uppercase leading-none mt-0.5">
                    Google Account
                  </span>
                </div>
                <svg
                  className={`w-3.5 h-3.5 text-neutral-600 transition-transform ${
                    showUserMenu ? "rotate-180" : ""
                  }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>

              {/* User Dropdown Menu */}
              {showUserMenu && (
                <div className="absolute top-full right-0 w-52 sm:w-60 bg-white border-[3px] border-black shadow-[4px_4px_0px_#000000] p-3 z-50 font-mono text-xs space-y-2 animate-in fade-in duration-150">
                  <div className="border-b-2 border-neutral-200 pb-2">
                    <span className="text-[10px] uppercase font-bold text-[#058a00] block">
                      Google Authenticated
                    </span>
                    <p className="text-black font-bold truncate text-xs mt-0.5">
                      {user?.fullName || "User"}
                    </p>
                    <p className="text-neutral-500 truncate text-[11px]">
                      {user?.email}
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={() => {
                      setShowUserMenu(false);
                      signOut();
                    }}
                    className="w-full text-left px-2.5 py-1.5 text-white bg-[#FF0000] hover:bg-black font-bold transition-colors cursor-pointer border border-black shadow-[2px_2px_0px_#000000] flex items-center justify-between"
                  >
                    <span>Sign Out</span>
                    <span>→</span>
                  </button>
                </div>
              )}
            </div>
          ) : (
            <Link
              href="/login"
              className="h-full px-5 sm:px-8 bg-black text-white hover:bg-neutral-900 transition-colors flex items-center justify-center gap-2.5 border-l-[3px] border-black font-pixel text-xs sm:text-sm font-bold select-none cursor-pointer"
            >
              {/* Google Icon */}
              <svg className="w-4 h-4 shrink-0" viewBox="0 0 24 24">
                <path
                  fill="#EA4335"
                  d="M12 5c1.6 0 3 .6 4.1 1.7l3.1-3.1C17.3 1.8 14.8 1 12 1 7.5 1 3.7 3.6 1.9 7.3l3.7 2.9C6.5 7.4 9 5 12 5z"
                />
                <path
                  fill="#4285F4"
                  d="M23.5 12.3c0-.8-.1-1.7-.2-2.3H12v4.6h6.5c-.3 1.5-1.1 2.8-2.4 3.7l3.7 2.9c2.2-2 3.7-5 3.7-8.9z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.6 14.8c-.2-.7-.4-1.5-.4-2.8s.2-2.1.4-2.8L1.9 6.3C.7 8.7 0 10.3 0 12s.7 3.3 1.9 5.7l3.7-2.9z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c3.2 0 6-1.1 8-3l-3.7-2.9c-1.1.7-2.5 1.2-4.3 1.2-3 0-5.5-2-6.4-4.8L1.9 16.4C3.7 20.1 7.5 23 12 23z"
                />
              </svg>
              <span>Sign In with Google</span>
            </Link>
          )}
        </div>
      </header>

      {/* Main Container */}
      <main className="flex-1 max-w-[1440px] w-full mx-auto p-4 sm:p-8 lg:p-10 space-y-6 sm:space-y-8">
        {/* Financial Metrics & Actions Toolbar */}
        <div className="space-y-4">
          <div className="flex items-center justify-end">
            {/* Right side controls: Currency switch, Export JSON, Sync Telemetry */}
            <div className="flex flex-wrap items-center gap-2.5 sm:gap-3">
              {/* INR / USD Toggle */}
              <div className="flex items-center border-2 border-black bg-neutral-100 p-0.5 font-mono text-xs shadow-[2px_2px_0px_#000000]">
                <button
                  type="button"
                  onClick={() => handleCurrencyChange("INR")}
                  className={`px-2.5 py-1 font-bold transition-colors cursor-pointer ${
                    currency === "INR"
                      ? "bg-black text-white"
                      : "text-black hover:bg-neutral-200"
                  }`}
                >
                  ₹ INR (UPI)
                </button>
                <button
                  type="button"
                  onClick={() => handleCurrencyChange("USD")}
                  className={`px-2.5 py-1 font-bold transition-colors cursor-pointer ${
                    currency === "USD"
                      ? "bg-black text-white"
                      : "text-black hover:bg-neutral-200"
                  }`}
                >
                  $ USD
                </button>
              </div>

              {/* Export JSON */}
              <button
                type="button"
                onClick={() => {
                  const jsonStr = JSON.stringify(
                    { summary, categoryData, dailyData, monthlyData, expenses },
                    null,
                    2,
                  );
                  const blob = new Blob([jsonStr], {
                    type: "application/json",
                  });
                  const url = URL.createObjectURL(blob);
                  const a = document.createElement("a");
                  a.href = url;
                  a.download = `hulypay-telemetry-${new Date().toISOString().slice(0, 10)}.json`;
                  a.click();
                }}
                className="px-3.5 py-1.5 border-2 border-black bg-white hover:bg-neutral-100 text-xs font-mono font-bold flex items-center gap-1.5 transition-colors cursor-pointer shadow-[2px_2px_0px_#000000]"
                title="Export JSON Telemetry"
              >
                <svg
                  className="w-3.5 h-3.5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                  />
                </svg>
                <span>Export JSON</span>
              </button>

              {/* Sync Telemetry */}
              <button
                type="button"
                onClick={handleRefresh}
                disabled={isLoading}
                className="px-3.5 py-1.5 border-2 border-black bg-[#62D800] hover:bg-[#52b600] text-black text-xs font-mono font-black flex items-center gap-1.5 transition-colors cursor-pointer shadow-[2px_2px_0px_#000000] disabled:opacity-50"
                title="Sync Actual Data"
              >
                <svg
                  className={`w-3.5 h-3.5 ${isLoading ? "animate-spin" : ""}`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  />
                </svg>
                <span>{isLoading ? "" : "Sync"}</span>
              </button>
            </div>
          </div>

          {/* 3 Core Financial KPI Metric Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
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
                  {formatMoney(summary?.totalSpent ?? 0)}
                </div>
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
                  {summary?.transactionCount ?? 0}
                </div>
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
                  {formatMoney(summary?.averageTransaction ?? 0)}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* CHARTS SECTION 1: AREA CHART & BAR CHART */}
        <div
          className={`grid grid-cols-1 ${
            dailyTheaterMode ? "" : "lg:grid-cols-2"
          } gap-6 items-start transition-all duration-300`}
        >
          {/* Chart 1: Area Chart (Daily Spending - with Theater View support) */}
          <div
            className={`w-full transition-all duration-300 ${
              dailyTheaterMode ? "col-span-full" : ""
            }`}
          >
            <AreaChartSpending
              data={dailyData}
              currency={currency}
              isTheaterMode={dailyTheaterMode}
              onToggleTheater={handleToggleTheater}
            />
          </div>

          {/* Chart 2: Bar Chart (Monthly Outflow vs Budget Cap) */}
          <div
            className={`w-full transition-all duration-300 ${
              dailyTheaterMode ? "col-span-full" : ""
            }`}
          >
            <BarChartMonthly data={monthlyData} currency={currency} />
          </div>
        </div>

        {/* CHARTS SECTION 2: PIE / DONUT CHART & RADAR CHART */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Chart 3: Pie / Donut Chart (Category Distribution & Filter) */}
          <PieChartCategories
            data={categoryData}
            expenses={expenses}
            selectedCategory={selectedCategory}
            onSelectCategory={setSelectedCategory}
            currency={currency}
          />

          {/* Chart 4: Radar Chart (System & Operational Risk Benchmark) */}
          <RadarChartPerformance data={radarData} />
        </div>

        {/* BACKEND TRANSACTIONS & RECONCILED LEDGER */}
        <div className="pt-2">
          <TransactionsTable
            expenses={expenses}
            selectedCategory={selectedCategory}
            onClearCategory={() => setSelectedCategory(null)}
            currency={currency}
            onDelete={handleDeleteTransaction}
          />
        </div>

      </main>

      {/* Retro Cyberdeck Footer */}
      <footer className="w-full border-t-[3px] border-black bg-white py-6 px-4 sm:px-8 lg:px-12 mt-12 flex flex-col sm:flex-row items-center justify-between gap-4 font-mono text-xs">
        <div className="flex items-center">
          <span className="font-bold text-black">@hulypay</span>
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
