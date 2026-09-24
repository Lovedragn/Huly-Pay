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
    label: "Total Amount",
    color: "#FF0000", // Brand Red
  },
  averageAmount: {
    label: "Average Ticket",
    color: "#62D800", // Terminal Lime
  },
};

const TIMEFRAMES = [
  { id: "7d", label: "7D", days: 7 },
  { id: "1m", label: "1M", days: 30 },
  { id: "4m", label: "4M", days: 120 },
  { id: "6m", label: "6M", days: 180 },
  { id: "1y", label: "1Y", days: 365 },
  { id: "all", label: "ALL", days: null },
];

export default function AreaChartSpending({
  data = [],
  currency = "INR",
  isTheaterMode: controlledTheaterMode,
  onToggleTheater,
}) {
  const [internalTheaterMode, setInternalTheaterMode] = React.useState(false);
  const isTheater =
    typeof controlledTheaterMode === "boolean"
      ? controlledTheaterMode
      : internalTheaterMode;

  const handleToggleTheater = React.useCallback(() => {
    if (onToggleTheater) {
      onToggleTheater();
    } else {
      setInternalTheaterMode((prev) => !prev);
    }
  }, [onToggleTheater]);

  React.useEffect(() => {
    function handleKeyDown(e) {
      if (e.key === "Escape" && isTheater) {
        handleToggleTheater();
      }
    }
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isTheater, handleToggleTheater]);

  const [timeRange, setTimeRange] = React.useState("1m");
  const [activeMetric, setActiveMetric] = React.useState("amount"); // "amount" | "average"

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  // Filter and format based on time range and currency
  const filteredData = React.useMemo(() => {
    if (!data || data.length === 0) return [];

    let scoped = data;
    if (timeRange !== "all") {
      const selectedTf = TIMEFRAMES.find((t) => t.id === timeRange);
      const days = selectedTf?.days || 30;

      // Extract valid timestamps from items with date
      const timestamps = data
        .map((d) => (d.date ? new Date(d.date).getTime() : NaN))
        .filter((t) => !isNaN(t));

      if (timestamps.length > 0) {
        const maxTime = Math.max(...timestamps);
        const cutoffTime = maxTime - days * 24 * 60 * 60 * 1000;
        const matched = data.filter((item) => {
          if (!item.date) return true;
          const t = new Date(item.date).getTime();
          return isNaN(t) || t >= cutoffTime;
        });
        scoped = matched.length > 0 ? matched : data.slice(-days);
      } else {
        scoped = data.slice(-days);
      }
    }

    if (currency === "USD") {
      return scoped.map((item) => {
        const totalAmount = Number(((item.totalAmount || 0) / rate).toFixed(2));
        const count = item.count || 1;
        const settlements = Number(((item.settlements || 0) / rate).toFixed(2));
        const averageAmount = Number((totalAmount / count).toFixed(2));
        return {
          ...item,
          totalAmount,
          settlements,
          averageAmount,
        };
      });
    }

    return scoped.map((item) => {
      const totalAmount = Math.round(item.totalAmount || 0);
      const count = item.count || 1;
      const settlements = Math.round(item.settlements || 0);
      const averageAmount = Math.round(totalAmount / count);
      return {
        ...item,
        totalAmount,
        settlements,
        averageAmount,
      };
    });
  }, [data, timeRange, currency, rate]);

  const totalPeriodAmount = React.useMemo(() => {
    return filteredData.reduce((acc, curr) => acc + (curr.totalAmount || 0), 0);
  }, [filteredData]);

  const totalPeriodTx = React.useMemo(() => {
    return filteredData.reduce((acc, curr) => acc + (curr.count || 0), 0);
  }, [filteredData]);

  const peakItem = React.useMemo(() => {
    if (!filteredData.length) return null;
    const metricKey = activeMetric === "average" ? "averageAmount" : "totalAmount";
    return filteredData.reduce(
      (prev, curr) =>
        (curr[metricKey] || 0) > (prev?.[metricKey] || 0) ? curr : prev,
      filteredData[0]
    );
  }, [filteredData, activeMetric]);

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header & Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-5 border-b-2 border-neutral-200">
        <div className="flex items-center gap-2.5 sm:gap-3 flex-wrap">
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            Daily Spending
          </h2>
          <button
            type="button"
            onClick={handleToggleTheater}
            className={`px-3 py-1 border-2 border-black font-mono text-xs font-black transition-all cursor-pointer shadow-[2px_2px_0px_#000000] active:translate-x-0.5 active:translate-y-0.5 flex items-center gap-1.5 ${
              isTheater
                ? "bg-[#FF0000] text-white hover:bg-black"
                : "bg-[#D8FF00] text-black hover:bg-black hover:text-white"
            }`}
            title={
              isTheater
                ? "Exit Theater View (normal width) [Esc]"
                : "Theater View: Expand chart to full width of the window"
            }
          >
            {isTheater ? (
              <>
                <svg
                  className="w-3.5 h-3.5 shrink-0"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2.5"
                    d="M9 9L4 4m0 0v4m0-4h4m6 6l5 5m0 0v-4m0 4h-4m-7 5l-5 5m0 0v-4m0 4h4m11-5l5-5m0 0h-4m4 0v4"
                  />
                </svg>
                <span>Exit Theater</span>
              </>
            ) : (
              <>
                <svg
                  className="w-3.5 h-3.5 shrink-0"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2.5"
                    d="M4 8V4m0 0h4M4 4l5 5m11-5h-4m4 0v4m0-4l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"
                  />
                </svg>
                <span>Theater View</span>
              </>
            )}
          </button>
        </div>

        {/* Filters */}
        <div className="flex flex-wrap items-center gap-2">
          {/* Metric Selector: Amount vs Average */}
          <div className="flex border-2 border-black bg-neutral-100 p-0.5 text-xs font-mono">
            <button
              type="button"
              onClick={() => setActiveMetric("amount")}
              className={`px-3 py-1 transition-colors cursor-pointer ${
                activeMetric === "amount"
                  ? "bg-black text-white font-bold"
                  : "text-neutral-700 hover:text-black"
              }`}
            >
              Amount
            </button>
            <button
              type="button"
              onClick={() => setActiveMetric("average")}
              className={`px-3 py-1 transition-colors cursor-pointer ${
                activeMetric === "average"
                  ? "bg-black text-white font-bold"
                  : "text-neutral-700 hover:text-black"
              }`}
            >
              Average
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

      {/* Summary KPI quick indicators */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 py-4 border-b border-neutral-100 my-2">
        <div className="bg-[#FFFFEB] border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Total Amount
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-black">
            {currencySymbol}
            {Math.round(totalPeriodAmount).toLocaleString()}
          </span>
        </div>
        <div className="bg-neutral-50 border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Avg Amount
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-[#058a00]">
            {currencySymbol}
            {filteredData.length > 0
              ? Math.round(totalPeriodAmount / filteredData.length).toLocaleString()
              : 0}
          </span>
        </div>
        <div className="bg-neutral-50 border border-neutral-300 p-2.5">
          <span className="text-[11px] font-mono uppercase text-neutral-500 block">
            Avg Transaction
          </span>
          <span className="font-doto text-lg sm:text-xl font-black text-black">
            {currencySymbol}
            {totalPeriodTx > 0
              ? Math.round(totalPeriodAmount / totalPeriodTx).toLocaleString()
              : 0}
          </span>
        </div>
      </div>

      {/* Area Chart Container */}
      <div
        className={`w-full pt-4 transition-all duration-300 ${
          isTheater ? "min-h-[480px]" : "min-h-[300px]"
        }`}
      >
        <ChartContainer
          config={chartConfig}
          className={`w-full transition-all duration-300 ${
            isTheater ? "h-[480px] sm:h-[520px]" : "h-[320px]"
          }`}
        >
          <AreaChart
            data={filteredData}
            margin={
              isTheater
                ? { top: 20, right: 30, left: -5, bottom: 5 }
                : { top: 10, right: 10, left: -20, bottom: 0 }
            }
          >
            <defs>
              <linearGradient id="fillAmount" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#FF0000" stopOpacity={0.45} />
                <stop offset="95%" stopColor="#FF0000" stopOpacity={0.02} />
              </linearGradient>
              <linearGradient id="fillAverage" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#62D800" stopOpacity={0.45} />
                <stop offset="95%" stopColor="#62D800" stopOpacity={0.02} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey="date"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) => {
                if (!value) return "";
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
                        {currencySymbol}{Number(val).toLocaleString()}
                      </span>
                    </div>
                  )}
                />
              }
            />

            {activeMetric === "amount" && (
              <Area
                type="monotone"
                dataKey="totalAmount"
                name="totalAmount"
                stroke="#FF0000"
                strokeWidth={2.5}
                fill="url(#fillAmount)"
                dot={{ r: 3, fill: "#FF0000", strokeWidth: 1, stroke: "#000" }}
                activeDot={{ r: 6, fill: "#FF0000", stroke: "#000", strokeWidth: 2 }}
              />
            )}

            {activeMetric === "average" && (
              <Area
                type="monotone"
                dataKey="averageAmount"
                name="averageAmount"
                stroke="#62D800"
                strokeWidth={2.5}
                fill="url(#fillAverage)"
                dot={{ r: 3, fill: "#62D800", strokeWidth: 1, stroke: "#000" }}
                activeDot={{ r: 6, fill: "#62D800", stroke: "#000", strokeWidth: 2 }}
              />
            )}
            <ChartLegend content={<ChartLegendContent />} />
          </AreaChart>
        </ChartContainer>
      </div>

      <div className="mt-3 pt-3 border-t border-neutral-200 flex items-center justify-between text-[11px] font-mono text-neutral-500">
        <span>STATUS: 200 OK • STREAM SYNCED</span>
        <span>
          PEAK {activeMetric === "average" ? "AVERAGE" : "AMOUNT"}: {currencySymbol}
          {peakItem
            ? Math.round(
                activeMetric === "average"
                  ? peakItem.averageAmount || 0
                  : peakItem.totalAmount || 0
              ).toLocaleString()
            : 0}{" "}
          • {peakItem?.date || "LIVE"}
        </span>
      </div>
    </div>
  );
}
