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
      <div ref={arrowRef} className="flex items-center justify-center pointer-events-none">
        <svg
          width="20"
          height="12"
          viewBox="0 0 20 12"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-4 h-2.5 sm:w-5 sm:h-3 overflow-visible"
          aria-hidden="true"
        >
          <path
            d="M0 1.78125L1.75 0L10.2 8.28137L10.2 11.7812Z"
            fill="white"
          />
          <path
            d="M20 1.78125L18.25 0L9.8 8.28137L9.8 11.7812Z"
            fill="white"
          />
        </svg>
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
    left: -220,   // Medium
    right: -110,  // Slowest
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
      className="relative w-full bg-white pt-8 sm:pt-12 md:pt-14 pb-16 sm:pb-24 lg:pb-28 min-h-[110vh] sm:min-h-[118vh] overflow-x-clip"
    >
      {/* 
        Hover Spotlight Reveal Background:
        Reveals /assets/Bg_hover_layout.svg within a circle around mouse cursor.
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

      {/* 
        Sticky Action Button (Bottom Left):
        Contained strictly within the Hero section with generous bottom padding (bottom-8 sm:bottom-12 lg:bottom-16)
        so it stops comfortably before the next section and never touches the next page.
      */}
      <div className="absolute top-0 bottom-4 sm:bottom-8 lg:bottom-10 left-4 sm:left-4 lg:left-8 w-14 pointer-events-none z-30">
        <div className="sticky top-[calc(100vh-5.5rem)] sm:top-[calc(100vh-6.5rem)] pointer-events-auto">
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

      {/* Main Showcase Container (Parallax 3-phone stage) */}
      <div className="relative z-10 max-w-[1720px] mx-auto px-4 sm:px-8 lg:px-16 mt-8 sm:mt-10 md:mt-14">
        {/* 3 iPhone Mockups Staggered Display (Pulled further down) */}
        <div className="flex items-start justify-center gap-3 sm:gap-6 md:gap-8 lg:gap-12 w-full translate-y-[18%] sm:translate-y-[22%]">
          {/* Left iPhone (Moves at medium speed upward) */}
          <div
            ref={leftPhoneRef}
            className="w-[126px] sm:w-[160px] md:w-[190px] lg:w-[205px] mt-8 sm:mt-12 md:mt-16 flex-shrink-0 will-change-transform"
          >
            <Image
              src="/assets/hero_mock_iphone_left.svg"
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
            className="w-[140px] sm:w-[182px] md:w-[220px] lg:w-[235px] -mt-5 sm:-mt-8 md:-mt-10 z-10 flex-shrink-0 will-change-transform"
          >
            <Image
              src="/assets/hero_mock_iphone_middle.svg"
              alt="Huly Pay iPhone Dashboard View"
              width={235}
              height={454}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Right iPhone (Moves SLOWEST among them all towards upper direction) */}
          <div
            ref={rightPhoneRef}
            className="w-[126px] sm:w-[160px] md:w-[195px] lg:w-[210px] mt-12 sm:mt-16 md:mt-24 flex-shrink-0 will-change-transform"
          >
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
