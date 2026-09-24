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

      // Status filter
      if (statusFilter !== "ALL") {
        const s = (item.status || "").toUpperCase();
        if (
          statusFilter === "CONFIRMED" &&
          s !== "CONFIRMED" &&
          s !== "COMPLETED" &&
          s !== "SETTLED"
        ) {
          return false;
        }
        if (statusFilter === "PENDING" && s !== "PENDING") {
          return false;
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
          {/* Search Input */}
          <div className="relative">
            <input
              type="text"
              placeholder="Search merchant, UPI ID..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="px-3 py-1.5 text-xs font-mono border-2 border-black bg-white focus:outline-none focus:ring-2 focus:ring-[#FF0000] w-48 sm:w-56"
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

          {/* Status selector */}
          <div className="flex border-2 border-black bg-white p-0.5 text-xs font-mono">
            {["ALL", "CONFIRMED", "PENDING"].map((status) => (
              <button
                type="button"
                key={status}
                onClick={() => setStatusFilter(status)}
                className={`px-2.5 py-1 transition-colors cursor-pointer ${
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
              <th className="py-3 px-4 sm:px-6">Merchant & Reference</th>
              <th className="py-3 px-4">Category / Method</th>
              <th className="py-3 px-4">UPI Identifier & Hash</th>
              <th className="py-3 px-4 sm:px-6 text-right">Amount</th>
              <th className="py-3 px-4 text-center">Status</th>
              <th className="py-3 px-4 text-center">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-200 text-xs sm:text-sm">
            {filteredExpenses.length === 0 ? (
              <tr>
                <td
                  colSpan={6}
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
                  <td className="py-3.5 px-4 sm:px-6">
                    <div className="font-bold text-black font-pixel text-sm sm:text-base">
                      {tx.merchantName}
                    </div>
                    <div className="text-xs text-neutral-500 font-sans line-clamp-1">
                      {tx.description || `Payment to ${tx.merchantName}`}
                    </div>
                  </td>

                  {/* Category */}
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

                  {/* Payment Method & UPI Reference */}
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

                  {/* Amount */}
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

                  {/* Status Tag */}
                  <td className="py-3.5 px-4 text-center whitespace-nowrap">
                    <span
                      className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-mono font-bold border ${
                        tx.status === "CONFIRMED" ||
                        tx.status === "COMPLETED" ||
                        tx.status === "SETTLED"
                          ? "bg-emerald-50 text-emerald-800 border-emerald-300"
                          : "bg-amber-50 text-amber-800 border-amber-300"
                      }`}
                    >
                      <span
                        className={`w-1.5 h-1.5 rounded-full ${
                          tx.status === "CONFIRMED" ||
                          tx.status === "COMPLETED" ||
                          tx.status === "SETTLED"
                            ? "bg-emerald-600"
                            : "bg-amber-500"
                        }`}
                      />
                      {tx.status}
                    </span>
                  </td>

                  {/* Action (Remove from Database) */}
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
    </div>
  );
}
