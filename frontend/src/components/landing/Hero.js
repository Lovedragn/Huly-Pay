"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import gsap from "gsap";

function ScrollDownButton({ onClick }) {
  const leftStickRef = useRef(null);
  const rightStickRef = useRef(null);
  const tlRef = useRef(null);

  useEffect(() => {
    if (!leftStickRef.current || !rightStickRef.current) return;

    // Initial setup: sticks offset left and right
    gsap.set(leftStickRef.current, { x: -25, opacity: 0 });
    gsap.set(rightStickRef.current, { x: 25, opacity: 0 });

    const tl = gsap.timeline({
      repeat: -1,
      repeatDelay: 3.0, // 3 seconds gap between cycles
    });

    // 1. Sticks come from left and right side and merge to make original down arrow
    tl.to([leftStickRef.current, rightStickRef.current], {
      x: 0,
      opacity: 1,
      duration: 0.45,
      ease: "power2.out",
    });

    // 2. Hold merged state as original down arrow for 1.0 second
    tl.to({}, { duration: 1.0 });

    // 3. Smoothly fade out merged arrow
    tl.to([leftStickRef.current, rightStickRef.current], {
      opacity: 0,
      duration: 0.25,
      ease: "power2.in",
    });

    // 4. Reset stick positions off-center for next cycle
    tl.set(leftStickRef.current, { x: -25 });
    tl.set(rightStickRef.current, { x: 25 });

    tlRef.current = tl;

    return () => {
      tl.kill();
    };
  }, []);

  const handleMouseEnter = () => {
    if (tlRef.current) tlRef.current.pause();
    gsap.killTweensOf([leftStickRef.current, rightStickRef.current]);
    gsap.to([leftStickRef.current, rightStickRef.current], {
      x: 0,
      opacity: 1,
      duration: 0.2,
      ease: "power2.out",
    });
  };

  const handleMouseLeave = () => {
    if (tlRef.current) tlRef.current.play();
  };

  return (
    <button
      type="button"
      onClick={onClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      aria-label="Scroll down to workflow"
      className="group w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-[#111111] flex items-center justify-center cursor-pointer shadow-xl shadow-black/25 overflow-hidden transition-transform duration-200 hover:scale-105 active:scale-95"
    >
      <svg
        width="20"
        height="12"
        viewBox="0 0 20 12"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-4 h-2.5 sm:w-5 sm:h-3 overflow-visible pointer-events-none"
        aria-hidden="true"
      >
        {/* Left stick: comes from left side */}
        <path
          ref={leftStickRef}
          d="M0 1.78125L1.75 0L10.2 8.28137L10.2 11.7812Z"
          fill="white"
        />
        {/* Right stick: comes from right side */}
        <path
          ref={rightStickRef}
          d="M20 1.78125L18.25 0L9.8 8.28137L9.8 11.7812Z"
          fill="white"
        />
      </svg>
    </button>
  );
}

// =========================================================================
// 🎛️ CUSTOMIZATION SETTINGS:
// 1. REVEAL_RADIUS: Radius of the mouse reveal circle in pixels (default 50px)
// 2. SVG_DIM_OPACITY: Controls how bright/dim the revealed SVG layout appears
//    Change this between 0.0 (fully invisible) and 1.0 (full solid dark)
//    - 0.20: Very subtle & soft watermark
//    - 0.35: Balanced & sleek (Recommended)
//    - 0.60: Noticeable & punchy
//    - 1.00: Full dark/black
// =========================================================================
const REVEAL_RADIUS = 200;
const SVG_DIM_OPACITY = 0.07;

export default function Hero() {
  const heroRef = useRef(null);
  const maskRef = useRef(null);

  const scrollToNext = () => {
    const workflowSection = document.getElementById("workflow");
    if (workflowSection) {
      workflowSection.scrollIntoView({ behavior: "smooth" });
    }
  };

  const updateMask = (x, y) => {
    if (!maskRef.current) return;
    const mask = `radial-gradient(circle ${REVEAL_RADIUS}px at ${x}px ${y}px, black 0%, black 40%, transparent 100%)`;
    maskRef.current.style.webkitMaskImage = mask;
    maskRef.current.style.maskImage = mask;
  };

  const handleMouseEnter = (e) => {
    if (!heroRef.current || !maskRef.current) return;
    const rect = heroRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    updateMask(x, y);
    maskRef.current.style.opacity = `${SVG_DIM_OPACITY}`;
  };

  const handleMouseMove = (e) => {
    if (!heroRef.current || !maskRef.current) return;
    const rect = heroRef.current.getBoundingClientRect();
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
      id="hero"
      ref={heroRef}
      onMouseEnter={handleMouseEnter}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="relative w-full bg-white pt-10 sm:pt-14 md:pt-16"
    >
      {/* 
        Hover Spotlight Reveal Background:
        Reveals /assets/Bg_hover_layout.svg within a 50px radius around mouse cursor.
        Opacity is controlled by SVG_DIM_OPACITY.
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
          src="/assets/Bg_hover_layout.svg"
          alt=""
          fill
          priority
          unoptimized
          className="object-cover object-top select-none pointer-events-none"
        />
      </div>

      {/* Sticky Action Button (Bottom Left, visible on load, sticks until Hero scrolls out) */}
      <div className="absolute inset-y-0 left-4 sm:left-8 lg:left-14 w-14 pointer-events-none z-30">
        <div className="sticky top-[calc(100vh-80px)] sm:top-[calc(100vh-90px)] md:top-[calc(100vh-100px)] pointer-events-auto">
          <ScrollDownButton onClick={scrollToNext} />
        </div>
      </div>

      {/* Title */}
      <div className="relative z-10 w-full flex justify-center px-4">
        <h1 className="font-pixel text-4xl sm:text-6xl md:text-7xl lg:text-[88px] xl:text-[96px] tracking-[0.14em] sm:tracking-[0.2em] text-black text-center select-none uppercase">
          PAY<span className="text-[#E53E3E]">.</span>TRACK
          <span className="text-[#E53E3E]">.</span>GROW
        </h1>
      </div>

      {/* Main Showcase Container (Phones reduced by 30%) */}
      <div className="relative z-10 max-w-[1720px] mx-auto px-4 sm:px-8 lg:px-16 mt-6 sm:mt-10 md:mt-12 overflow-hidden">
        {/* 3 iPhone Mockups Staggered Display */}
        <div className="flex items-start justify-center gap-3 sm:gap-6 md:gap-8 lg:gap-12 w-full translate-y-[30%]">
          {/* Left iPhone (30% reduced size) */}
          <div className="w-[126px] sm:w-[160px] md:w-[190px] lg:w-[205px] mt-8 sm:mt-12 md:mt-16 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_left.svg"
              alt="Huly Pay iPhone Left View"
              width={205}
              height={485}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Middle iPhone (Highest, Center Stage, 30% reduced size) */}
          <div className="w-[140px] sm:w-[182px] md:w-[220px] lg:w-[235px] mt-0 z-10 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_middle.svg"
              alt="Huly Pay iPhone Dashboard View"
              width={235}
              height={454}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Right iPhone (30% reduced size) */}
          <div className="w-[126px] sm:w-[160px] md:w-[195px] lg:w-[210px] mt-12 sm:mt-16 md:mt-24 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_right.svg"
              alt="Huly Pay iPhone Insights View"
              width={210}
              height={485}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
