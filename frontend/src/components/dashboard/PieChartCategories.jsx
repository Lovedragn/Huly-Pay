"use client";

import * as React from "react";
import { Pie, PieChart, Cell, Label, ResponsiveContainer } from "recharts";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";

const chartConfig = {
  totalAmount: {
    label: "Amount ($)",
  },
  "Cloud Infrastructure": {
    label: "Cloud Infrastructure",
    color: "#FF0000",
  },
  "SaaS & Developer Tools": {
    label: "SaaS Tools",
    color: "#FF00F5",
  },
  "Hardware & POS Terminals": {
    label: "Hardware & POS",
    color: "#62D800",
  },
  "Payment Gateway Fees": {
    label: "Payment Fees",
    color: "#D8FF00",
  },
  "Growth & Global Marketing": {
    label: "Marketing",
    color: "#00E5FF",
  },
  "Office & Operations": {
    label: "Operations",
    color: "#71717A",
  },
};

export default function PieChartCategories({
  data = [],
  expenses = [],
  selectedCategory,
  onSelectCategory,
  currency = "INR",
}) {
  const [viewMode, setViewMode] = React.useState("category"); // "category" | "merchant"
  const [activeIndex, setActiveIndex] = React.useState(null);

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  // 1. Category-based aggregation
  const formattedCategoryData = React.useMemo(() => {
    if (!data || data.length === 0) return [];
    if (currency === "USD") {
      return data.map((item) => ({
        ...item,
        totalAmount: Number(((item.totalAmount || 0) / rate).toFixed(2)),
      }));
    }
    return data;
  }, [data, currency, rate]);

  // 2. Merchandise / Single Transaction Grouped by Store / Merchant
  const merchantData = React.useMemo(() => {
    if (!expenses || expenses.length === 0) return [];

    const merchantMap = {};
    expenses.forEach((item) => {
      const rawName = (
        item.merchantName ||
        item.provider ||
        "Other Merchant"
      ).trim();
      const rawAmt = Number(item.amount) || 0;
      const amt = currency === "USD" ? rawAmt / rate : rawAmt;

      if (!merchantMap[rawName]) {
        merchantMap[rawName] = {
          name: rawName,
          category: rawName,
          totalAmount: 0,
          count: 0,
        };
      }
      merchantMap[rawName].totalAmount += amt;
      merchantMap[rawName].count += 1;
    });

    const totalOutflow = Object.values(merchantMap).reduce(
      (acc, curr) => acc + curr.totalAmount,
      0
    );

    const PALETTE = [
      "#FF0000", // Red
      "#FF00F5", // Neon Magenta
      "#62D800", // Lime
      "#D8FF00", // Cyber Yellow
      "#00E5FF", // Electric Cyan
      "#FF7A00", // Orange
      "#7B2CBF", // Vivid Purple
      "#00F5D4", // Mint
      "#F72585", // Cyber Fuchsia
      "#4361EE", // Indigo
      "#4CC9F0", // Sky Blue
      "#FFE600", // Signal Yellow
    ];

    const sorted = Object.values(merchantMap).sort(
      (a, b) => b.totalAmount - a.totalAmount
    );

    return sorted.map((m, idx) => ({
      ...m,
      totalAmount: Number(m.totalAmount.toFixed(2)),
      percentage:
        totalOutflow > 0
          ? Number(((m.totalAmount / totalOutflow) * 100).toFixed(1))
          : 0,
      color: PALETTE[idx % PALETTE.length],
    }));
  }, [expenses, currency, rate]);

  // Active dataset based on view mode
  const currentData =
    viewMode === "merchant" ? merchantData : formattedCategoryData;

  const totalAmount = React.useMemo(() => {
    return currentData.reduce(
      (acc, curr) => acc + (curr.totalAmount || 0),
      0
    );
  }, [currentData]);

  const activeItem =
    activeIndex !== null && currentData[activeIndex]
      ? currentData[activeIndex]
      : null;

  // Dynamic ChartConfig for Recharts
  const dynamicConfig = React.useMemo(() => {
    const cfg = {
      totalAmount: { label: "Amount" },
    };
    currentData.forEach((item) => {
      const key = item.category || item.name;
      cfg[key] = {
        label: key,
        color: item.color || "#000000",
      };
    });
    return cfg;
  }, [currentData]);

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header with Title and Mode Switcher Button */}
      <div className="pb-4 border-b-2 border-neutral-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-2 sm:gap-3 flex-wrap">
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            {viewMode === "category"
              ? "Category Breakdown"
              : "Merchandise Outflow"}
          </h2>
          {selectedCategory && (
            <button
              type="button"
              onClick={() => onSelectCategory && onSelectCategory(null)}
              className="text-xs font-mono font-bold px-2 py-0.5 border border-black bg-[#FF0000] text-white hover:bg-black transition-colors cursor-pointer shadow-[2px_2px_0px_#000000]"
              title="Reset active slice filter"
            >
              Reset [X]
            </button>
          )}
        </div>

        {/* Segmentation Mode Toggle Button */}
        <div className="flex border-2 border-black bg-white p-0.5 text-xs font-mono shrink-0 shadow-[2px_2px_0px_#000000]">
          <button
            type="button"
            onClick={() => {
              setViewMode("category");
              setActiveIndex(null);
            }}
            className={`px-2.5 sm:px-3 py-1 transition-colors cursor-pointer font-bold flex items-center gap-1.5 ${
              viewMode === "category"
                ? "bg-black text-white"
                : "text-neutral-700 hover:text-black hover:bg-neutral-100"
            }`}
            title="View spending grouped by Category"
          >
            <span>Category</span>
          </button>
          <button
            type="button"
            onClick={() => {
              setViewMode("merchant");
              setActiveIndex(null);
            }}
            className={`px-2.5 sm:px-3 py-1 transition-colors cursor-pointer font-bold flex items-center gap-1.5 ${
              viewMode === "merchant"
                ? "bg-black text-white"
                : "text-neutral-700 hover:text-black hover:bg-neutral-100"
            }`}
            title="View single transactions grouped by merchandise / merchant"
          >
            <span>Merchandise</span>
            {merchantData.length > 0 && (
              <span
                className={`text-[10px] px-1 py-0.2 border leading-none ${
                  viewMode === "merchant"
                    ? "bg-[#D8FF00] text-black border-black font-black"
                    : "bg-neutral-200 text-neutral-800 border-neutral-400"
                }`}
              >
                {merchantData.length}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* Donut Chart with center label */}
      <div className="w-full flex items-center justify-center pt-2">
        {currentData.length === 0 ? (
          <div className="py-16 text-center text-neutral-500 font-mono text-xs">
            No transactions found for this view mode.
          </div>
        ) : (
          <ChartContainer
            config={dynamicConfig}
            className="mx-auto aspect-square max-h-[260px] w-full"
          >
            <PieChart>
              <ChartTooltip
                cursor={false}
                content={
                  <ChartTooltipContent
                    hideLabel
                    formatter={(val, name, item) => (
                      <div className="flex flex-col gap-1">
                        <div className="flex items-center gap-1.5">
                          <span
                            className="w-2 h-2 inline-block shrink-0"
                            style={{
                              backgroundColor:
                                item.payload.color || "#000000",
                            }}
                          />
                          <span className="font-pixel text-xs text-neutral-800 font-bold truncate max-w-[170px]">
                            {item.payload.category || item.payload.name}
                          </span>
                        </div>
                        <div className="flex items-center justify-between gap-4 font-mono">
                          <span className="font-doto font-bold text-black text-sm">
                            {currencySymbol}
                            {Number(val).toLocaleString()}
                          </span>
                          <div className="flex items-center gap-1.5">
                            {item.payload.count && (
                              <span className="text-[10px] text-neutral-500 font-sans">
                                {item.payload.count} tx
                                {item.payload.count > 1 ? "s" : ""}
                              </span>
                            )}
                            <span className="text-xs px-1.5 py-0.2 bg-black text-white font-bold">
                              {item.payload.percentage}%
                            </span>
                          </div>
                        </div>
                      </div>
                    )}
                  />
                }
              />
              <Pie
                data={currentData}
                dataKey="totalAmount"
                nameKey="category"
                innerRadius={68}
                outerRadius={95}
                stroke="#000000"
                strokeWidth={2}
                paddingAngle={2}
                onMouseEnter={(_, index) => setActiveIndex(index)}
                onMouseLeave={() => setActiveIndex(null)}
                onClick={(entry) =>
                  onSelectCategory &&
                  onSelectCategory(entry.category || entry.name)
                }
                className="cursor-pointer"
              >
                {currentData.map((entry, index) => {
                  const key = entry.category || entry.name;
                  const isSelected = selectedCategory === key;
                  const isHovered = activeIndex === index;
                  return (
                    <Cell
                      key={`cell-${index}`}
                      fill={entry.color || "#000000"}
                      stroke="#000000"
                      strokeWidth={isSelected || isHovered ? 4 : 2}
                      className="transition-all duration-200"
                    />
                  );
                })}
                <Label
                  content={({ viewBox }) => {
                    if (viewBox && "cx" in viewBox && "cy" in viewBox) {
                      const displayAmount = activeItem
                        ? activeItem.totalAmount
                        : totalAmount;
                      const displayLabel = activeItem
                        ? activeItem.category || activeItem.name
                        : viewMode === "merchant"
                        ? "All Stores"
                        : "Total Outflow";

                      return (
                        <text
                          x={viewBox.cx}
                          y={viewBox.cy}
                          textAnchor="middle"
                          dominantBaseline="middle"
                        >
                          <tspan
                            x={viewBox.cx}
                            y={(viewBox.cy || 0) - 10}
                            className="fill-neutral-500 font-mono text-[10px] uppercase tracking-wider font-bold"
                          >
                            {displayLabel.length > 15
                              ? displayLabel.slice(0, 13) + ".."
                              : displayLabel}
                          </tspan>
                          <tspan
                            x={viewBox.cx}
                            y={(viewBox.cy || 0) + 12}
                            className="fill-black font-doto text-base sm:text-lg font-black"
                          >
                            {currencySymbol}
                            {displayAmount
                              ? Math.round(displayAmount).toLocaleString()
                              : 0}
                          </tspan>
                        </text>
                      );
                    }
                  }}
                />
              </Pie>
            </PieChart>
          </ChartContainer>
        )}
      </div>

      {/* Breakdown List */}
      <div className="mt-3 space-y-2 max-h-[160px] overflow-y-auto pr-1">
        {currentData.map((cat) => {
          const key = cat.category || cat.name;
          const isSelected = selectedCategory === key;
          return (
            <button
              key={key}
              type="button"
              onClick={() => onSelectCategory && onSelectCategory(key)}
              className={`w-full text-left p-2 border transition-colors flex items-center justify-between text-xs cursor-pointer ${
                isSelected
                  ? "border-black bg-neutral-100 shadow-[2px_2px_0px_#000000]"
                  : "border-neutral-200 hover:border-black bg-white"
              }`}
            >
              <div className="flex items-center gap-2">
                <span
                  className="w-3 h-3 shrink-0 border border-black"
                  style={{ backgroundColor: cat.color }}
                />
                <span className="font-pixel text-neutral-800 truncate max-w-[120px] sm:max-w-[160px]">
                  {key}
                </span>
                {cat.count && (
                  <span className="text-[10px] font-mono px-1 py-0.2 bg-neutral-100 text-neutral-600 border border-neutral-300">
                    {cat.count} tx{cat.count > 1 ? "s" : ""}
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2">
                <span className="font-doto font-bold text-black">
                  {currencySymbol}
                  {Number(cat.totalAmount).toLocaleString()}
                </span>
                <span className="font-mono text-[10px] text-neutral-500 w-10 text-right">
                  {cat.percentage}%
                </span>
              </div>
            </button>
          );
        })}
      </div>

      {/* Footer Meta */}
      <div className="mt-3 pt-3 border-t border-neutral-200 text-[11px] font-mono text-neutral-500 flex justify-between">
        <span>
          {viewMode === "merchant"
            ? `MERCHANTS: ${currentData.length} ACTIVE`
            : `CATEGORIES: ${currentData.length} ACTIVE`}
        </span>
        <span>CLICK SLICE TO FILTER LEDGER</span>
      </div>
    </div>
  );
}
