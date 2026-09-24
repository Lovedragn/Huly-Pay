"use client";

import * as React from "react";

export default function TransactionsTable({
  expenses = [],
  selectedCategory,
  onClearCategory,
  currency = "INR",
  exchangeRate = 83.5,
}) {
  const [searchQuery, setSearchQuery] = React.useState("");
  const [statusFilter, setStatusFilter] = React.useState("ALL");
  const [copiedId, setCopiedId] = React.useState(null);

  const filteredExpenses = React.useMemo(() => {
    return expenses.filter((item) => {
      // Category filter
      if (selectedCategory) {
        const cat = item.category?.name || item.paymentMethod;
        if (cat !== selectedCategory) return false;
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
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 bg-black inline-block" />
            <span className="font-mono text-xs font-bold uppercase tracking-wider text-neutral-800">
              LEDGER AUDIT STREAM • ACTUAL LIVE TRANSACTIONS
            </span>
          </div>
          <h3 className="text-xl sm:text-2xl font-bold font-pixel text-black mt-1">
            Reconciled Transactions & Settlement Log ({filteredExpenses.length})
          </h3>
          <p className="text-xs sm:text-sm text-neutral-600 font-sans mt-0.5">
            Synchronized directly from Supabase PostgreSQL & Spring Boot payments registry
          </p>
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
        </div>
      </div>

      {/* Active Category Filter Tag if any */}
      {selectedCategory && (
        <div className="px-4 py-2 bg-neutral-100 border-b border-neutral-300 flex items-center justify-between text-xs font-mono">
          <div className="flex items-center gap-2">
            <span className="text-neutral-500 uppercase">Active Category Filter:</span>
            <span className="font-bold px-2 py-0.5 bg-black text-white">
              {selectedCategory}
            </span>
          </div>
          <button
            type="button"
            onClick={onClearCategory}
            className="text-neutral-600 hover:text-black underline cursor-pointer"
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
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-200 text-xs sm:text-sm">
            {filteredExpenses.length === 0 ? (
              <tr>
                <td
                  colSpan={5}
                  className="py-12 text-center text-neutral-500 font-mono text-xs"
                >
                  No matching transactions located in ledger.
                </td>
              </tr>
            ) : (
              filteredExpenses.map((tx) => (
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
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
