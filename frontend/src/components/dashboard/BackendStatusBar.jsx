"use client";

import * as React from "react";
import { checkBackendHealth } from "@/lib/api";

export default function BackendStatusBar({
  dataSource = "live_supabase",
  onRefresh,
  isSyncing = false,
  lastSynced = "",
  recordsCount = 55,
  currency = "INR",
  onToggleCurrency,
}) {
  const [healthStatus, setHealthStatus] = React.useState({
    checking: false,
    online: false,
  });

  const handleSyncClick = async () => {
    setHealthStatus((prev) => ({ ...prev, checking: true }));
    const result = await checkBackendHealth();
    setHealthStatus({
      checking: false,
      online: result.isOnline,
    });
    if (onRefresh) {
      await onRefresh();
    }
  };

  React.useEffect(() => {
    let ignore = false;
    async function verify() {
      const result = await checkBackendHealth();
      if (!ignore) {
        setHealthStatus({
          checking: false,
          online: result.isOnline,
        });
      }
    }
    verify();
    return () => {
      ignore = true;
    };
  }, []);

  const isLive = dataSource === "live_supabase" || dataSource === "backend";

  return (
    <aside
      aria-label="System status"
      className="border-2 border-black bg-white p-3 sm:p-4 mb-6 shadow-[4px_4px_0px_#000000] flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs font-mono"
    >
      {/* Left: Backend & Database status details */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-2 px-2.5 py-1 bg-neutral-100 border border-black">
          <span
            className={`w-2.5 h-2.5 rounded-full ${
              isLive ? "bg-[#62D800] animate-pulse" : "bg-[#FF0000]"
            }`}
          />
          <span className="font-bold">
            {healthStatus.checking || isSyncing
              ? "SYNCING ACTUAL DATA..."
              : dataSource === "backend"
              ? "SPRING BOOT: ONLINE (:8080)"
              : isLive
              ? "SUPABASE POSTGRESQL (LIVE CLUSTER)"
              : "DATABASE: SIMULATED (OFFLINE)"}
          </span>
        </div>

        <div className="flex items-center gap-1.5 text-neutral-600">
          <span>SOURCE:</span>
          <span
            className={`px-2 py-0.5 font-bold ${
              isLive
                ? "bg-[#62D800] text-black"
                : "bg-[#D8FF00] text-black border border-black"
            }`}
          >
            {isLive ? `ACTUAL DATA (${recordsCount} RECORDS)` : "SIMULATED DTOs"}
          </span>
        </div>

        {lastSynced && (
          <>
            <span className="hidden lg:inline text-neutral-400">|</span>
            <div className="hidden lg:flex items-center gap-1 text-neutral-500">
              <span>SYNCED:</span>
              <span className="font-bold text-black">{lastSynced}</span>
            </div>
          </>
        )}

        <span className="hidden xl:inline text-neutral-400">|</span>

        <div className="hidden xl:flex items-center gap-2 text-neutral-600">
          <span>ENGINE:</span>
          <span className="bg-neutral-100 px-1.5 py-0.5 border border-neutral-300">
            UPI AUTO-SYNC
          </span>
        </div>
      </div>

      {/* Right: Controls & Sync Button */}
      <div className="flex flex-wrap items-center gap-2">
        {/* Currency Switcher ($ USD / ₹ INR) */}
        <div className="flex border border-black bg-neutral-100 p-0.5">
          <button
            type="button"
            onClick={() => onToggleCurrency && onToggleCurrency("INR")}
            className={`px-2.5 py-1 font-bold transition-colors cursor-pointer ${
              currency === "INR"
                ? "bg-[#62D800] text-black shadow-sm"
                : "text-neutral-600 hover:text-black"
            }`}
          >
            ₹ INR (UPI)
          </button>
          <button
            type="button"
            onClick={() => onToggleCurrency && onToggleCurrency("USD")}
            className={`px-2.5 py-1 font-bold transition-colors cursor-pointer ${
              currency === "USD"
                ? "bg-black text-white shadow-sm"
                : "text-neutral-600 hover:text-black"
            }`}
          >
            $ USD
          </button>
        </div>

        {/* Sync Actual Data Button */}
        <button
          type="button"
          onClick={handleSyncClick}
          disabled={isSyncing || healthStatus.checking}
          className="flex items-center gap-1.5 px-3 py-1.5 bg-black text-white hover:bg-neutral-800 transition-colors border border-black cursor-pointer font-bold disabled:opacity-60 shadow-[2px_2px_0px_#62D800]"
        >
          <svg
            className={`w-3.5 h-3.5 text-[#62D800] ${
              isSyncing || healthStatus.checking ? "animate-spin" : ""
            }`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2.5"
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
          <span>{isSyncing || healthStatus.checking ? "SYNCING..." : "SYNC ACTUAL DATA"}</span>
        </button>
      </div>
    </aside>
  );
}
