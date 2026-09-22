"use client";

import React, { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import AnimatedSignature from "./AnimatedSignature";
import { SIGNATURE_STROKE_LENGTH } from "./signaturePaths";

/**
 * InitialLoader Component
 *
 * Minimalist pure white loading screen showing ONLY the animated signature SVG
 * positioned right in the center of the screen with a smaller, refined size.
 *
 * Choreographed GSAP timeline tuned for 6 seconds:
 * - 0.0s - 0.2s: Pure white canvas preparation
 * - 0.2s - 3.6s (~3.4s): Staggered cursive stroke writing of the signature
 * - 3.6s - 5.1s (~1.5s): Waiting animation (signature breathes and settles in center)
 * - 5.1s - 6.0s (~0.9s): Clean curtain lift revealing the page
 */
export default function InitialLoader({ onComplete }) {
  const [isDone, setIsDone] = useState(false);
  const containerRef = useRef(null);
  const signatureRef = useRef(null);
  const maskPathRef = useRef(null);
  const fillPathRef = useRef(null);

  useEffect(() => {
    // Lock scrolling while the initial loading screen is active
    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({
        defaults: { ease: "power2.out" },
        onComplete: () => {
          document.body.style.overflow = originalOverflow;
          setIsDone(true);
          if (onComplete) onComplete();
        },
      });

      // Initial state setup: centered, stroke hidden
      gsap.set(containerRef.current, { yPercent: 0, opacity: 1 });
      gsap.set(signatureRef.current, { scale: 0.95, opacity: 1 });
      gsap.set(maskPathRef.current, {
        strokeDashoffset: SIGNATURE_STROKE_LENGTH,
      });

      // 1. Initial fade-in & scale focus (0.0s - 0.3s)
      tl.to(
        signatureRef.current,
        {
          scale: 1,
          duration: 0.4,
          ease: "power2.out",
        },
        0,
      );

      // 2. Staggered cursive calligraphy drawing (0.2s - 3.6s, ~3.4s)
      // Realistic pen speed variations across loops and curves
      tl.to(
        maskPathRef.current,
        {
          strokeDashoffset: SIGNATURE_STROKE_LENGTH * 0.72,
          duration: 1.0,
          ease: "power1.inOut",
        },
        0.2,
      );

      tl.to(
        maskPathRef.current,
        {
          strokeDashoffset: SIGNATURE_STROKE_LENGTH * 0.32,
          duration: 1.2,
          ease: "power2.out",
        },
        1.2,
      );

      tl.to(
        maskPathRef.current,
        {
          strokeDashoffset: 0,
          duration: 1.2,
          ease: "power1.inOut",
        },
        2.4,
      );

      // 3. Waiting Animation Tuning (3.6s - 5.1s, ~1.5s)
      // Pure signature breathing / gentle pulse in dead center
      tl.to(
        signatureRef.current,
        {
          scale: 1.035,
          duration: 0.75,
          yoyo: true,
          repeat: 1,
          ease: "sine.inOut",
        },
        3.6,
      );

      // 4. Elegant Awwwards-style Curtain Sweep Exit (5.1s - 6.0s, ~0.9s)
      tl.to(
        signatureRef.current,
        {
          opacity: 0,
          y: -15,
          scale: 1.02,
          duration: 0.45,
          ease: "power2.in",
        },
        5.05,
      );

      // The full white curtain sweeps upward cleanly to reveal the website
      tl.to(
        containerRef.current,
        {
          yPercent: -100,
          duration: 0.9,
          ease: "power4.inOut",
        },
        5.1,
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
      className="fixed inset-0 z-[99999] bg-white flex items-center justify-center select-none overflow-hidden"
      style={{ willChange: "transform" }}
      aria-live="polite"
      aria-label="Loading Huly Pay"
    >
      {/* Centered Smaller Signature Vector — no extra bars, text, or content */}
      <div
        ref={signatureRef}
        className="w-full flex items-center justify-center px-6"
      >
        <AnimatedSignature
          maskPathRef={maskPathRef}
          fillPathRef={fillPathRef}
          mode="initial"
          color="#0a0a0a"
          className="w-[100px] sm:w-[140px] md:w-[180px] max-w-[85vw]"
        />
      </div>
    </div>
  );
}
