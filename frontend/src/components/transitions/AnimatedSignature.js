"use client";

import React, { useId, useEffect, useRef } from "react";
import gsap from "gsap";
import {
  SIGNATURE_VIEWBOX,
  SIGNATURE_WIDTH,
  SIGNATURE_HEIGHT,
  SIGNATURE_STROKE_LENGTH,
  SIGNATURE_MASK_PATH,
  SIGNATURE_FILL_PATH,
} from "./signaturePaths";

/**
 * AnimatedSignature Component
 *
 * Direct inline SVG with GSAP stroke-dashoffset animation.
 * Because it's rendered as inline SVG with GSAP controlling stroke-dashoffset directly:
 * 1. It ALWAYS plays from 0% to 100% on every mount / page load, even if the user refreshes
 *    the page multiple times consecutively (bypasses browser image caching where SVG CSS @keyframes
 *    fail to restart on subsequent reloads).
 * 2. Perfect 60fps hardware-accelerated cursive handwriting reveal.
 */
export default function AnimatedSignature({
  className = "w-full max-w-[560px] h-auto",
  alt = "Huly Pay Signature",
  duration = 1.35,
  delay = 0,
  color = "#1a1a1a",
}) {
  const maskId = useId().replace(/:/g, "_");
  const maskPathRef = useRef(null);

  useEffect(() => {
    if (!maskPathRef.current) return;

    // Reset stroke-dashoffset to full stroke length
    gsap.set(maskPathRef.current, {
      strokeDasharray: SIGNATURE_STROKE_LENGTH,
      strokeDashoffset: SIGNATURE_STROKE_LENGTH,
    });

    // Animate smoothly to 0 offset (writing effect)
    const tween = gsap.to(maskPathRef.current, {
      strokeDashoffset: 0,
      duration: duration,
      delay: delay,
      ease: "power2.inOut",
    });

    return () => {
      tween.kill();
    };
  }, [duration, delay]);

  return (
    <div
      className={`relative flex items-center justify-center select-none ${className}`}
      role="img"
      aria-label={alt}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox={SIGNATURE_VIEWBOX}
        width={SIGNATURE_WIDTH}
        height={SIGNATURE_HEIGHT}
        className="w-full h-auto select-none pointer-events-none"
      >
        <defs>
          <mask
            id={maskId}
            maskUnits="userSpaceOnUse"
            x="334.333"
            y="78.075"
            width="565.805"
            height="144.967"
          >
            <path
              ref={maskPathRef}
              d={SIGNATURE_MASK_PATH}
              fill="none"
              stroke="#fff"
              strokeWidth="14.4"
              strokeLinecap="round"
              strokeLinejoin="round"
              style={{
                strokeDasharray: SIGNATURE_STROKE_LENGTH,
                strokeDashoffset: SIGNATURE_STROKE_LENGTH,
              }}
            />
          </mask>
        </defs>
        <g mask={`url(#${maskId})`}>
          <path d={SIGNATURE_FILL_PATH} fill={color} />
        </g>
      </svg>
    </div>
  );
}
