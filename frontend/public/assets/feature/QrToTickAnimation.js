"use client";

export const MORPH_PIXELS = [
  // 1-4: Checkmark start tip & left arm
  { qrX: 24, qrY: 24, tickX: 28, tickY: 66 },
  { qrX: 34, qrY: 24, tickX: 38, tickY: 76 },
  { qrX: 44, qrY: 24, tickX: 48, tickY: 86 },
  { qrX: 24, qrY: 34, tickX: 58, tickY: 96 }, // vertex

  // 5-8: Checkmark double-layer lower arm
  { qrX: 34, qrY: 34, tickX: 28, tickY: 76 },
  { qrX: 44, qrY: 34, tickX: 38, tickY: 86 },
  { qrX: 24, qrY: 44, tickX: 48, tickY: 96 },
  { qrX: 44, qrY: 44, tickX: 58, tickY: 106 },

  // 9-14: Checkmark long stem ascending
  { qrX: 88, qrY: 24, tickX: 68, tickY: 86 },
  { qrX: 98, qrY: 24, tickX: 78, tickY: 76 },
  { qrX: 108, qrY: 24, tickX: 88, tickY: 66 },
  { qrX: 88, qrY: 34, tickX: 98, tickY: 56 },
  { qrX: 98, qrY: 34, tickX: 108, tickY: 46 },
  { qrX: 108, qrY: 34, tickX: 118, tickY: 36 },

  // 15-20: Checkmark double-layer upper stem
  { qrX: 88, qrY: 44, tickX: 68, tickY: 96 },
  { qrX: 108, qrY: 44, tickX: 78, tickY: 86 },
  { qrX: 24, qrY: 88, tickX: 88, tickY: 76 },
  { qrX: 34, qrY: 88, tickX: 98, tickY: 66 },
  { qrX: 44, qrY: 88, tickX: 108, tickY: 56 },
  { qrX: 24, qrY: 98, tickX: 118, tickY: 46 },

  // 21-22: Tip caps & reinforcement
  { qrX: 34, qrY: 98, tickX: 118, tickY: 26 },
  { qrX: 44, qrY: 98, tickX: 48, tickY: 106 },
];

export const EXTRA_PIXELS = [
  { x: 24, y: 108 },
  { x: 34, y: 108 },
  { x: 44, y: 108 },
  { x: 88, y: 88 },
  { x: 98, y: 88 },
  { x: 108, y: 88 },
  { x: 98, y: 98 },
  { x: 108, y: 98 },
  { x: 88, y: 108 },
  { x: 108, y: 108 },
  { x: 62, y: 56 },
  { x: 72, y: 66 },
];

export default function QrToTickAnimation({ className = "" }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`}>
      <svg
        viewBox="0 0 140 140"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-28 h-28 sm:w-32 sm:h-32 md:w-36 md:h-36 overflow-visible select-none drop-shadow-[0_0_10px_rgba(255,255,255,0.4)]"
      >
        {/* 22 Morphing Pixels (Start at QR positions, morph to Checkmark positions) */}
        <g fill="white">
          {MORPH_PIXELS.map((p, idx) => (
            <rect
              key={`morph-${idx}`}
              x={p.qrX}
              y={p.qrY}
              width="8"
              height="8"
              className="qr-morph-pixel"
              data-qr-x={p.qrX}
              data-qr-y={p.qrY}
              data-tick-x={p.tickX}
              data-tick-y={p.tickY}
            />
          ))}
        </g>

        {/* 12 Extra QR Pixels (Dissolve during scroll) */}
        <g fill="white">
          {EXTRA_PIXELS.map((p, idx) => (
            <rect
              key={`extra-${idx}`}
              x={p.x}
              y={p.y}
              width="8"
              height="8"
              className="qr-extra-pixel"
            />
          ))}
        </g>
      </svg>
    </div>
  );
}
