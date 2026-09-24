"use client";

import { useEffect, useRef } from "react";
import Image from "next/image";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

function ScrollDownButton({ onClick }) {
  const arrowRef = useRef(null);
  const floatTweenRef = useRef(null);

  useEffect(() => {
    // Gentle rhythmic idle float bounce (organic micro-motion)
    floatTweenRef.current = gsap.to(arrowRef.current, {
      y: 4,
      duration: 1.2,
      repeat: -1,
      yoyo: true,
      ease: "power1.inOut",
    });

    return () => {
      if (floatTweenRef.current) floatTweenRef.current.kill();
    };
  }, []);

  const handleMouseEnter = () => {
    if (floatTweenRef.current) floatTweenRef.current.pause();

    // Slick drop-and-reenter loop animation on hover
    const tl = gsap.timeline();
    tl.to(arrowRef.current, {
      y: 12,
      opacity: 0,
      duration: 0.16,
      ease: "power2.in",
    })
      .set(arrowRef.current, { y: -12, opacity: 0 })
      .to(arrowRef.current, {
        y: 0,
        opacity: 1,
        duration: 0.28,
        ease: "back.out(2)",
      });
  };

  const handleMouseLeave = () => {
    gsap.to(arrowRef.current, {
      y: 0,
      opacity: 1,
      duration: 0.2,
      onComplete: () => {
        if (floatTweenRef.current) floatTweenRef.current.play();
      },
    });
  };

  return (
    <button
      type="button"
      onClick={onClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      aria-label="Scroll down to workflow"
      className="group w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-[#111111] hover:bg-black flex items-center justify-center cursor-pointer shadow-lg shadow-black/20 hover:shadow-2xl hover:shadow-black/35 ring-1 ring-black/10 hover:ring-white/20 overflow-hidden transition-all duration-300 hover:scale-105 active:scale-95"
    >
      <div
        ref={arrowRef}
        className="flex items-center justify-center pointer-events-none"
      >
        <Image
          src="/assets/arrow_back.svg"
          alt="Scroll down"
          width={20}
          height={12}
          className="w-4 h-2.5 sm:w-5 sm:h-3 object-contain"
        />
      </div>
    </button>
  );
}

// =========================================================================
// 🎛️ CUSTOMIZATION SETTINGS:
// 1. REVEAL_RADIUS: Radius of the mouse reveal circle in pixels
// 2. SVG_DIM_OPACITY: Controls how bright/dim the revealed SVG layout appears
// =========================================================================
const REVEAL_RADIUS = 200;
const SVG_DIM_OPACITY = 0.07;

// =========================================================================
// 📱 PARALLAX SPEED CONFIGURATION:
// Defines upward travel distance (negative y) during scroll.
// Order of speed: Middle (fastest) > Left (medium) > Right (slowest).
// =========================================================================
const PARALLAX_CONFIG = {
  desktop: {
    middle: -380, // Fastest
    left: -220, // Medium
    right: -110, // Slowest
  },
  mobile: {
    middle: -190,
    left: -110,
    right: -55,
  },
};

export default function Hero() {
  const heroRef = useRef(null);
  const maskRef = useRef(null);

  // Parallax refs for each phone mockup
  const leftPhoneRef = useRef(null);
  const middlePhoneRef = useRef(null);
  const rightPhoneRef = useRef(null);

  const scrollToNext = () => {
    const workflowSection = document.getElementById("workflow");
    if (workflowSection) {
      workflowSection.scrollIntoView({ behavior: "smooth" });
    }
  };

  // ScrollTrigger Parallax Effect Setup
  useEffect(() => {
    if (typeof window === "undefined") return;
    gsap.registerPlugin(ScrollTrigger);

    const ctx = gsap.context(() => {
      const mm = gsap.matchMedia();

      // Desktop & Tablets (>= 768px)
      mm.add("(min-width: 768px)", () => {
        // Middle iPhone: moves fastest towards upper direction
        gsap.to(middlePhoneRef.current, {
          y: PARALLAX_CONFIG.desktop.middle,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });

        // Left iPhone: moves a bit slower towards upper direction
        gsap.to(leftPhoneRef.current, {
          y: PARALLAX_CONFIG.desktop.left,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });

        // Right iPhone: moves slowest among them all towards upper direction
        gsap.to(rightPhoneRef.current, {
          y: PARALLAX_CONFIG.desktop.right,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });
      });

      // Mobile Devices (< 768px)
      mm.add("(max-width: 767px)", () => {
        gsap.to(middlePhoneRef.current, {
          y: PARALLAX_CONFIG.mobile.middle,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });

        gsap.to(leftPhoneRef.current, {
          y: PARALLAX_CONFIG.mobile.left,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });

        gsap.to(rightPhoneRef.current, {
          y: PARALLAX_CONFIG.mobile.right,
          ease: "none",
          scrollTrigger: {
            trigger: heroRef.current,
            start: "top top",
            end: "bottom top",
            scrub: 0.2,
          },
        });
      });
    }, heroRef);

    return () => ctx.revert();
  }, []);

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
      className="relative w-full bg-white pt-6 sm:pt-12 md:pt-14 pb-20 sm:pb-40 md:pb-48 lg:pb-60 min-h-[105vh] sm:min-h-[145vh] overflow-x-clip"
    >
      {/* 
        Hover Spotlight Reveal Background:
        Reveals /assets/hero/Bg_hover_layout.svg within a circle around mouse cursor.
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
          src="/assets/hero/Bg_hover_layout.svg"
          alt=""
          fill
          priority
          unoptimized
          className="object-cover object-top select-none pointer-events-none"
        />
      </div>

      {/* 
        Sticky Action Button (Bottom Left):
        Contained strictly within the Hero section with generous bottom padding (bottom-8 sm:bottom-12 lg:bottom-16)
        so it stops comfortably before the next section and never touches the next page.
      */}
      <div className="absolute top-0 bottom-4 sm:bottom-8 lg:bottom-10 left-4 sm:left-4 lg:left-8 w-12 sm:w-14 pointer-events-none z-30">
        <div className="sticky top-[calc(100vh-5.5rem)] sm:top-[calc(100vh-6.5rem)] pointer-events-auto">
          <ScrollDownButton onClick={scrollToNext} />
        </div>
      </div>

      {/* Title */}
      <div className="relative z-10 w-full flex justify-start sm:justify-center px-5 xs:px-6 sm:px-4">
        <h1 className="font-pixel text-[108px] xs:text-[80px] sm:text-6xl md:text-7xl lg:text-[88px] xl:text-[96px] leading-[0.84] sm:leading-tight tracking-[0.03em] sm:tracking-[0.2em] text-black text-left sm:text-center select-none uppercase">
          <span className="block sm:inline">
            PAY<span className="text-[#ff0000] font-extrabold">.</span>
          </span>
          <span className="block sm:inline">
            TRACK<span className="text-[#ff0000] font-extrabold">.</span>
          </span>
          <span className="block sm:inline">GROW</span>
        </h1>
      </div>

      {/* Main Showcase Container (Parallax 3-phone stage) */}
      <div className="relative z-10 max-w-[1720px] mx-auto px-2 xs:px-3 sm:px-8 lg:px-16 mt-6 sm:mt-10 md:mt-14">
        <div className="flex items-start justify-between sm:justify-center gap-1.5 xs:gap-3 sm:gap-6 md:gap-8 lg:gap-12 w-full translate-y-[30%] sm:translate-y-[22%]">
          {/* Left iPhone (Moves at medium speed upward) */}
          <div
            ref={leftPhoneRef}
            className="w-[48%] xs:w-[48%] sm:w-[160px] md:w-[190px] lg:w-[205px] mt-5 sm:mt-12 md:mt-16 flex-shrink-0 will-change-transform"
          >
            <Image
              src="/assets/hero/hero_mock_iphone_left.svg"
              alt="Huly Pay iPhone Left View"
              width={205}
              height={485}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Middle iPhone (Moves FASTEST towards upper direction, positioned higher) */}
          <div
            ref={middlePhoneRef}
            className="w-[50%] xs:w-[50%] sm:w-[182px] md:w-[220px] lg:w-[235px] -mt-1 sm:-mt-8 md:-mt-10 z-10 flex-shrink-0 will-change-transform"
          >
            <Image
              src="/assets/hero/hero_mock_iphone_middle.svg"
              alt="Huly Pay iPhone Dashboard View"
              width={235}
              height={454}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Right iPhone (Hidden on mobile, visible on sm+ desktop/tablets) */}
          <div
            ref={rightPhoneRef}
            className="hidden sm:block sm:w-[160px] md:w-[195px] lg:w-[210px] mt-8 sm:mt-16 md:mt-24 flex-shrink-0 will-change-transform"
          >
            <Image
              src="/assets/hero/hero_mock_iphone_right.svg"
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
