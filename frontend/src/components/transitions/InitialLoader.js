"use client";

import React, { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import AnimatedSignature from "./AnimatedSignature";

/**
 * InitialLoader Component
 *
 * Minimalist pure white loading screen showing ONLY the animated signature SVG
 * (/assets/animated_signature.svg) positioned right in the center of the screen.
 *
 * Timeline:
 * - Signature SVG renders and auto-plays its 1100ms cursive animation
 * - Breaths/settles gently in center
 * - Clean curtain sweeps upward off the screen to reveal the website
 */
export default function InitialLoader({ onComplete }) {
  const [isDone, setIsDone] = useState(false);
  const containerRef = useRef(null);
  const signatureRef = useRef(null);

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

      // Initial state setup
      gsap.set(containerRef.current, { yPercent: 0, opacity: 1 });
      gsap.set(signatureRef.current, { scale: 0.95, opacity: 1 });

      // 1. Focus scale
      tl.to(
        signatureRef.current,
        {
          scale: 1,
          duration: 0.4,
          ease: "power2.out",
        },
        0,
      );

      // 2. Allow signature SVG to complete its natural 1100ms draw, plus subtle breath
      tl.to(
        signatureRef.current,
        {
          scale: 1.03,
          duration: 0.6,
          yoyo: true,
          repeat: 1,
          ease: "sine.inOut",
        },
        1.2,
      );

      // 3. Elegant curtain lift (reveals website)
      tl.to(
        signatureRef.current,
        {
          opacity: 0,
          y: -15,
          scale: 1.02,
          duration: 0.35,
          ease: "power2.in",
        },
        2.2,
      );

      tl.to(
        containerRef.current,
        {
          yPercent: -100,
          duration: 0.75,
          ease: "power4.inOut",
        },
        2.3,
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
      <div
        ref={signatureRef}
        className="w-full flex items-center justify-center px-6"
      >
        <AnimatedSignature className="w-[110px] sm:w-[150px] md:w-[190px] max-w-[85vw]" />
      </div>
    </div>
  );
}
