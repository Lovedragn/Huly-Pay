"use client";

import React, { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import AnimatedSignature from "./AnimatedSignature";

const SEGMENT_COUNT = 20;

/**
 * InitialLoader Component
 *
 * Implements MadeInUX / Codegrid 20-segmentation vertical rectangle preloader:
 * 1. Loading animation: 20 vertical pure white rectangles (no borders) sweep and fill from left to right.
 * 2. Signature animation: In the center of the white canvas, the signature draws its cursive strokes cleanly.
 * 3. Exit animation: Signature fades out, and the 20 vertical rectangles exit from left to right,
 *    revealing the page underneath.
 */
export default function InitialLoader({ onComplete }) {
  const [isDone, setIsDone] = useState(false);
  const containerRef = useRef(null);
  const signatureRef = useRef(null);
  const blocksRef = useRef([]);

  useEffect(() => {
    // Lock scrolling while the initial loading screen is active
    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    const blocks = blocksRef.current.filter(Boolean);

    const ctx = gsap.context(() => {
      // Initial state: 20 vertical rectangles clipped at right: 100% (hidden on left edge)
      gsap.set(blocks, {
        clipPath: "inset(0% 100% 0% 0%)",
        webkitClipPath: "inset(0% 100% 0% 0%)",
      });
      gsap.set(signatureRef.current, { opacity: 0 });

      const tl = gsap.timeline({
        defaults: { ease: "power3.inOut" },
        onComplete: () => {
          document.body.style.overflow = originalOverflow;
          setIsDone(true);
          if (onComplete) onComplete();
        },
      });

      // 1. Loading animation: 20 segmentation vertical rectangles fill from left to right
      tl.to(blocks, {
        clipPath: "inset(-1% -1% -1% -1%)",
        webkitClipPath: "inset(-1% -1% -1% -1%)",
        duration: 0.52,
        ease: "power3.inOut",
        stagger: {
          each: 0.022,
          from: "start", // Left side to right side
        },
      });

      // 2. Signature animation:
      // Fade in the signature container as the center fills with white
      tl.to(
        signatureRef.current,
        {
          opacity: 1,
          duration: 0.22,
          ease: "power2.out",
        },
        "-=0.18",
      );

      // Give signature stroke drawing animation time to complete cleanly
      tl.to({}, { duration: 1.35 });

      // 3. Exit animation:
      // Fade out signature cleanly
      tl.to(signatureRef.current, {
        opacity: 0,
        y: -10,
        duration: 0.2,
        ease: "power2.in",
      });

      // 20 vertical rectangles exit from left side to right side (revealing the page)
      tl.to(
        blocks,
        {
          clipPath: "inset(-1% -1% -1% 101%)",
          webkitClipPath: "inset(-1% -1% -1% 101%)",
          duration: 0.62,
          ease: "power3.inOut",
          stagger: {
            each: 0.022,
            from: "start", // Left side to right side
          },
        },
        "-=0.08",
      );
    }, containerRef);

    return () => {
      document.body.style.overflow = originalOverflow;
      ctx.revert();
    };
  }, [onComplete]);

  if (isDone) return null;

  return (
    <div
      ref={containerRef}
      className="fixed inset-0 z-[99999] pointer-events-auto select-none overflow-hidden bg-transparent"
      aria-live="polite"
      aria-label="Loading Huly Pay"
    >
      {/* 20 segmentation of vertical rectangles with white color, no border colors */}
      <div className="absolute inset-0 flex flex-row pointer-events-none overflow-hidden w-full h-full">
        {Array.from({ length: SEGMENT_COUNT }).map((_, i) => (
          <div
            key={i}
            ref={(el) => {
              blocksRef.current[i] = el;
            }}
            className="h-full flex-1 bg-white border-0 outline-none select-none pointer-events-none"
            style={{
              clipPath: "inset(0% 100% 0% 0%)",
              WebkitClipPath: "inset(0% 100% 0% 0%)",
              willChange: "clip-path",
            }}
          />
        ))}
      </div>

      {/* Signature animation in center */}
      <div
        ref={signatureRef}
        className="relative z-10 w-full h-full flex items-center justify-center px-6 pointer-events-none"
        style={{ opacity: 0 }}
      >
        <AnimatedSignature
          delay={0.45}
          duration={1.3}
          className="w-[110px] sm:w-[150px] md:w-[190px] max-w-[85vw]"
        />
      </div>
    </div>
  );
}
