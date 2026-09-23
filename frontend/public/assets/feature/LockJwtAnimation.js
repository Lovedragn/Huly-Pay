"use client";

export default function LockJwtAnimation({ className = "" }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`}>
      <svg
        viewBox="0 0 140 140"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-28 h-28 sm:w-32 sm:h-32 md:w-36 md:h-36 overflow-visible select-none drop-shadow-[0_0_10px_rgba(255,255,255,0.4)]"
      >
        {/* Shackle (Snaps from unlocked to locked on scroll) */}
        <g fill="white" className="lock-shackle">
          {/* Top Arch */}
          <rect x="42" y="22" width="56" height="12" />
          <rect x="48" y="16" width="44" height="6" />

          {/* Left Leg */}
          <rect x="42" y="34" width="12" height="24" />

          {/* Right Leg */}
          <rect x="86" y="34" width="12" height="24" />
        </g>

        {/* Chunky Fat Lock Body */}
        <g className="lock-body">
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

          {/* Security Spark on Lock */}
          <g fill="white" className="lock-spark">
            <rect x="68" y="66" width="4" height="4" />
            <rect x="76" y="76" width="4" height="4" />
            <rect x="60" y="76" width="4" height="4" />
            <rect x="68" y="86" width="4" height="4" />
          </g>
        </g>
      </svg>
    </div>
  );
}
