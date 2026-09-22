"use client";

import Image from "next/image";
import { useEffect, useRef, useState, useCallback } from "react";

export default function Workflow() {
  const containerRef = useRef(null);
  const badge1Ref = useRef(null);
  const badge2Ref = useRef(null);
  const badge3Ref = useRef(null);

  const [path1, setPath1] = useState("");
  const [path2, setPath2] = useState("");

  const updatePaths = useCallback(() => {
    if (
      !containerRef.current ||
      !badge1Ref.current ||
      !badge2Ref.current ||
      !badge3Ref.current
    ) {
      return;
    }

    const cRect = containerRef.current.getBoundingClientRect();
    const b1Rect = badge1Ref.current.getBoundingClientRect();
    const b2Rect = badge2Ref.current.getBoundingClientRect();
    const b3Rect = badge3Ref.current.getBoundingClientRect();

    // Connection point on Badge 1 (right edge, around 72% down height)
    const p1 = {
      x: b1Rect.right - cRect.left,
      y: b1Rect.top - cRect.top + b1Rect.height * 0.72,
    };

    // Connection point on Badge 2 top center (top border opening)
    const p2_top = {
      x: b2Rect.left - cRect.left + b2Rect.width * 0.49,
      y: b2Rect.top - cRect.top,
    };

    // Connection point on Badge 2 bottom center (bottom border opening)
    const p2_bottom = {
      x: b2Rect.left - cRect.left + b2Rect.width * 0.49,
      y: b2Rect.bottom - cRect.top,
    };

    // Connection point on Badge 3 top-right shoulder
    const p3 = {
      x: b3Rect.right - cRect.left,
      y: b3Rect.top - cRect.top + b3Rect.height * 0.18,
    };

    // Curve 1 (Badge 1 -> Badge 2 top)
    const dx1 = p2_top.x - p1.x;
    const dy1 = p2_top.y - p1.y;

    let d1 = "";
    if (dx1 > 60) {
      // Desktop S-curve matching Vector 7
      const cp1x = p1.x + dx1 * (101.163 / 886.5);
      const cp1y = p1.y + dy1 * (236.829 / 223.5);
      const midx = p1.x + dx1 * (445.751 / 886.5);
      const midy = p1.y + dy1 * (114.251 / 223.5);
      const cp2x = p1.x + dx1 * (810.501 / 886.5);
      const cp2y = p1.y + dy1 * (-15.4993 / 223.5);
      d1 = `M ${p1.x} ${p1.y} C ${p1.x} ${p1.y} ${cp1x} ${cp1y} ${midx} ${midy} C ${cp2x} ${cp2y} ${p2_top.x} ${p2_top.y} ${p2_top.x} ${p2_top.y}`;
    } else {
      // Mobile / Compact layout curve
      d1 = `M ${p1.x} ${p1.y} C ${p1.x + 30} ${p1.y + dy1 * 0.4}, ${p2_top.x + 30} ${p2_top.y - dy1 * 0.4}, ${p2_top.x} ${p2_top.y}`;
    }

    // Curve 2 (Badge 2 bottom -> Badge 3 shoulder)
    const dx2 = p2_bottom.x - p3.x;
    const dy2 = p3.y - p2_bottom.y;

    let d2 = "";
    if (dx2 > 60) {
      // Desktop S-curve matching Vector 6
      const cp1x_2 = p2_bottom.x - dx2 * (1 - 844 / 919);
      const cp1y_2 = p2_bottom.y + dy2 * (178.356 / 118);
      const midx_2 = p3.x + dx2 * (437 / 919);
      const midy_2 = p2_bottom.y + dy2 * (61.5 / 118);
      const cp2x_2 = p3.x + dx2 * (30 / 919);
      const cp2y_2 = p2_bottom.y + dy2 * (-55.355 / 118);
      d2 = `M ${p2_bottom.x} ${p2_bottom.y} C ${p2_bottom.x} ${p2_bottom.y} ${cp1x_2} ${cp1y_2} ${midx_2} ${midy_2} C ${cp2x_2} ${cp2y_2} ${p3.x} ${p3.y} ${p3.x} ${p3.y}`;
    } else {
      // Mobile / Compact layout curve
      d2 = `M ${p2_bottom.x} ${p2_bottom.y} C ${p2_bottom.x - 30} ${p2_bottom.y + dy2 * 0.4}, ${p3.x - 30} ${p3.y - dy2 * 0.4}, ${p3.x} ${p3.y}`;
    }

    setPath1(d1);
    setPath2(d2);
  }, []);

  useEffect(() => {
    updatePaths();

    const handleResize = () => updatePaths();
    window.addEventListener("resize", handleResize);

    let observer;
    if (typeof ResizeObserver !== "undefined" && containerRef.current) {
      observer = new ResizeObserver(() => updatePaths());
      observer.observe(containerRef.current);
    }

    const timer1 = setTimeout(updatePaths, 150);
    const timer2 = setTimeout(updatePaths, 500);

    return () => {
      window.removeEventListener("resize", handleResize);
      if (observer) observer.disconnect();
      clearTimeout(timer1);
      clearTimeout(timer2);
    };
  }, [updatePaths]);

  return (
    <section
      id="workflow"
      className="relative w-full bg-black text-white py-24 sm:py-32 lg:py-40 overflow-hidden"
    >
      <div className="relative max-w-[1720px] mx-auto px-6 sm:px-12 lg:px-24">
        {/* Header Section */}
        <div className="mb-20 sm:mb-28 lg:mb-36">
          <div className="inline-flex items-center gap-2 sm:gap-3.5">
            {/* Vertical YOUR */}
            <div className="flex items-center justify-center self-stretch">
              <span
                className="font-pixel text-3xl sm:text-5xl lg:text-[64px] font-semibold text-[#FF0000] tracking-[0.12em] sm:tracking-[0.16em] uppercase select-none leading-none inline-block"
                style={{
                  writingMode: "vertical-rl",
                  transform: "rotate(180deg)",
                }}
              >
                YOUR
              </span>
            </div>

            {/* Money Control (tightly stacked so both words fit within YOUR) */}
            <div className="flex flex-col justify-center leading-none">
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-[96px] text-white tracking-tight leading-[0.85] select-none">
                Money
              </h2>
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-[96px] text-white tracking-tight leading-[0.85] select-none mt-1 sm:mt-2">
                Control
              </h2>
            </div>
          </div>

          {/* Subtitle */}
          <p className="font-sans text-sm sm:text-base text-[#D4D4D8] tracking-normal mt-6 max-w-2xl leading-relaxed">
            HulyPay An open-source payment and expense tracking platform built
            to help anyone pay, track, and understand their money.
          </p>
        </div>

        {/* Workflow Interactive Roadmap */}
        <div ref={containerRef} className="relative w-full">
          {/* Responsive Dynamically Linked Curves Overlay */}
          <svg className="absolute inset-0 w-full h-full pointer-events-none z-0 overflow-visible">
            {path1 && (
              <path
                d={path1}
                stroke="white"
                strokeWidth="4"
                strokeLinecap="round"
                fill="none"
              />
            )}
            {path2 && (
              <path
                d={path2}
                stroke="white"
                strokeWidth="4"
                strokeLinecap="round"
                fill="none"
              />
            )}
          </svg>

          {/* STEP 1: QR Badge on Left, 2X Text on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12 mb-28 sm:mb-36 lg:mb-48">
            {/* Left Badge: QR Scanner */}
            <div className="lg:col-span-5 flex justify-start lg:pl-6">
              <div
                ref={badge1Ref}
                className="w-[108px] sm:w-[132px] lg:w-[150px] relative"
              >
                <Image
                  src="/assets/Frame 145.svg"
                  alt="Scan QR Badge"
                  width={323}
                  height={357}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>

            {/* Right Text: 2X Times Scan QR to pay */}
            <div className="lg:col-span-7 flex items-center justify-start lg:pl-8">
              <div className="flex items-center gap-4 sm:gap-6">
                {/* 2X Graphic */}
                <div className="flex flex-col items-center justify-center leading-none select-none">
                  <span className="font-doto text-6xl sm:text-7xl lg:text-8xl font-black text-white tracking-tighter">
                    2
                  </span>
                  <span className="font-pixel text-2xl sm:text-3xl lg:text-4xl font-bold text-[#62D800] -mt-1 sm:-mt-2">
                    X
                  </span>
                </div>

                {/* Description Lines */}
                <div className="flex flex-col font-pixel text-xl sm:text-2xl lg:text-3xl font-semibold text-[#D4D4D8] tracking-wide leading-snug select-none">
                  <span>Times Scan QR to pay</span>
                  <span>Faster Tracking</span>
                </div>
              </div>
            </div>
          </div>

          {/* STEP 2: Secure Text on Left, Chevron Badge on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12 mb-28 sm:mb-36 lg:mb-48">
            {/* Left Text: Keep your transactions (Secure) & Expenses Organized. */}
            <div className="order-2 lg:order-1 lg:col-span-7 flex justify-start lg:justify-end lg:pr-12">
              <p className="font-pixel text-2xl sm:text-3xl lg:text-4xl font-semibold text-[#D4D4D8] tracking-wide leading-snug max-w-xl select-none">
                Keep your transactions{" "}
                <span className="text-[#D8FF00] font-bold">(Secure)</span> &amp;
                Expenses Organized.
              </p>
            </div>

            {/* Right Badge: Down Chevrons */}
            <div className="order-1 lg:order-2 lg:col-span-5 flex justify-start lg:justify-end lg:pr-6">
              <div
                ref={badge2Ref}
                className="w-[108px] sm:w-[132px] lg:w-[150px] relative"
              >
                <Image
                  src="/assets/Frame 143.svg"
                  alt="Secure Transactions Badge"
                  width={248}
                  height={299}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>
          </div>

          {/* STEP 3: Shield Badge on Left, Visual Data Text on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12">
            {/* Left Badge: Star Shield */}
            <div className="lg:col-span-5 flex justify-start lg:pl-6">
              <div
                ref={badge3Ref}
                className="w-[108px] sm:w-[132px] lg:w-[150px] relative"
              >
                <Image
                  src="/assets/Frame 144.svg"
                  alt="Visual Data Sparkle Shield"
                  width={309}
                  height={342}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>

            {/* Right Text: Turn your spending into useful Visual Data. */}
            <div className="lg:col-span-7 flex justify-start lg:pl-8">
              <p className="font-pixel text-2xl sm:text-3xl lg:text-4xl font-semibold text-[#D4D4D8] tracking-wide leading-snug select-none">
                Turn your spending into useful{" "}
                <span className="text-[#FF00F5] font-bold">Visual</span> Data.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
