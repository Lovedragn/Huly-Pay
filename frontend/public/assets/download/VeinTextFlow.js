"use client";

import { useEffect, useRef, useId } from "react";
import gsap from "gsap";

const REPEAT_COUNT = 6;
const CURRENCY_ITEMS = ["$3,400", "₹23,000", "€1,250", "$9,820", "£4,500", "¥50,000", "CHF 1,600", "$78,500"];
const CIPHER_ITEMS   = ["#$^#$^", "*#&@!$%", "#^&&@#", "*$#@%!", "#%^&*@", "$#^&&@!", "#$%@*!&#^", "*#&^@$!"];

const SEPARATOR = "   ✦   ";
const PLAIN_BLOCK  = CURRENCY_ITEMS.join(SEPARATOR) + SEPARATOR;
const CIPHER_BLOCK = CIPHER_ITEMS.join(SEPARATOR) + SEPARATOR;

const PLAIN_TEXT  = PLAIN_BLOCK.repeat(REPEAT_COUNT);
const CIPHER_TEXT = CIPHER_BLOCK.repeat(REPEAT_COUNT);

export default function VeinTextFlow() {
  const plainPathRef = useRef(null);
  const cipherPathRef = useRef(null);
  const plainTextRef = useRef(null);
  const cipherTextRef = useRef(null);

  // Refs for the fat lock repeated animation
  const shackleRef = useRef(null);
  const lockBodyRef = useRef(null);
  const sparkRef = useRef(null);

  const uid = useId().replace(/:/g, "");
  const pathId = `vein-${uid}`;
  const leftClipId = `left-clip-${uid}`;
  const rightClipId = `right-clip-${uid}`;

  // Corner-to-corner path with a large, spacious 360-degree loop on the left side
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

  useEffect(() => {
    if (!plainPathRef.current || !cipherPathRef.current || !plainTextRef.current) return;

    let plainTotalLength = 0;
    let cipherTotalLength = 0;
    try {
      plainTotalLength = plainTextRef.current.getComputedTextLength();
    } catch {}
    try {
      if (cipherTextRef.current) {
        cipherTotalLength = cipherTextRef.current.getComputedTextLength();
      }
    } catch {}

    const cycleLengthPlain = plainTotalLength > 0 ? plainTotalLength / REPEAT_COUNT : 950;
    const cycleLengthCipher = cipherTotalLength > 0 ? cipherTotalLength / REPEAT_COUNT : 950;

    const ctx = gsap.context(() => {
      // 1. LEFT SIDE (Faster flow)
      gsap.set(plainPathRef.current, {
        attr: { startOffset: `${-cycleLengthPlain}px` },
      });
      gsap.to(plainPathRef.current, {
        attr: { startOffset: "0px" },
        duration: 14,
        ease: "none",
        repeat: -1,
      });

      // 2. RIGHT SIDE (Slower flow)
      gsap.set(cipherPathRef.current, {
        attr: { startOffset: `${-cycleLengthCipher}px` },
      });
      gsap.to(cipherPathRef.current, {
        attr: { startOffset: "0px" },
        duration: 32,
        ease: "none",
        repeat: -1,
      });

      // 3. FAT LOCK REPEATING ANIMATION
      if (shackleRef.current && lockBodyRef.current && sparkRef.current) {
        gsap.set(shackleRef.current, {
          y: -12,
          x: 2,
          rotation: -16,
          transformOrigin: "48px 34px",
        });
        gsap.set(lockBodyRef.current, { y: 0 });
        gsap.set(sparkRef.current, {
          opacity: 0,
          scale: 0.2,
          transformOrigin: "70px 76px",
        });

        const lockTl = gsap.timeline({ repeat: -1, repeatDelay: 10 });
        lockTl
          // Hold open briefly
          .to({}, { duration: 0.8 })
          // Snap shut
          .to(shackleRef.current, {
            y: 0,
            x: 0,
            rotation: 0,
            duration: 0.16,
            ease: "power3.in",
          })
          // Lock body subtle physical thump
          .to(lockBodyRef.current, { y: 3, duration: 0.05, ease: "power1.in" }, "-=0.03")
          .to(lockBodyRef.current, { y: 0, duration: 0.08, ease: "power1.out" })
          // Spark flash on keyhole
          .fromTo(
            sparkRef.current,
            { opacity: 1, scale: 0.2 },
            { opacity: 1, scale: 1.3, duration: 0.12, ease: "power2.out" },
            "-=0.05"
          )
          .to(sparkRef.current, { opacity: 0, scale: 1.8, duration: 0.2, ease: "power1.in" })
          // Stay securely locked
          .to({}, { duration: 1.8 })
          // Re-open
          .to(shackleRef.current, {
            y: -12,
            x: 2,
            rotation: -16,
            duration: 0.3,
            ease: "back.out(1.6)",
          });
      }
    });

    return () => ctx.revert();
  }, []);

  return (
    <div className="w-full relative select-none overflow-visible">
      <svg
        viewBox="-30 -30 1500 420"
        className="w-full h-auto overflow-visible pointer-events-none"
        style={{ display: "block" }}
      >
        <defs>
          <path id={pathId} d={veinPath} fill="none" />

          {/* Left clip: covers up to the separator entrance */}
          <clipPath id={leftClipId}>
            <rect x="-100" y="-100" width="785" height="600" />
          </clipPath>

          {/* Right clip: covers from separator exit onwards */}
          <clipPath id={rightClipId}>
            <rect x="755" y="-100" width="850" height="600" />
          </clipPath>
        </defs>

        {/* RIGHT SIDE VEIN: Solid black background path with white text */}
        <path
          d={veinPath}
          fill="none"
          stroke="#000000"
          strokeWidth="42"
          strokeLinecap="round"
          strokeLinejoin="round"
          clipPath={`url(#${rightClipId})`}
        />

        {/* Left-side Plaintext flow (Transparent background with gray text) */}
        <g clipPath={`url(#${leftClipId})`}>
          <text
            ref={plainTextRef}
            className="font-pixel font-bold"
            fill="#555555"
            fontSize="14.5"
            letterSpacing="0.05em"
            dominantBaseline="central"
          >
            <textPath ref={plainPathRef} href={`#${pathId}`}>
              {PLAIN_TEXT}
            </textPath>
          </text>
        </g>

        {/* Right-side Encrypted flow (Black background with white text) */}
        <g clipPath={`url(#${rightClipId})`}>
          <text
            ref={cipherTextRef}
            className="font-pixel font-bold"
            fill="#FFFFFF"
            fontSize="14.5"
            letterSpacing="0.05em"
            dominantBaseline="central"
          >
            <textPath ref={cipherPathRef} href={`#${pathId}`}>
              {CIPHER_TEXT}
            </textPath>
          </text>
        </g>

        {/* MIDDLE SEPARATOR: Rounded Red Rectangle with Animated White Fat Lock */}
        <g>
          {/* Background color (#FFFFEB) padding gap cutting the vein */}
          <rect
            x="675"
            y="122"
            width="90"
            height="116"
            rx="22"
            fill="#FFFFEB"
          />

          {/* Red Rounded Rectangle Separator */}
          <rect
            x="685"
            y="132"
            width="70"
            height="96"
            rx="16"
            fill="#FF0000"
            stroke="#B30003"
            strokeWidth="3.5"
            style={{ filter: "drop-shadow(0 4px 10px rgba(179,0,3,0.35))" }}
          />

          {/* Fat Lock SVG (White with repeating snap animation) */}
          <g transform="translate(720, 180) scale(0.52) translate(-70, -65)">
            {/* Shackle (Snaps from unlocked to locked repeatedly) */}
            <g ref={shackleRef} fill="white">
              {/* Top Arch */}
              <rect x="42" y="22" width="56" height="12" />
              <rect x="48" y="16" width="44" height="6" />

              {/* Left Leg */}
              <rect x="42" y="34" width="12" height="24" />

              {/* Right Leg */}
              <rect x="86" y="34" width="12" height="24" />
            </g>

            {/* Chunky Fat Lock Body */}
            <g ref={lockBodyRef}>
              {/* Main Fat White Body */}
              <rect x="30" y="58" width="80" height="52" fill="white" />
              <rect x="34" y="54" width="72" height="4" fill="white" />
              <rect x="34" y="110" width="72" height="4" fill="white" />

              {/* Shackle Entry Sockets (Contrasting Red Slots) */}
              <rect x="42" y="54" width="12" height="6" fill="#CC0000" />
              <rect x="86" y="54" width="12" height="6" fill="#CC0000" />

              {/* Center Pixel Keyhole (Contrasting Red cutout in white body) */}
              <rect x="66" y="74" width="8" height="8" fill="#CC0000" />
              <rect x="68" y="82" width="4" height="12" fill="#CC0000" />
              <rect x="66" y="92" width="8" height="4" fill="#CC0000" />

              {/* Security Spark on Lock Keyhole */}
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
