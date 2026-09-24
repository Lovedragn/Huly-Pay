"use client";

import * as React from "react";
import {
  PolarAngleAxis,
  PolarGrid,
  PolarRadiusAxis,
  Radar,
  RadarChart,
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
  score: {
    label: "Current System Score",
    color: "#62D800", // Terminal Lime
  },
  benchmark: {
    label: "Industry Benchmark",
    color: "#000000", // Monolith Black
  },
};

export default function RadarChartPerformance({ data = [] }) {
  const [showBenchmark, setShowBenchmark] = React.useState(true);

  const averageScore = React.useMemo(() => {
    if (!data.length) return 0;
    return Math.round(
      data.reduce((acc, curr) => acc + (curr.score || 0), 0) / data.length
    );
  }, [data]);

  return (
    <div className="border-[3px] border-black bg-white shadow-[6px_6px_0px_#000000] p-4 sm:p-6 flex flex-col justify-between">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b-2 border-neutral-200">
        <div>
          <h2 className="text-xl sm:text-2xl font-bold font-pixel text-black">
            System & Financial Radar
          </h2>
        </div>

        {/* Benchmark toggle */}
        <button
          onClick={() => setShowBenchmark(!showBenchmark)}
          className={`px-3 py-1 text-xs font-mono border-2 border-black transition-colors ${
            showBenchmark
              ? "bg-[#D8FF00] text-black font-bold"
              : "bg-neutral-100 text-neutral-700 hover:bg-neutral-200"
          }`}
        >
          {showBenchmark ? "Benchmark: ON" : "Benchmark: OFF"}
        </button>
      </div>

      {/* Quick Score Badge */}
      <div className="flex items-center justify-between py-2 px-3 bg-neutral-50 border border-neutral-200 my-2">
        <span className="text-xs font-mono text-neutral-500 uppercase">
          Composite Network Health
        </span>
        <div className="flex items-center gap-2">
          <span className="font-doto text-xl font-black text-[#62D800]">
            {averageScore} / 100
          </span>
          <span className="text-[10px] font-mono px-1.5 py-0.5 bg-black text-white">
            TIER 1
          </span>
        </div>
      </div>

      {/* Radar Chart */}
      <div className="w-full flex items-center justify-center pt-2 min-h-[290px]">
        <ChartContainer
          config={chartConfig}
          className="mx-auto aspect-square max-h-[300px] w-full"
        >
          <RadarChart data={data}>
            <ChartTooltip
              cursor={false}
              content={
                <ChartTooltipContent
                  indicator="dot"
                  formatter={(val, name, item) => (
                    <div className="flex flex-col gap-1">
                      <div className="flex items-center justify-between gap-4 font-mono">
                        <span className="font-pixel text-xs text-neutral-600">
                          {chartConfig[name]?.label || name}:
                        </span>
                        <span className="font-doto font-bold text-black text-sm">
                          {val} / 100
                        </span>
                      </div>
                      {item.payload.description && (
                        <span className="text-[10px] text-neutral-500 font-sans">
                          {item.payload.description}
                        </span>
                      )}
                    </div>
                  )}
                />
              }
            />
            <PolarGrid stroke="#000000" strokeOpacity={0.15} />
            <PolarAngleAxis
              dataKey="metric"
              tick={{ fontSize: 11, fontFamily: "var(--font-pixelify)" }}
            />
            <PolarRadiusAxis
              angle={30}
              domain={[0, 100]}
              stroke="#000000"
              strokeOpacity={0.2}
              tick={{ fontSize: 9, fontFamily: "var(--font-geist-mono)" }}
            />

            {showBenchmark && (
              <Radar
                name="benchmark"
                dataKey="benchmark"
                stroke="#000000"
                strokeWidth={1.5}
                strokeDasharray="4 4"
                fill="#000000"
                fillOpacity={0.08}
              />
            )}

            <Radar
              name="score"
              dataKey="score"
              stroke="#62D800"
              strokeWidth={2.5}
              fill="#62D800"
              fillOpacity={0.4}
              dot={{ r: 3, fill: "#62D800", stroke: "#000000", strokeWidth: 1 }}
            />
            <ChartLegend content={<ChartLegendContent />} />
          </RadarChart>
        </ChartContainer>
      </div>

      <div className="mt-3 pt-3 border-t border-neutral-200 flex items-center justify-between text-[11px] font-mono text-neutral-500">
        <span>SECURITY: SUPABASE ES256/RS256</span>
        <span>SMS PARSER: 94% MATCH</span>
      </div>
    </div>
  );
}
