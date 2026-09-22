"use client";

import React, { useId } from "react";
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
 * Renders the vector signature from Loading_signature_animated.svg with full GSAP control.
 * In "initial" mode: The mask path stroke-dashoffset starts at 963 and is choreographed by GSAP.
 * In "normal" mode: Plays the original 1100ms signature animation (or can be tweened via GSAP).
 */
export default function AnimatedSignature({
  svgRef,
  maskPathRef,
  fillPathRef,
  mode = "initial", // "initial" | "normal" | "controlled"
  color = "#111111",
  className = "w-full max-w-[560px] h-auto",
  strokeWidth = 14.4,
}) {
  const generatedId = useId().replace(/:/g, "_");
  const maskId = `sig-mask-${generatedId}`;
  const animClass = `sig-anim-${generatedId}`;

  const isNormalMode = mode === "normal";

  return (
    <div className={`relative flex items-center justify-center select-none ${className}`}>
      {/* If normal mode with CSS animation, inject keyframes */}
      {isNormalMode && (
        <style>{`
          .${animClass} {
            stroke-dasharray: ${SIGNATURE_STROKE_LENGTH};
            stroke-dashoffset: ${SIGNATURE_STROKE_LENGTH};
            animation: ${animClass} 1100ms cubic-bezier(0.4, 0, 0.2, 1) 0ms forwards;
          }
          @keyframes ${animClass} {
            to { stroke-dashoffset: 0; }
          }
        `}</style>
      )}

      <svg
        ref={svgRef}
        xmlns="http://www.w3.org/2000/svg"
        viewBox={SIGNATURE_VIEWBOX}
        width={SIGNATURE_WIDTH}
        height={SIGNATURE_HEIGHT}
        role="img"
        aria-label="Huly Pay Signature"
        className="w-full h-auto drop-shadow-sm overflow-visible"
      >
        <defs>
          <mask
            id={maskId}
            maskUnits="userSpaceOnUse"
            x="334.33"
            y="78.08"
            width={SIGNATURE_WIDTH}
            height={SIGNATURE_HEIGHT}
          >
            <path
              ref={maskPathRef}
              d={SIGNATURE_MASK_PATH}
              fill="none"
              stroke="#ffffff"
              strokeWidth={strokeWidth}
              strokeLinecap="round"
              strokeLinejoin="round"
              style={{
                strokeDasharray: SIGNATURE_STROKE_LENGTH,
                strokeDashoffset: isNormalMode ? undefined : SIGNATURE_STROKE_LENGTH,
              }}
              className={isNormalMode ? animClass : ""}
            />
          </mask>
        </defs>

        <g mask={`url(#${maskId})`}>
          <path
            ref={fillPathRef}
            d={SIGNATURE_FILL_PATH}
            fill={color}
          />
        </g>
      </svg>
    </div>
  );
}
