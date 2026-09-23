"use client";

export default function WifiOfflineAnimation({ className = "" }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`}>
      <div className="wifi-float-container will-change-transform">
        <svg
          viewBox="0 0 140 140"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-28 h-28 sm:w-32 sm:h-32 md:w-36 md:h-36 overflow-visible select-none drop-shadow-[0_0_10px_rgba(255,255,255,0.4)]"
        >
          {/* Outer Arc 3 (Top) */}
          <g fill="white" className="wifi-outer-arc">
            <rect x="40" y="44" width="60" height="8" />
            <rect x="26" y="50" width="14" height="8" />
            <rect x="100" y="50" width="14" height="8" />
            <rect x="16" y="58" width="10" height="8" />
            <rect x="114" y="58" width="10" height="8" />
            <rect x="8" y="66" width="8" height="10" />
            <rect x="124" y="66" width="8" height="10" />
          </g>

          {/* Mid Arc 2 (Center) */}
          <g fill="white" className="wifi-mid-arc">
            <rect x="48" y="66" width="44" height="8" />
            <rect x="36" y="72" width="12" height="8" />
            <rect x="92" y="72" width="12" height="8" />
            <rect x="26" y="80" width="10" height="8" />
            <rect x="104" y="80" width="10" height="8" />
          </g>

          {/* Inner Arc 1 (Lower) */}
          <g fill="white" className="wifi-inner-arc">
            <rect x="56" y="86" width="28" height="8" />
            <rect x="46" y="92" width="10" height="8" />
            <rect x="84" y="92" width="10" height="8" />
          </g>

          {/* Dot (Center Core) */}
          <rect
            x="64"
            y="104"
            width="12"
            height="12"
            fill="white"
            className="wifi-dot"
          />
        </svg>
      </div>
    </div>
  );
}
