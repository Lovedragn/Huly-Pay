"use client";

import * as React from "react";

export default function TransactionsTable({
  expenses = [],
  selectedCategory,
  onClearCategory,
  currency = "INR",
  exchangeRate = 83.5,
  onDelete,
}) {
  const [searchQuery, setSearchQuery] = React.useState("");
  const [statusFilter, setStatusFilter] = React.useState("ALL");
  const [copiedId, setCopiedId] = React.useState(null);
  const [visibleCount, setVisibleCount] = React.useState(5);
  const [confirmingId, setConfirmingId] = React.useState(null);
  const [deletingId, setDeletingId] = React.useState(null);
  const [noticeMessage, setNoticeMessage] = React.useState(null);
  const [errorMessage, setErrorMessage] = React.useState(null);
  const [isFilterMenuOpen, setIsFilterMenuOpen] = React.useState(false);
  const [isColumnsMenuOpen, setIsColumnsMenuOpen] = React.useState(false);
  const [activeMapTx, setActiveMapTx] = React.useState(null);
  const filterMenuRef = React.useRef(null);
  const columnsMenuRef = React.useRef(null);

  // Column visibility state with localStorage persistence
  const [visibleColumns, setVisibleColumns] = React.useState({
    merchant: true,
    category: true,
    upi: true,
    location: true,
    amount: true,
    status: true,
    action: true,
  });

  React.useEffect(() => {
    try {
      const saved = localStorage.getItem("hulypay_pref_tx_columns");
      if (saved) {
        setVisibleColumns((prev) => ({ ...prev, ...JSON.parse(saved) }));
      }
    } catch (e) {
      // ignore
    }
  }, []);

  const toggleColumn = (key) => {
    setVisibleColumns((prev) => {
      const next = { ...prev, [key]: !prev[key] };
      // Ensure at least one column remains visible
      if (!Object.values(next).some(Boolean)) return prev;
      try {
        localStorage.setItem("hulypay_pref_tx_columns", JSON.stringify(next));
      } catch (e) {
        // ignore
      }
      return next;
    });
  };

  // Close menus on outside click
  React.useEffect(() => {
    function handleClickOutside(e) {
      if (filterMenuRef.current && !filterMenuRef.current.contains(e.target)) {
        setIsFilterMenuOpen(false);
      }
      if (columnsMenuRef.current && !columnsMenuRef.current.contains(e.target)) {
        setIsColumnsMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const [prevFilterKey, setPrevFilterKey] = React.useState(
    `${searchQuery}|${statusFilter}|${selectedCategory || ""}`
  );

  const currentFilterKey = `${searchQuery}|${statusFilter}|${selectedCategory || ""}`;
  if (prevFilterKey !== currentFilterKey) {
    setPrevFilterKey(currentFilterKey);
    setVisibleCount(5);
  }

  const filteredExpenses = React.useMemo(() => {
    return expenses.filter((item) => {
      // Category or Merchant filter
      if (selectedCategory) {
        const cat = item.category?.name || item.paymentMethod;
        const merchant = item.merchantName || item.provider;
        if (cat !== selectedCategory && merchant !== selectedCategory) {
          return false;
        }
      }

      // Status filter: ALL | CONFIRMED | PENDING | CANCELED
      if (statusFilter !== "ALL") {
        const s = (item.status || "").toUpperCase();
        if (statusFilter === "CONFIRMED") {
          if (s !== "CONFIRMED" && s !== "COMPLETED" && s !== "SETTLED") {
            return false;
          }
        } else if (statusFilter === "PENDING") {
          if (s !== "PENDING" && s !== "PROCESSING") {
            return false;
          }
        } else if (statusFilter === "CANCELED") {
          if (
            s !== "CANCELED" &&
            s !== "CANCELLED" &&
            s !== "FAILED" &&
            s !== "REJECTED" &&
            s !== "VOID"
          ) {
            return false;
          }
        }
      }

      // Search query
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const matchMerchant = item.merchantName?.toLowerCase().includes(query);
        const matchDesc = item.description?.toLowerCase().includes(query);
        const matchUpi = item.upiTransactionId?.toLowerCase().includes(query);
        const matchUpiId = item.upiId?.toLowerCase().includes(query);
        if (!matchMerchant && !matchDesc && !matchUpi && !matchUpiId) {
          return false;
        }
      }
      return true;
    });
  }, [expenses, selectedCategory, statusFilter, searchQuery]);

  const visibleExpenses = React.useMemo(() => {
    return filteredExpenses.slice(0, visibleCount);
  }, [filteredExpenses, visibleCount]);

  const hasActiveFilter = Boolean(
    searchQuery.trim() || statusFilter !== "ALL" || selectedCategory
  );

  const handleClearAllFilters = () => {
    setSearchQuery("");
    setStatusFilter("ALL");
    if (onClearCategory) {
      onClearCategory();
    }
  };

  const handleConfirmDelete = async (tx) => {
    if (!onDelete) return;
    try {
      setDeletingId(tx.id);
      setErrorMessage(null);
      await onDelete(tx);
      setNoticeMessage(`Transaction removed from database successfully.`);
      setTimeout(() => setNoticeMessage(null), 4000);
      setConfirmingId(null);
    } catch (err) {
      console.error("Failed to remove transaction:", err);
      setErrorMessage(
        err?.message || "Failed to remove transaction from database."
      );
      setTimeout(() => setErrorMessage(null), 5000);
    } finally {
      setDeletingId(null);
    }
  };

  const copyToClipboard = (id) => {
    if (!id) return;
    navigator.clipboard.writeText(id);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const formatAmount = (tx) => {
    const rawVal = Number(tx.amount) || 0;
    const isOriginalInr =
      tx.originalCurrency === "INR" || tx.currency === "INR";

    if (currency === "INR") {
      const inrVal = isOriginalInr
        ? rawVal
        : Math.round(rawVal * exchangeRate);
      return `₹${inrVal.toLocaleString("en-IN")}`;
    }

    const usdVal = isOriginalInr ? rawVal / exchangeRate : rawVal;
    return `$${usdVal.toLocaleString("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  };

  const STATUS_OPTIONS = [
    { id: "ALL", label: "All Statuses", badgeColor: "bg-neutral-100 text-black border-neutral-300" },
    { id: "CONFIRMED", label: "Confirmed", badgeColor: "bg-emerald-50 text-emerald-800 border-emerald-300" },
    { id: "PENDING", label: "Pending", badgeColor: "bg-amber-50 text-amber-800 border-amber-300" },
    { id: "CANCELED", label: "Canceled", badgeColor: "bg-rose-50 text-rose-800 border-rose-300" },
  ];

  const COLUMN_DEFINITIONS = [
    { key: "merchant", label: "Merchant & Reference" },
    { key: "category", label: "Category / Method" },
    { key: "upi", label: "UPI Identifier & Hash" },
    { key: "location", label: "Map & Geolocation" },
    { key: "amount", label: "Amount" },
    { key: "status", label: "Status" },
    { key: "action", label: "Action (Delete)" },
  ];

  // Helper to get formatted location name or coordinates for an item
  const getTxLocation = (tx) => {
    if (tx.locationCity && tx.locationState) {
      return `${tx.locationCity}, ${tx.locationState}`;
    }
    if (tx.locationCity) return tx.locationCity;
    if (tx.latitude && tx.longitude) {
      return `${Number(tx.latitude).toFixed(3)}°, ${Number(tx.longitude).toFixed(3)}°`;
    }
    // Default fallback coordinates if unrecorded
    return "India Node";
  };

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] overflow-hidden">
      {/* Header & Controls */}
      <div className="p-4 sm:p-6 border-b-2 border-black flex flex-col md:flex-row md:items-center justify-between gap-4 bg-[#FFFFEB]">
        <div>
          <h3 className="text-xl sm:text-2xl font-bold font-pixel text-black inline-flex items-baseline gap-1.5">
            <span>Transaction Logs</span>
            <span className="font-sans font-bold text-neutral-600">(</span>
            <span className="font-doto font-black text-lg sm:text-xl text-black">
              {filteredExpenses.length}
            </span>
            <span className="font-sans font-bold text-neutral-600">)</span>
          </h3>
        </div>

        {/* Filter bar */}
        <div className="flex flex-wrap items-center gap-2">
          {/* Dedicated Filter Button (Left side of filter tools) */}
          <div ref={filterMenuRef} className="relative">
            <button
              type="button"
              onClick={() => setIsFilterMenuOpen((prev) => !prev)}
              className={`px-3 py-1.5 text-xs font-mono font-bold border-2 border-black transition-all flex items-center gap-1.5 cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 ${
                statusFilter !== "ALL"
                  ? "bg-[#D8FF00] text-black"
                  : "bg-white hover:bg-neutral-100 text-black"
              }`}
              title="Filter transactions by status (All, Confirmed, Pending, Canceled)"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2.5"
                  d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
                />
              </svg>
              <span>Filter:</span>
              <span className="font-black uppercase">{statusFilter}</span>
              <svg
                className={`w-3 h-3 transition-transform ${isFilterMenuOpen ? "rotate-180" : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            {/* Filter Dropdown Popover */}
            {isFilterMenuOpen && (
              <div className="absolute top-full left-0 mt-1 w-48 bg-white border-[2.5px] border-black shadow-[4px_4px_0px_#000000] p-1.5 z-40 font-mono text-xs space-y-1 animate-in fade-in duration-100">
                <div className="px-2 py-1 text-[10px] uppercase font-bold text-neutral-500 border-b border-neutral-200">
                  Select Status
                </div>
                {STATUS_OPTIONS.map((opt) => (
                  <button
                    key={opt.id}
                    type="button"
                    onClick={() => {
                      setStatusFilter(opt.id);
                      setIsFilterMenuOpen(false);
                    }}
                    className={`w-full text-left px-2.5 py-1.5 rounded-none flex items-center justify-between transition-colors cursor-pointer border ${
                      statusFilter === opt.id
                        ? "bg-black text-white font-bold border-black"
                        : "hover:bg-[#FFFFEB] border-transparent text-neutral-800"
                    }`}
                  >
                    <span>{opt.label}</span>
                    {statusFilter === opt.id && <span className="font-bold">✓</span>}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Columns Selector Button */}
          <div ref={columnsMenuRef} className="relative">
            <button
              type="button"
              onClick={() => setIsColumnsMenuOpen((prev) => !prev)}
              className="px-3 py-1.5 text-xs font-mono font-bold border-2 border-black bg-white hover:bg-neutral-100 text-black transition-all flex items-center gap-1.5 cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5"
              title="Select which columns and data are shown in the table"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2"
                />
              </svg>
              <span>Columns</span>
              <svg
                className={`w-3 h-3 transition-transform ${isColumnsMenuOpen ? "rotate-180" : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            {/* Columns Dropdown Popover */}
            {isColumnsMenuOpen && (
              <div className="absolute top-full right-0 sm:left-0 mt-1 w-56 bg-white border-[2.5px] border-black shadow-[4px_4px_0px_#000000] p-2 z-40 font-mono text-xs space-y-1.5 animate-in fade-in duration-100">
                <div className="px-1.5 pb-1 text-[10px] uppercase font-bold text-neutral-500 border-b border-neutral-200 flex justify-between items-center">
                  <span>Visible Data Fields</span>
                  <span className="text-[9px] text-[#058a00]">Auto-saved</span>
                </div>
                {COLUMN_DEFINITIONS.map((col) => (
                  <label
                    key={col.key}
                    className="flex items-center gap-2.5 px-2 py-1.5 hover:bg-[#FFFFEB] cursor-pointer select-none border border-transparent hover:border-neutral-200"
                  >
                    <input
                      type="checkbox"
                      checked={visibleColumns[col.key]}
                      onChange={() => toggleColumn(col.key)}
                      className="w-3.5 h-3.5 accent-black rounded-none cursor-pointer"
                    />
                    <span className="text-black font-semibold text-xs">{col.label}</span>
                  </label>
                ))}
              </div>
            )}
          </div>

          {/* Search Input */}
          <div className="relative">
            <input
              type="text"
              placeholder="Search merchant, UPI ID..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="px-3 py-1.5 text-xs font-mono border-2 border-black bg-white focus:outline-none focus:ring-2 focus:ring-[#FF0000] w-44 sm:w-52"
            />
            {searchQuery && (
              <button
                type="button"
                onClick={() => setSearchQuery("")}
                className="absolute right-2 top-1/2 -translate-y-1/2 text-xs font-bold text-neutral-400 hover:text-black cursor-pointer"
              >
                ×
              </button>
            )}
          </div>

          {/* Quick Status Pill Bar (All, Confirmed, Pending, Canceled) */}
          <div className="hidden lg:flex border-2 border-black bg-white p-0.5 text-xs font-mono">
            {["ALL", "CONFIRMED", "PENDING", "CANCELED"].map((status) => (
              <button
                type="button"
                key={status}
                onClick={() => setStatusFilter(status)}
                className={`px-2 py-1 transition-colors cursor-pointer text-[11px] ${
                  statusFilter === status
                    ? "bg-black text-white font-bold"
                    : "text-neutral-700 hover:text-black"
                }`}
              >
                {status}
              </button>
            ))}
          </div>

          {/* Clear Filter Button */}
          <button
            type="button"
            onClick={handleClearAllFilters}
            disabled={!hasActiveFilter}
            className={`px-3 py-1.5 text-xs font-mono font-bold border-2 transition-all flex items-center gap-1.5 ${
              hasActiveFilter
                ? "border-black bg-[#FF0000] text-white hover:bg-black cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5"
                : "border-neutral-300 bg-neutral-100 text-neutral-400 cursor-not-allowed opacity-60"
            }`}
            title={hasActiveFilter ? "Clear all active filters" : "No filters active"}
          >
            <span>Clear Filter</span>
            {hasActiveFilter && <span className="font-bold">×</span>}
          </button>
        </div>
      </div>

      {/* Action Notification Banners */}
      {noticeMessage && (
        <div className="px-4 py-2 bg-[#62D800]/20 border-b-2 border-black text-black font-mono text-xs font-bold flex items-center justify-between animate-in fade-in duration-150">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 bg-[#058a00] inline-block" />
            <span>{noticeMessage}</span>
          </div>
          <button
            type="button"
            onClick={() => setNoticeMessage(null)}
            className="font-bold text-neutral-600 hover:text-black cursor-pointer px-1 text-sm"
          >
            ×
          </button>
        </div>
      )}
      {errorMessage && (
        <div className="px-4 py-2 bg-[#FF0000]/15 border-b-2 border-black text-black font-mono text-xs font-bold flex items-center justify-between animate-in fade-in duration-150">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 bg-[#FF0000] inline-block" />
            <span>{errorMessage}</span>
          </div>
          <button
            type="button"
            onClick={() => setErrorMessage(null)}
            className="font-bold text-neutral-600 hover:text-black cursor-pointer px-1 text-sm"
          >
            ×
          </button>
        </div>
      )}

      {/* Active Category Filter Tag if any */}
      {selectedCategory && (
        <div className="px-4 py-2 bg-neutral-100 border-b border-neutral-300 flex items-center justify-between text-xs font-mono">
          <div className="flex items-center gap-2">
            <span className="text-neutral-500 uppercase">Active Filter:</span>
            <span className="font-bold px-2 py-0.5 bg-black text-white">
              {selectedCategory}
            </span>
          </div>
          <button
            type="button"
            onClick={onClearCategory}
            className="text-xs font-mono font-bold px-2.5 py-1 bg-[#FF0000] text-white border border-black hover:bg-black transition-colors cursor-pointer shadow-[2px_2px_0px_#000000]"
          >
            Clear Filter [X]
          </button>
        </div>
      )}

      {/* Table view */}
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b-2 border-neutral-200 bg-neutral-100/70 text-[11px] font-mono uppercase text-neutral-600">
              {visibleColumns.merchant && (
                <th className="py-3 px-4 sm:px-6">Merchant & Reference</th>
              )}
              {visibleColumns.category && (
                <th className="py-3 px-4">Category / Method</th>
              )}
              {visibleColumns.upi && (
                <th className="py-3 px-4">UPI Identifier & Hash</th>
              )}
              {visibleColumns.location && (
                <th className="py-3 px-4">Location / Map</th>
              )}
              {visibleColumns.amount && (
                <th className="py-3 px-4 sm:px-6 text-right">Amount</th>
              )}
              {visibleColumns.status && (
                <th className="py-3 px-4 text-center">Status</th>
              )}
              {visibleColumns.action && (
                <th className="py-3 px-4 text-center">Action</th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-200 text-xs sm:text-sm">
            {filteredExpenses.length === 0 ? (
              <tr>
                <td
                  colSpan={Object.values(visibleColumns).filter(Boolean).length || 6}
                  className="py-12 text-center text-neutral-500 font-mono text-xs"
                >
                  <p>No matching transactions located in ledger.</p>
                  {hasActiveFilter && (
                    <button
                      type="button"
                      onClick={handleClearAllFilters}
                      className="mt-3 px-3.5 py-1.5 border-2 border-black bg-[#FF0000] text-white hover:bg-black font-bold text-xs cursor-pointer shadow-[2px_2px_0px_#000000] transition-colors"
                    >
                      Clear Filters
                    </button>
                  )}
                </td>
              </tr>
            ) : (
              visibleExpenses.map((tx) => (
                <tr
                  key={tx.id}
                  className="hover:bg-[#FFFFEB]/60 transition-colors group"
                >
                  {/* Merchant & Description */}
                  {visibleColumns.merchant && (
                    <td className="py-3.5 px-4 sm:px-6">
                      <div className="font-bold text-black font-pixel text-sm sm:text-base">
                        {tx.merchantName}
                      </div>
                      <div className="text-xs text-neutral-500 font-sans line-clamp-1">
                        {tx.description || `Payment to ${tx.merchantName}`}
                      </div>
                    </td>
                  )}

                  {/* Category */}
                  {visibleColumns.category && (
                    <td className="py-3.5 px-4 whitespace-nowrap">
                      <span
                        className="inline-flex items-center gap-1.5 px-2 py-1 text-xs border border-black font-mono font-bold"
                        style={{
                          backgroundColor: `${tx.category?.color || "#000000"}15`,
                          borderColor: tx.category?.color || "#000000",
                          color: "#000000",
                        }}
                      >
                        <span
                          className="w-2 h-2 rounded-none inline-block"
                          style={{
                            backgroundColor: tx.category?.color || "#000000",
                          }}
                        />
                        {tx.category?.name || tx.paymentMethod || "UPI"}
                      </span>
                    </td>
                  )}

                  {/* Payment Method & UPI Reference */}
                  {visibleColumns.upi && (
                    <td className="py-3.5 px-4 whitespace-nowrap">
                      <div className="font-mono text-xs text-neutral-700 font-semibold">
                        {tx.upiId || tx.paymentMethod}
                      </div>
                      <div className="flex items-center gap-2 mt-0.5">
                        <span className="font-mono text-[11px] text-neutral-500 truncate max-w-[140px]">
                          {tx.upiTransactionId}
                        </span>
                        <button
                          type="button"
                          onClick={() => copyToClipboard(tx.upiTransactionId)}
                          title="Copy UPI Reference"
                          className="text-[10px] font-mono px-1.5 py-0.5 border border-neutral-300 hover:border-black bg-neutral-50 hover:bg-neutral-200 transition-colors cursor-pointer"
                        >
                          {copiedId === tx.upiTransactionId ? "COPIED" : "COPY"}
                        </button>
                      </div>
                    </td>
                  )}

                  {/* Location & Map Trigger */}
                  {visibleColumns.location && (
                    <td className="py-3.5 px-4 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          onClick={() => setActiveMapTx(tx)}
                          className="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-mono font-bold border-2 border-black bg-white hover:bg-[#D8FF00] hover:text-black transition-colors cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 group"
                          title="View transaction geolocation on interactive map"
                        >
                          <svg
                            className="w-3.5 h-3.5 text-[#FF0000] group-hover:scale-110 transition-transform"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2.5"
                              d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                            />
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2.5"
                              d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                            />
                          </svg>
                          <span>{getTxLocation(tx)}</span>
                          <span className="text-[10px] font-bold text-neutral-500 underline ml-0.5">Map</span>
                        </button>
                      </div>
                    </td>
                  )}

                  {/* Amount */}
                  {visibleColumns.amount && (
                    <td className="py-3.5 px-4 sm:px-6 text-right whitespace-nowrap">
                      <div className="font-doto text-base sm:text-lg font-black text-black">
                        {formatAmount(tx)}
                      </div>
                      <div className="text-[10px] font-mono text-neutral-400">
                        {(tx.createdAt || tx.transactionTime)
                          ? new Date(tx.createdAt || tx.transactionTime).toLocaleDateString("en-US", {
                              month: "short",
                              day: "numeric",
                              hour: "2-digit",
                              minute: "2-digit",
                            })
                          : "Recent"}
                      </div>
                    </td>
                  )}

                  {/* Status Tag */}
                  {visibleColumns.status && (
                    <td className="py-3.5 px-4 text-center whitespace-nowrap">
                      {(() => {
                        const s = (tx.status || "").toUpperCase();
                        const isConfirmed = s === "CONFIRMED" || s === "COMPLETED" || s === "SETTLED";
                        const isCanceled = s === "CANCELED" || s === "CANCELLED" || s === "FAILED" || s === "REJECTED";

                        return (
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-mono font-bold border ${
                              isConfirmed
                                ? "bg-emerald-50 text-emerald-800 border-emerald-300"
                                : isCanceled
                                ? "bg-rose-50 text-rose-800 border-rose-300"
                                : "bg-amber-50 text-amber-800 border-amber-300"
                            }`}
                          >
                            <span
                              className={`w-1.5 h-1.5 rounded-full ${
                                isConfirmed
                                  ? "bg-emerald-600"
                                  : isCanceled
                                  ? "bg-rose-600"
                                  : "bg-amber-500"
                              }`}
                            />
                            {tx.status}
                          </span>
                        );
                      })()}
                    </td>
                  )}

                  {/* Action (Remove from Database) */}
                  {visibleColumns.action && (
                    <td className="py-3.5 px-4 text-center whitespace-nowrap">
                      {confirmingId === tx.id ? (
                        <div className="inline-flex items-center gap-1.5 animate-in fade-in zoom-in-95 duration-100">
                          <button
                            type="button"
                            onClick={() => handleConfirmDelete(tx)}
                            disabled={deletingId === tx.id}
                            className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-black bg-[#FF0000] text-white hover:bg-black transition-colors cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 flex items-center gap-1.5"
                            title="Confirm permanent removal from database"
                          >
                            {deletingId === tx.id ? (
                              <>
                                <span className="w-2.5 h-2.5 border-2 border-white border-t-transparent rounded-full animate-spin inline-block" />
                                <span>Removing...</span>
                              </>
                            ) : (
                              <span>Confirm</span>
                            )}
                          </button>
                          {deletingId !== tx.id && (
                            <button
                              type="button"
                              onClick={() => setConfirmingId(null)}
                              className="px-2 py-1 text-xs font-mono font-bold border-2 border-black bg-neutral-100 hover:bg-neutral-200 text-black cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5"
                              title="Cancel"
                            >
                              ×
                            </button>
                          )}
                        </div>
                      ) : (
                        <button
                          type="button"
                          onClick={() => setConfirmingId(tx.id)}
                          disabled={deletingId !== null}
                          className="px-2.5 py-1 text-xs font-mono font-bold border-2 border-black bg-white hover:bg-[#FF0000] hover:text-white transition-all text-neutral-800 cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 inline-flex items-center gap-1.5 group disabled:opacity-50 disabled:cursor-not-allowed"
                          title="Remove transaction from database"
                        >
                          <svg
                            className="w-3.5 h-3.5 text-neutral-600 group-hover:text-white transition-colors"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                            />
                          </svg>
                          <span>Remove</span>
                        </button>
                      )}
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Footer / More Transactions Bar */}
      {filteredExpenses.length > 5 && (
        <div className="p-3.5 sm:p-4 bg-neutral-50 border-t-2 border-black flex flex-col sm:flex-row items-center justify-between gap-3">
          <span className="text-xs font-mono text-neutral-600">
            Showing <strong className="text-black">{Math.min(visibleCount, filteredExpenses.length)}</strong> of{" "}
            <strong className="text-black">{filteredExpenses.length}</strong> transactions
          </span>

          {visibleCount < filteredExpenses.length ? (
            <button
              type="button"
              onClick={() => setVisibleCount((prev) => prev + 10)}
              className="px-5 py-2 border-2 border-black bg-white hover:bg-black hover:text-white text-xs font-mono font-bold transition-all cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 flex items-center gap-2 group"
            >
              <span>More</span>
              <span className="text-[10px] font-bold bg-[#D8FF00] group-hover:bg-white text-black px-1.5 py-0.5 border border-black transition-colors">
                +10
              </span>
            </button>
          ) : (
            <span className="text-xs font-mono text-neutral-500 font-bold bg-neutral-100 px-3 py-1.5 border border-neutral-300">
              ALL TRANSACTIONS LOADED
            </span>
          )}
        </div>
      )}

      {/* Interactive Geolocation & Map Integration Modal */}
      {activeMapTx && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-150">
          <div className="bg-white border-[3px] border-black shadow-[8px_8px_0px_#000000] w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
            {/* Modal Header */}
            <div className="p-4 bg-[#FFFFEB] border-b-2 border-black flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-3 h-3 bg-[#FF0000] border border-black" />
                <h4 className="font-pixel text-lg sm:text-xl font-bold text-black">
                  Transaction Geolocation Node
                </h4>
              </div>
              <button
                type="button"
                onClick={() => setActiveMapTx(null)}
                className="w-8 h-8 flex items-center justify-center border-2 border-black bg-white hover:bg-[#FF0000] hover:text-white font-mono font-bold text-base transition-colors cursor-pointer shadow-[2px_2px_0px_#000000]"
                title="Close Map"
              >
                ×
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-4 sm:p-6 space-y-4 overflow-y-auto">
              {/* Transaction Metadata Quick Summary */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 font-mono text-xs">
                <div className="p-2 border border-black bg-neutral-50">
                  <span className="text-[10px] text-neutral-500 block uppercase">Merchant</span>
                  <strong className="text-black truncate block">{activeMapTx.merchantName}</strong>
                </div>
                <div className="p-2 border border-black bg-neutral-50">
                  <span className="text-[10px] text-neutral-500 block uppercase">Amount</span>
                  <strong className="text-black block">{formatAmount(activeMapTx)}</strong>
                </div>
                <div className="p-2 border border-black bg-neutral-50">
                  <span className="text-[10px] text-neutral-500 block uppercase">Coordinates</span>
                  <strong className="text-black block truncate">
                    {Number(activeMapTx.latitude || 19.076).toFixed(4)}°, {Number(activeMapTx.longitude || 72.8777).toFixed(4)}°
                  </strong>
                </div>
                <div className="p-2 border border-black bg-neutral-50">
                  <span className="text-[10px] text-neutral-500 block uppercase">Location</span>
                  <strong className="text-black block truncate">{getTxLocation(activeMapTx)}</strong>
                </div>
              </div>

              {/* Embedded Interactive Map View */}
              <div className="relative border-2 border-black h-72 sm:h-80 bg-neutral-100 overflow-hidden shadow-[4px_4px_0px_#000000]">
                {(() => {
                  const lat = Number(activeMapTx.latitude) || 19.0760;
                  const lon = Number(activeMapTx.longitude) || 72.8777;
                  const bbox = `${lon - 0.04},${lat - 0.04},${lon + 0.04},${lat + 0.04}`;
                  const osmEmbedUrl = `https://www.openstreetmap.org/export/embed.html?bbox=${bbox}&layer=mapnik&marker=${lat},${lon}`;

                  return (
                    <iframe
                      title={`Transaction Location - ${activeMapTx.merchantName}`}
                      src={osmEmbedUrl}
                      className="w-full h-full border-0"
                      loading="lazy"
                    />
                  );
                })()}

                {/* Map Overlay Badge */}
                <div className="absolute top-2 left-2 px-2.5 py-1 bg-black text-[#D8FF00] font-mono text-[11px] font-bold border border-black shadow-[2px_2px_0px_rgba(0,0,0,0.5)] flex items-center gap-1.5 pointer-events-none">
                  <span className="w-2 h-2 rounded-full bg-[#62D800] animate-pulse" />
                  <span>GPS POS NODE VERIFIED</span>
                </div>
              </div>

              {/* External Navigation Links */}
              <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
                <span className="text-xs font-mono text-neutral-600">
                  Precision: GPS Hardware QR Scanner / ISP Geocoding
                </span>
                <div className="flex items-center gap-2">
                  <a
                    href={`https://www.google.com/maps/search/?api=1&query=${activeMapTx.latitude || 19.076},${activeMapTx.longitude || 72.8777}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="px-3 py-1.5 border-2 border-black bg-white hover:bg-neutral-100 font-mono text-xs font-bold transition-all cursor-pointer shadow-[2px_2px_0px_#000000] flex items-center gap-1.5"
                  >
                    <span>Google Maps</span>
                    <span>↗</span>
                  </a>
                  <a
                    href={`https://www.openstreetmap.org/?mlat=${activeMapTx.latitude || 19.076}&mlon=${activeMapTx.longitude || 72.8777}#map=16/${activeMapTx.latitude || 19.076}/${activeMapTx.longitude || 72.8777}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="px-3 py-1.5 border-2 border-black bg-[#D8FF00] hover:bg-black hover:text-white font-mono text-xs font-bold transition-all cursor-pointer shadow-[2px_2px_0px_#000000] flex items-center gap-1.5"
                  >
                    <span>OpenStreetMap</span>
                    <span>↗</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
