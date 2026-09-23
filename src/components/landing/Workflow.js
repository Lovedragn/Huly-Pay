"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import Image from "next/image";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { Frame145Badge, Frame143Badge, Frame144Badge } from "./WorkflowBadges";

// =========================================================================
// 🎛️ CUSTOMIZATION SETTINGS:
// 1. REVEAL_RADIUS: Radius of the mouse reveal circle in pixels (default: 200)
// 2. GRID_OPACITY: Controls brightness/opacity of the revealed pixel grid SVG
// =========================================================================
const REVEAL_RADIUS = 200;
const GRID_OPACITY = 0.2;

export default function Workflow() {
  const sectionRef = useRef(null);
  const maskRef = useRef(null);
  const containerRef = useRef(null);
  const badge1Ref = useRef(null);
  const badge2Ref = useRef(null);
  const badge3Ref = useRef(null);
  const badge1SvgRef = useRef(null);
  const badge2SvgRef = useRef(null);
  const badge3SvgRef = useRef(null);
  const path1Ref = useRef(null);
  const path2Ref = useRef(null);

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
    if (typeof window !== "undefined") {
      ScrollTrigger.refresh();
    }
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

  // ScrollTrigger animation: Path 1 draws left-to-right, then Path 2 draws right-to-left
  useEffect(() => {
    if (typeof window === "undefined") return;
    gsap.registerPlugin(ScrollTrigger);

    if (
      !path1 ||
      !path2 ||
      !path1Ref.current ||
      !path2Ref.current ||
      !containerRef.current
    ) {
      return;
    }

    const ctx = gsap.context(() => {
      const len1 = path1Ref.current.getTotalLength() || 1000;
      const len2 = path2Ref.current.getTotalLength() || 1000;

      // Initialize both paths: hidden with full dashoffset and opacity 0
      gsap.set(path1Ref.current, {
        strokeDasharray: len1,
        strokeDashoffset: len1,
        opacity: 0,
      });

      gsap.set(path2Ref.current, {
        strokeDasharray: len2,
        strokeDashoffset: len2,
        opacity: 0,
      });

      // Target frame and inner elements for each badge
      const b1Frame = badge1SvgRef.current?.querySelector(".badge-frame");
      const b1Inner = badge1SvgRef.current?.querySelector(".badge-inner");
      const b1Core = badge1SvgRef.current?.querySelector(".badge-core");

      const b2Frame = badge2SvgRef.current?.querySelector(".badge-frame");
      const b2Inner = badge2SvgRef.current?.querySelector(".badge-inner");

      const b3Frame = badge3SvgRef.current?.querySelector(".badge-frame");
      const b3Inner = badge3SvgRef.current?.querySelector(".badge-inner");

      // Initialize all frames in their original color (gray frame + white inner)
      if (b1Frame) gsap.set(b1Frame, { fill: "#D9D9D9" });
      if (b1Inner) gsap.set(b1Inner, { fill: "#FFFFFF" });
      if (b1Core) gsap.set(b1Core, { fill: "#D6D6D6" });
      if (badge1SvgRef.current) {
        gsap.set(badge1SvgRef.current, {
          filter: "drop-shadow(0 0 0px rgba(98, 216, 0, 0))",
        });
      }

      if (b2Frame) gsap.set(b2Frame, { fill: "#D9D9D9" });
      if (b2Inner) gsap.set(b2Inner, { fill: "#FFFFFF" });
      if (badge2SvgRef.current) {
        gsap.set(badge2SvgRef.current, {
          filter: "drop-shadow(0 0 0px rgba(216, 255, 0, 0))",
        });
      }

      if (b3Frame) gsap.set(b3Frame, { fill: "#D9D9D9" });
      if (b3Inner) gsap.set(b3Inner, { fill: "#FFFFFF" });
      if (badge3SvgRef.current) {
        gsap.set(badge3SvgRef.current, {
          filter: "drop-shadow(0 0 0px rgba(255, 0, 245, 0))",
        });
      }

      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: containerRef.current,
          start: "top 65%",
          end: "bottom 75%",
          scrub: 0.8,
          invalidateOnRefresh: true,
        },
      });

      // 1. Badge 1 (Frame 145) turns #62D800 (frame) and #459700 (30% darker inner) as path initiates
      if (b1Frame) {
        tl.to(
          b1Frame,
          {
            fill: "#62D800",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.01,
        );
      }
      if (b1Inner) {
        tl.to(
          b1Inner,
          {
            fill: "#459700",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.01,
        );
      }
      if (b1Core) {
        tl.to(
          b1Core,
          {
            fill: "#62D800",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.01,
        );
      }
      if (badge1SvgRef.current) {
        tl.to(
          badge1SvgRef.current,
          {
            filter: "drop-shadow(0 0 16px rgba(98, 216, 0, 0.45))",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.01,
        );
      }

      // 1. First SVG path draws from left to right (from Badge 1 to Badge 2)
      tl.to(
        path1Ref.current,
        {
          opacity: 1,
          duration: 0.04,
          ease: "none",
        },
        0,
      ).to(
        path1Ref.current,
        {
          strokeDashoffset: 0,
          duration: 0.96,
          ease: "none",
        },
        0,
      );

      // 2. Badge 2 (Frame 143) turns #D8FF00 (frame) and #97B300 (30% darker inner) when path 1 arrives and touches it
      if (b2Frame) {
        tl.to(
          b2Frame,
          {
            fill: "#D8FF00",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.92,
        );
      }
      if (b2Inner) {
        tl.to(
          b2Inner,
          {
            fill: "#97B300",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.92,
        );
      }
      if (badge2SvgRef.current) {
        tl.to(
          badge2SvgRef.current,
          {
            filter: "drop-shadow(0 0 16px rgba(216, 255, 0, 0.45))",
            duration: 0.08,
            ease: "power1.inOut",
          },
          0.92,
        );
      }

      // 2. Then Second SVG path draws from right to left (from Badge 2 to Badge 3)
      tl.to(
        path2Ref.current,
        {
          opacity: 1,
          duration: 0.04,
          ease: "none",
        },
        1,
      ).to(
        path2Ref.current,
        {
          strokeDashoffset: 0,
          duration: 0.96,
          ease: "none",
        },
        1,
      );

      // 3. Badge 3 (Frame 144) turns #FF00F5 (frame) and #B300AC (30% darker inner) when path 2 arrives and touches it
      if (b3Frame) {
        tl.to(
          b3Frame,
          {
            fill: "#FF00F5",
            duration: 0.08,
            ease: "power1.inOut",
          },
          1.92,
        );
      }
      if (b3Inner) {
        tl.to(
          b3Inner,
          {
            fill: "#B300AC",
            duration: 0.08,
            ease: "power1.inOut",
          },
          1.92,
        );
      }
      if (badge3SvgRef.current) {
        tl.to(
          badge3SvgRef.current,
          {
            filter: "drop-shadow(0 0 16px rgba(255, 0, 245, 0.45))",
            duration: 0.08,
            ease: "power1.inOut",
          },
          1.92,
        );
      }
    }, containerRef);

    return () => ctx.revert();
  }, [path1, path2]);

  const updateMask = (x, y) => {
    if (!maskRef.current) return;
    const mask = `radial-gradient(circle ${REVEAL_RADIUS}px at ${x}px ${y}px, black 0%, black 40%, transparent 100%)`;
    maskRef.current.style.webkitMaskImage = mask;
    maskRef.current.style.maskImage = mask;
  };

  const handleMouseEnter = (e) => {
    if (!sectionRef.current || !maskRef.current) return;
    const rect = sectionRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    updateMask(x, y);
    maskRef.current.style.opacity = `${GRID_OPACITY}`;
  };

  const handleMouseMove = (e) => {
    if (!sectionRef.current || !maskRef.current) return;
    const rect = sectionRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    updateMask(x, y);
  };

  const handleMouseLeave = () => {
    if (!maskRef.current) return;
    maskRef.current.style.opacity = "0";
  };

  return (
    <section
      id="workflow"
      ref={sectionRef}
      onMouseEnter={handleMouseEnter}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="relative w-full bg-black text-white py-24 sm:py-32 lg:py-40 overflow-hidden"
    >
      {/* 
        Hover Spotlight Reveal Background:
        Reveals /assets/workflow/workflow_grid_hover.svg within a 200px circle around mouse cursor.
        Opacity is controlled by GRID_OPACITY.
      */}
      <div
        ref={maskRef}
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 z-0 overflow-hidden transition-opacity duration-300 ease-out"
        style={{
          opacity: 0,
          WebkitMaskRepeat: "no-repeat",
          maskRepeat: "no-repeat",
        }}
      >
        <Image
          src="/assets/workflow/workflow_grid_hover.svg"
          alt=""
          fill
          priority
          unoptimized
          className="object-cover object-top select-none pointer-events-none"
        />
      </div>

      <div className="relative z-10 max-w-[1720px] mx-auto px-6 sm:px-12 lg:px-24">
        {/* Header Section */}
        <div className="mb-20 sm:mb-28 lg:mb-36">
          <div className="inline-flex items-center gap-2 sm:gap-3.5">
            {/* Vertical YOUR */}
            <div className="flex items-center justify-center self-stretch">
              <span
                className="font-pixel text-3xl sm:text-5xl lg:text-5xl font-semibold text-[#FF0000] tracking-[0.12em] sm:tracking-[0.16em] uppercase select-none leading-none inline-block"
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
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-7xl text-white tracking-tight leading-[0.85] select-none">
                Money
              </h2>
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-7xl text-white tracking-tight leading-[0.85] select-none mt-1 sm:mt-2">
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
                ref={path1Ref}
                d={path1}
                stroke="white"
                strokeWidth="4"
                strokeLinecap="round"
                fill="none"
              />
            )}
            {path2 && (
              <path
                ref={path2Ref}
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
                <Frame145Badge
                  svgRef={badge1SvgRef}
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
                <Frame143Badge
                  svgRef={badge2SvgRef}
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
                <Frame144Badge
                  svgRef={badge3SvgRef}
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
