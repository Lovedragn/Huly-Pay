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
  className = "w-full max-w-[560px] h-auto",
  alt = "Huly Pay Signature",
}) {
  return (
    <div className={`relative flex items-center justify-center select-none ${className}`}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src="/assets/animated_signature.svg"
        alt={alt}
        width={SIGNATURE_WIDTH}
        height={SIGNATURE_HEIGHT}
        className="w-full h-auto drop-shadow-sm select-none pointer-events-none"
        loading="eager"
        decoding="sync"
      />
    </div>
  );
}
