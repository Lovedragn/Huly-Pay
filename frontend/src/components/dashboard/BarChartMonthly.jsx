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

const TIMEFRAMES = [
  { id: "7d", label: "7D", days: 7 },
  { id: "1m", label: "1M", days: 30 },
  { id: "4m", label: "4M", days: 120 },
  { id: "6m", label: "6M", days: 180 },
  { id: "1y", label: "1Y", days: 365 },
  { id: "all", label: "ALL", days: null },
];

export default function BarChartMonthly({
  data = [],
  dailyData = [],
  expenses = [],
  currency = "INR",
}) {
  const [timeRange, setTimeRange] = React.useState("1m");
  const [viewMode, setViewMode] = React.useState("spendingVsBudget"); // "spendingVsBudget" or "txCount"

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  const chartConfig = {
    budget: {
      label: `Budget Cap (${currencySymbol})`,
      color: "#62D800", // Terminal Lime (Green)
    },
    totalAmount: {
      label: `Spended (${currencySymbol})`,
      color: "#000000", // Monolith Black
    },
    count: {
      label: "Transactions (Count)",
      color: "#FF00F5", // Neon Magenta
    },
  };

  const formattedData = React.useMemo(() => {
    // 1. Calculate base monthly budget from available data
    const latestMonthBudget =
      data && data.length > 0
        ? data[data.length - 1].budget || 60000
        : 60000;

    // 2. Determine reference latest date
    let latestDate = new Date();
    if (expenses && expenses.length > 0) {
      const ts = expenses
        .map((e) => (e.date ? new Date(e.date).getTime() : NaN))
        .filter((t) => !isNaN(t) && t > 0);
      if (ts.length > 0) latestDate = new Date(Math.max(...ts));
    } else if (dailyData && dailyData.length > 0) {
      const ts = dailyData
        .map((d) => (d.date ? new Date(d.date).getTime() : NaN))
        .filter((t) => !isNaN(t) && t > 0);
      if (ts.length > 0) latestDate = new Date(Math.max(...ts));
    }

    let result = [];

    if (timeRange === "7d") {
      // 7 Days: Daily breakdown over last 7 days
      const dailyBudget = Math.round(latestMonthBudget / 30);
      for (let i = 6; i >= 0; i--) {
        const d = new Date(latestDate);
        d.setDate(d.getDate() - i);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, "0");
        const dd = String(d.getDate()).padStart(2, "0");
        const dateStr = `${yyyy}-${mm}-${dd}`;

        const dayTx = (expenses || []).filter((e) => e.date === dateStr);
        let daySpent = dayTx.reduce((sum, e) => sum + (Number(e.amount) || 0), 0);
        let dayCount = dayTx.length;

        if (dayCount === 0 && dailyData && dailyData.length > 0) {
          const match = dailyData.find((item) => item.date === dateStr);
          if (match) {
            daySpent = match.totalAmount || 0;
            dayCount = match.count || 0;
          }
        }

        const label = d.toLocaleDateString("en-US", {
          day: "2-digit",
          month: "short",
        });

        result.push({
          label,
          rawDate: dateStr,
          totalAmount: daySpent,
          budget: dailyBudget,
          count: dayCount,
        });
      }
    } else if (timeRange === "1m") {
      // 1 Month: 4 weekly milestone buckets of the active month
      const activeYear = latestDate.getFullYear();
      const activeMonthIdx = latestDate.getMonth();
      const weeklyBudget = Math.round(latestMonthBudget / 4);

      const weeks = [
        { label: "W1 (1-7)", start: 1, end: 7 },
        { label: "W2 (8-14)", start: 8, end: 14 },
        { label: "W3 (15-21)", start: 15, end: 21 },
        { label: "W4 (22+)", start: 22, end: 31 },
      ];

      weeks.forEach((w) => {
        const weekTx = (expenses || []).filter((e) => {
          if (!e.date) return false;
          const parts = e.date.split("-");
          if (parts.length < 3) return false;
          const y = parseInt(parts[0], 10);
          const m = parseInt(parts[1], 10) - 1;
          const day = parseInt(parts[2], 10);
          return y === activeYear && m === activeMonthIdx && day >= w.start && day <= w.end;
        });

        let weekSpent = weekTx.reduce((sum, e) => sum + (Number(e.amount) || 0), 0);
        let weekCount = weekTx.length;

        if (weekCount === 0 && dailyData && dailyData.length > 0) {
          dailyData.forEach((d) => {
            if (!d.date) return;
            const parts = d.date.split("-");
            if (parts.length < 3) return;
            const y = parseInt(parts[0], 10);
            const m = parseInt(parts[1], 10) - 1;
            const day = parseInt(parts[2], 10);
            if (y === activeYear && m === activeMonthIdx && day >= w.start && day <= w.end) {
              weekSpent += d.totalAmount || 0;
              weekCount += d.count || 0;
            }
          });
        }

        result.push({
          label: w.label,
          totalAmount: weekSpent,
          budget: weeklyBudget,
          count: weekCount,
        });
      });
    } else {
      // 4m, 6m, 1y, all -> Monthly aggregation
      let numMonths = 12;
      if (timeRange === "4m") numMonths = 4;
      else if (timeRange === "6m") numMonths = 6;
      else if (timeRange === "1y") numMonths = 12;
      else if (timeRange === "all") numMonths = Math.max(data.length, 6);

      const monthNames = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
      ];

      for (let i = numMonths - 1; i >= 0; i--) {
        const d = new Date(latestDate.getFullYear(), latestDate.getMonth() - i, 1);
        const y = d.getFullYear();
        const mIdx = d.getMonth();
        const rawMonth = `${y}-${String(mIdx + 1).padStart(2, "0")}`;
        const label = `${monthNames[mIdx]} ${String(y).slice(2)}`;

        const existing = (data || []).find(
          (item) => item.rawMonth === rawMonth || item.month === label
        );

        if (existing) {
          result.push({
            label: existing.month || label,
            rawMonth,
            totalAmount: existing.totalAmount || 0,
            budget: existing.budget || latestMonthBudget,
            count: existing.count || 0,
          });
        } else {
          result.push({
            label,
            rawMonth,
            totalAmount: 0,
            budget: latestMonthBudget,
            count: 0,
          });
        }
      }
    }

    // Convert currency if USD
    if (currency === "USD") {
      return result.map((item) => ({
        ...item,
        totalAmount: Number(((item.totalAmount || 0) / rate).toFixed(2)),
        budget: Number(((item.budget || 0) / rate).toFixed(2)),
      }));
    }

    return result;
  }, [data, dailyData, expenses, currency, rate, timeRange]);

  // Aggregate stats across the active scope
  const totalSpentInView = React.useMemo(() => {
    return formattedData.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
  }, [formattedData]);

  const totalBudgetInView = React.useMemo(() => {
    return formattedData.reduce((sum, item) => sum + (item.budget || 0), 0);
  }, [formattedData]);

  const budgetPct = React.useMemo(() => {
    if (totalBudgetInView <= 0) return 0;
    return Math.round((totalSpentInView / totalBudgetInView) * 100);
  }, [totalSpentInView, totalBudgetInView]);

  const { barSizeBudget, barSizeSpent } = React.useMemo(() => {
    const len = formattedData.length;
    if (len <= 4) return { barSizeBudget: 44, barSizeSpent: 22 };
    if (len <= 7) return { barSizeBudget: 36, barSizeSpent: 18 };
    if (len <= 12) return { barSizeBudget: 24, barSizeSpent: 12 };
    return { barSizeBudget: 20, barSizeSpent: 10 };
  }, [formattedData.length]);

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header & Controls */}
      <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4 pb-5 border-b-2 border-neutral-200">
        <div>
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            Budget Chart
          </h2>
        </div>

        {/* Controls: View Toggle & Timeframe Selector */}
        <div className="flex flex-wrap items-center justify-end gap-2 ml-auto">
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
              Count
            </button>
          </div>

          {/* Timeframe Selector: 7d, 1m, 4m, 6m, 1y, all */}
          <div className="flex border-2 border-black bg-neutral-100 p-0.5 text-xs font-mono">
            {TIMEFRAMES.map((t) => (
              <button
                key={t.id}
                type="button"
                onClick={() => setTimeRange(t.id)}
                className={`px-2 sm:px-2.5 py-1 uppercase transition-colors cursor-pointer ${
                  timeRange === t.id
                    ? "bg-[#62D800] text-black font-black"
                    : "text-neutral-700 hover:text-black"
                }`}
              >
                {t.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Highlights Bar with Visual Legend */}
      <div className="flex flex-wrap items-center justify-between gap-3 py-3 bg-neutral-50 px-3 border border-neutral-200 my-3">
        {/* Overlapping Legend Indicators */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="w-3.5 h-3.5 bg-[#62D800] border border-black inline-block"></span>
            <span className="text-xs font-mono font-bold uppercase text-neutral-700">
              Budget Cap
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="w-3.5 h-3.5 bg-black border border-black inline-block"></span>
            <span className="text-xs font-mono font-bold uppercase text-neutral-700">
              Spended
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs font-mono text-neutral-500 uppercase">
            Total Spended:
          </span>
          <span className="font-doto font-bold text-black text-base">
            {currencySymbol}
            {totalSpentInView.toLocaleString(undefined, {
              minimumFractionDigits: 0,
              maximumFractionDigits: 2,
            })}
          </span>
        </div>

        <div className="flex items-center gap-3 text-xs font-mono">
          <span className="text-neutral-500">Run-Rate:</span>
          <span
            className={`px-2 py-0.5 border border-black font-bold ${
              budgetPct > 100
                ? "bg-[#FF0000] text-white"
                : "bg-[#62D800] text-black"
            }`}
          >
            {budgetPct}% OF CAP
          </span>
        </div>
      </div>

      {/* Chart Canvas with Overlapping Bars */}
      <div className="w-full pt-2 min-h-[300px]">
        <ChartContainer config={chartConfig} className="w-full h-[320px]">
          <BarChart
            data={formattedData}
            margin={{ top: 15, right: 10, left: -20, bottom: 0 }}
            barGap="-100%"
          >
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey="label"
              tickLine={false}
              tickMargin={10}
              axisLine={false}
              style={{ fontSize: "11px", fontWeight: "600" }}
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
                {/* Outer/Background: Budget Bar in Green (#62D800) */}
                <Bar
                  dataKey="budget"
                  name="budget"
                  fill="#62D800"
                  radius={[3, 3, 0, 0]}
                  stroke="#000000"
                  strokeWidth={1.5}
                  barSize={barSizeBudget}
                />
                {/* Inner/Foreground: Spended Bar in Black (#000000) */}
                <Bar
                  dataKey="totalAmount"
                  name="totalAmount"
                  fill="#000000"
                  radius={[3, 3, 0, 0]}
                  stroke="#000000"
                  strokeWidth={1.5}
                  barSize={barSizeSpent}
                />
              </>
            ) : (
              <Bar
                dataKey="count"
                name="count"
                fill="#FF00F5"
                radius={[3, 3, 0, 0]}
                stroke="#000000"
                strokeWidth={1.5}
                barSize={24}
              />
            )}
          </BarChart>
        </ChartContainer>
      </div>
    </div>
  );
}
