"use client";

import { useEffect, useRef, useState, useId } from "react";
import gsap from "gsap";

// Streamlined text data without arrays or runtime .join() allocations
const CURRENCY_TEXT =
  "$3,400 ✦ ₹23,000 ✦ €1,250 ✦ $9,820 ✦ £4,500 ✦ ¥50,000 ✦ CHF 1,600 ✦ $78,500 ✦ ";

const CIPHER_TEXT =
  "#$^#$^ ✦ #&@!$% ✦ #^&&@# ✦ $#@%! ✦ #%^&@ ✦ $#^&&@! ✦ #$%@!&#^ ✦ *#&^@$! ✦ ";

// Calibrated cycle distance matching 1 unit of text at fontSize 24 (~1240 user units)
const INITIAL_CYCLE_LENGTH = 1240;

// Path arc length where the middle separator is located (~1640 user units)
const SEPARATOR_OFFSET = 1640;

const PLAIN_FLOW = CURRENCY_TEXT.repeat(4);
const CIPHER_FLOW = CIPHER_TEXT.repeat(4);

export default function VeinTextFlow() {
  const plainTextRef = useRef(null);
  const [cycleLength, setCycleLength] = useState(INITIAL_CYCLE_LENGTH);

  // Dedicated refs for the physical lock animation timeline
  const shackleRef = useRef(null);
  const lockBodyRef = useRef(null);
  const sparkRef = useRef(null);

  // Colon-free unique IDs for safe SSR SVG references
  const uid = useId().replace(/:/g, "");
  const pathId = `vein-${uid}`;
  const leftClipId = `left-clip-${uid}`;
  const rightClipId = `right-clip-${uid}`;

  // Corner-to-corner path with a spacious 360-degree loop on the left side
  const veinPath =
    "M 0,0 " +
    "C 70,30 140,150 210,190 " +
    "C 270,225 350,250 430,225 " +
    "C 520,195 560,110 510,45 " +
    "C 460,-15 350,-15 300,45 " +
    "C 250,105 240,185 290,235 " +
    "C 350,290 470,255 570,205 " +
    "C 630,180 670,180 720,180 " +
    "C 770,180 820,120 900,90 " +
    "C 980,60 1060,60 1140,110 " +
    "C 1220,160 1280,250 1350,300 " +
    "C 1390,330 1420,350 1440,360";

  // Measure exact rendered text cycle on mount for sub-pixel seamless loop
  useEffect(() => {
    if (plainTextRef.current) {
      try {
        const measured = plainTextRef.current.getComputedTextLength();
        if (measured > 0) {
          const singleCycle = Math.round(measured / 4);
          if (Math.abs(singleCycle - INITIAL_CYCLE_LENGTH) > 5) {
            setCycleLength(singleCycle);
          }
        }
      } catch {}
    }
  }, []);

  useEffect(() => {
    // GSAP context cleanly scoped for discrete, physical transform animation of the lock
    const ctx = gsap.context(() => {
      if (!shackleRef.current || !lockBodyRef.current || !sparkRef.current)
        return;

      // Initial state: unlocked and ready
      gsap.set(shackleRef.current, {
        y: -12,
        x: 2,
        rotation: -16,
        transformOrigin: "48px 34px",
        force3D: true,
      });
      gsap.set(lockBodyRef.current, { y: 0, force3D: true });
      gsap.set(sparkRef.current, {
        opacity: 0,
        scale: 0.2,
        transformOrigin: "70px 76px",
        force3D: true,
      });

      const lockTl = gsap.timeline({ repeat: -1, repeatDelay: 10 });
      lockTl
        // 1. Stays open
        .to({}, { duration: 0.8 })
        // 2. Snaps shut
        .to(shackleRef.current, {
          y: 0,
          x: 0,
          rotation: 0,
          duration: 0.16,
          ease: "power3.in",
        })
        // 3. Physical body thump / bounce
        .to(
          lockBodyRef.current,
          { y: 3, duration: 0.05, ease: "power1.in" },
          "-=0.03",
        )
        .to(lockBodyRef.current, { y: 0, duration: 0.08, ease: "power1.out" })
        // 4. Security spark burst on keyhole
        .fromTo(
          sparkRef.current,
          { opacity: 1, scale: 0.2 },
          { opacity: 1, scale: 1.3, duration: 0.12, ease: "power2.out" },
          "-=0.05",
        )
        .to(sparkRef.current, {
          opacity: 0,
          scale: 1.8,
          duration: 0.2,
          ease: "power1.in",
        })
        // 5. Stays locked securely
        .to({}, { duration: 1.8 })
        // 6. Opens again with organic mechanical recoil
        .to(shackleRef.current, {
          y: -12,
          x: 2,
          rotation: -16,
          duration: 0.3,
          ease: "back.out(1.6)",
        });
    });

    return () => ctx.revert();
  }, []);

  return (
    <div className="w-full relative select-none overflow-hidden pointer-events-none touch-pan-y flex justify-center">
      <svg
        viewBox="-30 -30 1500 420"
        className="w-[180%] sm:w-[130%] md:w-full h-auto shrink-0 overflow-visible pointer-events-none"
        style={{ display: "block" }}
      >
        <defs>
          {/* Static geometric path: rendered once, never modified or recalculated */}
          <path id={pathId} d={veinPath} fill="none" />

          {/* Left clip: covers entrance up to separator */}
          <clipPath id={leftClipId}>
            <rect x="-100" y="-100" width="769" height="600" />
          </clipPath>

          {/* Right clip: covers separator exit through the right edge */}
          <clipPath id={rightClipId}>
            <rect x="771" y="-100" width="850" height="600" />
          </clipPath>
        </defs>

        {/* RIGHT SIDE VEIN: Solid black background path */}
        <path
          d={veinPath}
          fill="none"
          stroke="#000000"
          strokeWidth="56"
          strokeLinecap="round"
          strokeLinejoin="round"
          clipPath={`url(#${rightClipId})`}
        />

        {/* 
          LEFT-SIDE CURRENCY CONVEYOR FLOW:
          Isolated GPU layer using translate3d. Coordinates flow along the static curve
          via native browser x-positioning without 60fps JavaScript execution loops.
        */}
        <g
          clipPath={`url(#${leftClipId})`}
          style={{ willChange: "transform", transform: "translate3d(0, 0, 0)" }}
        >
          <text
            ref={plainTextRef}
            x={`-${cycleLength}`}
            className="font-pixel font-bold"
            fill="#555555"
            fontSize="24"
            letterSpacing="0.05em"
            dominantBaseline="central"
          >
            <textPath href={`#${pathId}`}>{PLAIN_FLOW}</textPath>
            <animate
              key={`plain-anim-${cycleLength}`}
              attributeName="x"
              from={`-${cycleLength}`}
              to="0"
              dur="14s"
              repeatCount="indefinite"
            />
          </text>
        </g>

        {/* 
          RIGHT-SIDE ENCRYPTED CONVEYOR FLOW:
          White cipher text on top of the black vein.
          Starts at the middle separator (SEPARATOR_OFFSET ~1640px) and flows
          outwards to the right at a faster speed (8s) than the left side (14s).
        */}
        <g
          clipPath={`url(#${rightClipId})`}
          style={{ willChange: "transform", transform: "translate3d(0, 0, 0)" }}
        >
          <text
            x={`${SEPARATOR_OFFSET - cycleLength}`}
            className="font-pixel font-bold"
            fill="#FFFFFF"
            fontSize="24"
            letterSpacing="0.05em"
            dominantBaseline="central"
          >
            <textPath href={`#${pathId}`}>{CIPHER_FLOW}</textPath>
            <animate
              key={`cipher-anim-${cycleLength}`}
              attributeName="x"
              from={`${SEPARATOR_OFFSET - cycleLength}`}
              to={`${SEPARATOR_OFFSET}`}
              dur="8s"
              repeatCount="indefinite"
            />
          </text>
        </g>

        {/* MIDDLE SEPARATOR: Rounded Red Rectangle with Animated White Fat Lock */}
        <g>
          {/* Background color (#FFFFEB) cutout gap cleanly slicing the vein */}
          <rect
            x="656"
            y="104"
            width="128"
            height="152"
            rx="26"
            fill="#FFFFEB"
          />

          {/* Red Rounded Rectangle Separator */}
          <rect
            x="669"
            y="117"
            width="102"
            height="126"
            rx="20"
            fill="#FF0000"
            stroke="#B30003"
            strokeWidth="4"
            style={{ filter: "drop-shadow(0 6px 14px rgba(179,0,3,0.4))" }}
          />

          {/* Chunky White Pixel Lock */}
          <g transform="translate(720, 180) scale(0.95) translate(-70, -65)">
            {/* Shackle: snaps between unlocked and locked positions */}
            <g ref={shackleRef} fill="white">
              {/* Top Arch */}
              <rect x="42" y="22" width="56" height="12" />
              <rect x="48" y="16" width="44" height="6" />

              {/* Left Leg */}
              <rect x="42" y="34" width="12" height="24" />

              {/* Right Leg */}
              <rect x="86" y="34" width="12" height="24" />
            </g>

            {/* Chunky Lock Body */}
            <g ref={lockBodyRef}>
              {/* Main White Body */}
              <rect x="30" y="58" width="80" height="52" fill="white" />
              <rect x="34" y="54" width="72" height="4" fill="white" />
              <rect x="34" y="110" width="72" height="4" fill="white" />

              {/* Shackle Entry Sockets (Contrasting Red Slots) */}
              <rect x="42" y="54" width="12" height="6" fill="#CC0000" />
              <rect x="86" y="54" width="12" height="6" fill="#CC0000" />

              {/* Center Pixel Keyhole */}
              <rect x="66" y="74" width="8" height="8" fill="#CC0000" />
              <rect x="68" y="82" width="4" height="12" fill="#CC0000" />
              <rect x="66" y="92" width="8" height="4" fill="#CC0000" />

              {/* Security Spark on Keyhole */}
              <g ref={sparkRef} fill="white">
                <rect x="68" y="66" width="4" height="4" />
                <rect x="76" y="76" width="4" height="4" />
                <rect x="60" y="76" width="4" height="4" />
                <rect x="68" y="86" width="4" height="4" />
              </g>
            </g>
          </g>
        </g>
      </svg>
    </div>
  );
}
