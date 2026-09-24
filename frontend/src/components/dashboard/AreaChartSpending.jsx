"use client";

import * as React from "react";
import {
  Area,
  AreaChart,
  CartesianGrid,
  XAxis,
  YAxis,
  ResponsiveContainer,
} from "recharts";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  ChartLegend,
  ChartLegendContent,
} from "@/components/ui/chart";

const chartConfig = {
  totalAmount: {
    label: "Total Spent ($)",
    color: "#FF0000", // Brand Red
  },
  settlements: {
    label: "Settled Volume ($)",
    color: "#62D800", // Terminal Lime
  },
  count: {
    label: "Tx Count",
    color: "#FF00F5", // Neon Magenta
  },
};

export default function AreaChartSpending({ data = [], currency = "INR" }) {
  const [timeRange, setTimeRange] = React.useState("30d");
  const [activeMetric, setActiveMetric] = React.useState("both"); // "amount", "count", "both"

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  // Filter and format based on time range and currency
  const filteredData = React.useMemo(() => {
    if (!data || data.length === 0) return [];
    const sliced =
      timeRange === "7d"
        ? data.slice(-7)
        : timeRange === "14d"
        ? data.slice(-14)
        : data;

    if (currency === "USD") {
      return sliced.map((item) => ({
        ...item,
        totalAmount: Number(((item.totalAmount || 0) / rate).toFixed(2)),
        settlements: Number(((item.settlements || 0) / rate).toFixed(2)),
      }));
    }
    return sliced;
  }, [data, timeRange, currency, rate]);

  const totalPeriodAmount = React.useMemo(() => {
    return filteredData.reduce((acc, curr) => acc + (curr.totalAmount || 0), 0);
  }, [filteredData]);

  const totalPeriodTx = React.useMemo(() => {
    return filteredData.reduce((acc, curr) => acc + (curr.count || 0), 0);
  }, [filteredData]);

  const peakItem = React.useMemo(() => {
    if (!filteredData.length) return null;
    return filteredData.reduce(
      (prev, curr) =>
        (curr.totalAmount || 0) > (prev?.totalAmount || 0) ? curr : prev,
      filteredData[0]
    );
  }, [filteredData]);

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header & Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b-2 border-neutral-200">
        <div>
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 bg-[#FF0000] inline-block animate-pulse" />
            <span className="font-mono text-xs font-bold uppercase tracking-wider text-[#FF0000]">
              ANALYTICS STREAM • AREA CHART
            </span>
          </div>
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black mt-1">
            Settlement Velocity & Daily Volume
          </h2>
          <p className="text-xs sm:text-sm text-neutral-600 font-sans mt-0.5">
            Real-time daily expense outflow from Spring Boot backend (
            <code className="text-xs bg-neutral-100 px-1 py-0.5 font-mono">
              /api/v1/analytics/daily-spending
            </code>
            )
          </p>
        </div>

        {/* Filters */}
        <div className="flex flex-wrap items-center gap-2">
          {/* Metric Selector */}
          <div className="flex border-2 border-black bg-neutral-100 p-0.5 text-xs font-mono">
            <button
              onClick={() => setActiveMetric("both")}
              className={`px-2.5 py-1 transition-colors ${
                activeMetric === "both"
                  ? "bg-black text-white font-bold"
                  : "text-neutral-700 hover:text-black"
              }`}
            >
              Dual View
            </button>
            <button
              onClick={() => setActiveMetric("amount")}
              className={`px-2.5 py-1 transition-colors ${
                activeMetric === "amount"
                  ? "bg-black text-white font-bold"
                  : "text-neutral-700 hover:text-black"
              }`}
            >
              Amount Only
            </button>
            <button
              onClick={() => setActiveMetric("count")}
              className={`px-2.5 py-1 transition-colors ${
                activeMetric === "count"
                  ? "bg-black text-white font-bold"
                  : "text-neutral-700 hover:text-black"
              }`}
            >
              Tx Count
            </button>
          </div>

          {/* Timeframe Selector */}
          <div className="flex border-2 border-black bg-neutral-100 p-0.5 text-xs font-mono">
            {["7d", "14d", "30d"].map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-2.5 py-1 uppercase transition-colors ${
                  timeRange === range
                    ? "bg-[#62D800] text-black font-black"
                    : "text-neutral-700 hover:text-black"
                }`}
              >
                {range}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Summary KPI quick indicators */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 py-4 border-b border-neutral-100 my-2">
        <div className="bg-[#FFFFEB] border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Period Volume
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-black">
            {currencySymbol}
            {totalPeriodAmount.toLocaleString()}
          </span>
        </div>
        <div className="bg-neutral-50 border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Total Tx Count
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-[#62D800]">
            {totalPeriodTx} txs
          </span>
        </div>
        <div className="bg-neutral-50 border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Avg Daily Burn
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-black">
            {currencySymbol}
            {filteredData.length > 0
              ? Math.round(totalPeriodAmount / filteredData.length).toLocaleString()
              : 0}
          </span>
        </div>
        <div className="bg-[#FFFFEB] border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Settlement SLA
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-[#FF00F5]">
            99.98%
          </span>
        </div>
      </div>

      {/* Area Chart Container */}
      <div className="w-full pt-4 min-h-[300px]">
        <ChartContainer config={chartConfig} className="w-full h-[320px]">
          <AreaChart
            data={filteredData}
            margin={{ top: 10, right: 10, left: -20, bottom: 0 }}
          >
            <defs>
              <linearGradient id="fillSpending" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#FF0000" stopOpacity={0.45} />
                <stop offset="95%" stopColor="#FF0000" stopOpacity={0.02} />
              </linearGradient>
              <linearGradient id="fillSettlement" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#62D800" stopOpacity={0.35} />
                <stop offset="95%" stopColor="#62D800" stopOpacity={0.02} />
              </linearGradient>
              <linearGradient id="fillCount" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#FF00F5" stopOpacity={0.4} />
                <stop offset="95%" stopColor="#FF00F5" stopOpacity={0.02} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey="date"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) => {
                const parts = value.split("-");
                return parts.length >= 3 ? `${parts[1]}/${parts[2]}` : value;
              }}
              style={{ fontSize: "11px" }}
            />
            <YAxis
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) =>
                value >= 1000
                  ? `${currencySymbol}${(value / 1000).toFixed(0)}k`
                  : `${currencySymbol}${value}`
              }
              style={{ fontSize: "11px" }}
            />
            <ChartTooltip
              cursor={{ stroke: "#000000", strokeWidth: 1.5, strokeDasharray: "4 4" }}
              content={
                <ChartTooltipContent
                  indicator="dot"
                  labelFormatter={(value) => `Date: ${value}`}
                  formatter={(val, name) => (
                    <div className="flex items-center justify-between w-full gap-3">
                      <span className="text-neutral-600 font-pixel text-xs">
                        {chartConfig[name]?.label || name}:
                      </span>
                      <span className="font-doto font-bold text-black">
                        {name === "count"
                          ? `${val} txs`
                          : `${currencySymbol}${Number(val).toLocaleString()}`}
                      </span>
                    </div>
                  )}
                />
              }
            />

            {(activeMetric === "both" || activeMetric === "amount") && (
              <Area
                type="monotone"
                dataKey="totalAmount"
                stroke="#FF0000"
                strokeWidth={2.5}
                fill="url(#fillSpending)"
                dot={{ r: 3, fill: "#FF0000", strokeWidth: 1, stroke: "#000" }}
                activeDot={{ r: 6, fill: "#FF0000", stroke: "#000", strokeWidth: 2 }}
              />
            )}

            {activeMetric === "both" && (
              <Area
                type="monotone"
                dataKey="settlements"
                stroke="#62D800"
                strokeWidth={2}
                fill="url(#fillSettlement)"
                dot={false}
              />
            )}

            {activeMetric === "count" && (
              <Area
                type="stepAfter"
                dataKey="count"
                stroke="#FF00F5"
                strokeWidth={2.5}
                fill="url(#fillCount)"
                dot={{ r: 4, fill: "#FF00F5", strokeWidth: 1, stroke: "#000" }}
              />
            )}
            <ChartLegend content={<ChartLegendContent />} />
          </AreaChart>
        </ChartContainer>
      </div>

      <div className="mt-3 pt-3 border-t border-neutral-200 flex items-center justify-between text-[11px] font-mono text-neutral-500">
        <span>STATUS: 200 OK • STREAM SYNCED</span>
        <span>
          PEAK: {currencySymbol}
          {peakItem?.totalAmount
            ? Math.round(peakItem.totalAmount).toLocaleString()
            : 0}{" "}
          • {peakItem?.date || "LIVE"}
        </span>
      </div>
    </div>
  );
}
