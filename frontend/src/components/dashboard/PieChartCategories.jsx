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
  selectedCategory,
  onSelectCategory,
  currency = "INR",
}) {
  const [activeIndex, setActiveIndex] = React.useState(null);

  const currencySymbol = currency === "INR" ? "₹" : "$";
  const rate = currency === "USD" ? 83.5 : 1;

  const formattedData = React.useMemo(() => {
    if (!data || data.length === 0) return [];
    if (currency === "USD") {
      return data.map((item) => ({
        ...item,
        totalAmount: Number(((item.totalAmount || 0) / rate).toFixed(2)),
      }));
    }
    return data;
  }, [data, currency, rate]);

  const totalAmount = React.useMemo(() => {
    return formattedData.reduce((acc, curr) => acc + (curr.totalAmount || 0), 0);
  }, [formattedData]);

  const activeItem =
    activeIndex !== null && formattedData[activeIndex]
      ? formattedData[activeIndex]
      : null;

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header */}
      <div className="pb-4 border-b-2 border-neutral-200">
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 bg-[#FF00F5] inline-block" />
          <span className="font-mono text-xs font-bold uppercase tracking-wider text-[#FF00F5]">
            DISTRIBUTION • DONUT / PIE CHART
          </span>
        </div>
        <div className="flex items-center justify-between mt-1">
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            Category Breakdown
          </h2>
          {selectedCategory && (
            <button
              onClick={() => onSelectCategory && onSelectCategory(null)}
              className="text-xs font-mono px-2 py-0.5 border border-black bg-neutral-100 hover:bg-black hover:text-white transition-colors cursor-pointer"
            >
              Reset Filter [X]
            </button>
          )}
        </div>
        <p className="text-xs sm:text-sm text-neutral-600 font-sans mt-0.5">
          Live expense clustering synchronized from{" "}
          <code className="text-xs bg-neutral-100 px-1 py-0.5 font-mono">
            Supabase DB & Spring Boot
          </code>
        </p>
      </div>

      {/* Donut Chart with center label */}
      <div className="w-full flex items-center justify-center pt-2">
        <ChartContainer
          config={chartConfig}
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
                      <span className="font-pixel text-xs text-neutral-600">
                        {item.payload.category}
                      </span>
                      <div className="flex items-center justify-between gap-4 font-mono">
                        <span className="font-doto font-bold text-black text-sm">
                          {currencySymbol}
                          {Number(val).toLocaleString()}
                        </span>
                        <span className="text-xs px-1.5 py-0.2 bg-black text-white">
                          {item.payload.percentage}%
                        </span>
                      </div>
                    </div>
                  )}
                />
              }
            />
            <Pie
              data={formattedData}
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
                onSelectCategory && onSelectCategory(entry.category)
              }
              className="cursor-pointer"
            >
              {formattedData.map((entry, index) => {
                const isSelected = selectedCategory === entry.category;
                const isHovered = activeIndex === index;
                return (
                  <Cell
                    key={`cell-${index}`}
                    fill={entry.color || "#000000"}
                    stroke={isSelected || isHovered ? "#000000" : "#000000"}
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
                      ? activeItem.category
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
                          className="fill-neutral-500 font-mono text-[10px] uppercase tracking-wider"
                        >
                          {displayLabel.length > 16
                            ? displayLabel.slice(0, 14) + ".."
                            : displayLabel}
                        </tspan>
                        <tspan
                          x={viewBox.cx}
                          y={(viewBox.cy || 0) + 12}
                          className="fill-black font-doto text-base sm:text-lg font-black"
                        >
                          {currencySymbol}
                          {displayAmount ? Math.round(displayAmount).toLocaleString() : 0}
                        </tspan>
                      </text>
                    );
                  }
                }}
              />
            </Pie>
          </PieChart>
        </ChartContainer>
      </div>

      {/* Category List */}
      <div className="mt-3 space-y-2 max-h-[160px] overflow-y-auto pr-1">
        {formattedData.map((cat) => {
          const isSelected = selectedCategory === cat.category;
          return (
            <button
              key={cat.category}
              onClick={() => onSelectCategory && onSelectCategory(cat.category)}
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
                <span className="font-pixel text-neutral-800 truncate max-w-[130px] sm:max-w-[160px]">
                  {cat.category}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="font-doto font-bold text-black">
                  {currencySymbol}
                  {Number(cat.totalAmount).toLocaleString()}
                </span>
                <span className="font-mono text-[10px] text-neutral-500 w-9 text-right">
                  {cat.percentage}%
                </span>
              </div>
            </button>
          );
        })}
      </div>

      <div className="mt-3 pt-3 border-t border-neutral-200 text-[11px] font-mono text-neutral-500 flex justify-between">
        <span>CATEGORIES: {formattedData.length} ACTIVE</span>
        <span>CLICK SLICE TO FILTER LEDGER</span>
      </div>
    </div>
  );
}
