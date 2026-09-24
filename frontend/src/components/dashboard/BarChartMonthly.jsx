"use client";

import * as React from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  XAxis,
  YAxis,
} from "recharts";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";

export default function BarChartMonthly({ data = [], currency = "INR" }) {
  const [viewMode, setViewMode] = React.useState("spendingVsBudget"); // "spendingVsBudget" or "txCount"

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  const chartConfig = {
    totalAmount: {
      label: `Actual Outflow (${currencySymbol})`,
      color: "#62D800", // Terminal Lime
    },
    budget: {
      label: `Budget Cap (${currencySymbol})`,
      color: "#000000", // Monolith Black
    },
    count: {
      label: "Transactions (Count)",
      color: "#FF00F5", // Neon Magenta
    },
  };

  const formattedData = React.useMemo(() => {
    if (!data || data.length === 0) return [];
    if (currency === "USD") {
      return data.map((item) => ({
        ...item,
        totalAmount: Number(((item.totalAmount || 0) / rate).toFixed(2)),
        budget: Number(((item.budget || 0) / rate).toFixed(2)),
      }));
    }
    return data;
  }, [data, currency, rate]);

  const latestMonth = React.useMemo(() => {
    if (!formattedData.length) return null;
    return formattedData[formattedData.length - 1];
  }, [formattedData]);

  const budgetPct = latestMonth && latestMonth.budget > 0
    ? Math.min(100, Math.round((latestMonth.totalAmount / latestMonth.budget) * 100))
    : 85;

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header & Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b-2 border-neutral-200">
        <div>
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            Monthly Spending vs Budget
          </h2>
        </div>

        {/* View Toggle */}
        <div className="flex border-2 border-black bg-neutral-100 p-0.5 text-xs font-mono">
          <button
            type="button"
            onClick={() => setViewMode("spendingVsBudget")}
            className={`px-3 py-1 transition-colors cursor-pointer ${
              viewMode === "spendingVsBudget"
                ? "bg-black text-white font-bold"
                : "text-neutral-700 hover:text-black"
            }`}
          >
            Spend vs Budget
          </button>
          <button
            type="button"
            onClick={() => setViewMode("txCount")}
            className={`px-3 py-1 transition-colors cursor-pointer ${
              viewMode === "txCount"
                ? "bg-[#62D800] text-black font-black"
                : "text-neutral-700 hover:text-black"
            }`}
          >
            Transaction Count
          </button>
        </div>
      </div>

      {/* Highlights Bar */}
      <div className="flex flex-wrap items-center justify-between gap-2 py-3 bg-neutral-50 px-3 border border-neutral-200 my-3">
        <div className="flex items-center gap-2">
          <span className="text-xs font-mono text-neutral-500 uppercase">
            Active Month ({latestMonth?.month || "Current"}):
          </span>
          <span className="font-doto font-bold text-black text-base">
            {currencySymbol}
            {latestMonth ? Number(latestMonth.totalAmount).toLocaleString() : "0"}
          </span>
        </div>
        <div className="flex items-center gap-3 text-xs font-mono">
          <span className="text-neutral-500">Run-Rate Budget:</span>
          <span className="px-2 py-0.5 bg-[#D8FF00] text-black border border-black font-bold">
            {budgetPct}% OF CAP
          </span>
        </div>
      </div>

      {/* Chart */}
      <div className="w-full pt-2 min-h-[300px]">
        <ChartContainer config={chartConfig} className="w-full h-[320px]">
          <BarChart
            data={formattedData}
            margin={{ top: 15, right: 10, left: -20, bottom: 0 }}
          >
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey="month"
              tickLine={false}
              tickMargin={10}
              axisLine={false}
              style={{ fontSize: "11px" }}
            />
            <YAxis
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) =>
                viewMode === "txCount"
                  ? `${value} tx`
                  : value >= 1000
                  ? `${currencySymbol}${(value / 1000).toFixed(0)}k`
                  : `${currencySymbol}${value}`
              }
              style={{ fontSize: "11px" }}
            />
            <ChartTooltip
              cursor={{ fill: "rgba(0, 0, 0, 0.04)" }}
              content={
                <ChartTooltipContent
                  indicator="dot"
                  formatter={(val, name) => (
                    <div className="flex items-center justify-between w-full gap-3">
                      <span className="text-neutral-600 font-pixel text-xs">
                        {chartConfig[name]?.label || name}:
                      </span>
                      <span className="font-doto font-bold text-black">
                        {name === "count"
                          ? `${val} transactions`
                          : `${currencySymbol}${Number(val).toLocaleString()}`}
                      </span>
                    </div>
                  )}
                />
              }
            />

            {viewMode === "spendingVsBudget" ? (
              <>
                <Bar
                  dataKey="totalAmount"
                  fill="#62D800"
                  radius={[3, 3, 0, 0]}
                  stroke="#000000"
                  strokeWidth={1.5}
                />
                <Bar
                  dataKey="budget"
                  fill="#000000"
                  radius={[3, 3, 0, 0]}
                  stroke="#000000"
                  strokeWidth={1.5}
                />
              </>
            ) : (
              <Bar
                dataKey="count"
                fill="#FF00F5"
                radius={[3, 3, 0, 0]}
                stroke="#000000"
                strokeWidth={1.5}
              />
            )}
          </BarChart>
        </ChartContainer>
      </div>
    </div>
  );
}
