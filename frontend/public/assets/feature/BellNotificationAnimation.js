"use client";

export default function BellNotificationAnimation({ className = "" }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`}>
      <svg
        viewBox="0 0 140 140"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-28 h-28 sm:w-32 sm:h-32 md:w-36 md:h-36 overflow-visible select-none drop-shadow-[0_0_10px_rgba(255,255,255,0.4)]"
      >
        {/* Left Sound Vibration Waves */}
        <g fill="white" className="bell-wave-left">
          <rect x="22" y="54" width="6" height="6" />
          <rect x="18" y="62" width="6" height="16" />
          <rect x="22" y="80" width="6" height="6" />
          <rect x="12" y="44" width="6" height="6" />
          <rect x="6" y="54" width="6" height="32" />
          <rect x="12" y="90" width="6" height="6" />
        </g>

        {/* Right Sound Vibration Waves */}
        <g fill="white" className="bell-wave-right">
          <rect x="112" y="54" width="6" height="6" />
          <rect x="116" y="62" width="6" height="16" />
          <rect x="112" y="80" width="6" height="6" />
          <rect x="122" y="44" width="6" height="6" />
          <rect x="128" y="54" width="6" height="32" />
          <rect x="122" y="90" width="6" height="6" />
        </g>

        {/* Shaking Bell Body Group */}
        <g className="bell-body" fill="white">
          {/* Top Loop */}
          <rect x="66" y="16" width="8" height="8" />

          {/* Dome */}
          <rect x="62" y="24" width="16" height="8" />
          <rect x="58" y="32" width="24" height="8" />
          <rect x="54" y="40" width="32" height="10" />
          <rect x="50" y="50" width="40" height="12" />
          <rect x="46" y="62" width="48" height="14" />

          {/* Bell Flare / Rim */}
          <rect x="38" y="76" width="64" height="10" />
          <rect x="32" y="86" width="76" height="10" />

          {/* Bell Clapper */}
          <g className="bell-clapper">
            <rect x="64" y="96" width="12" height="10" />
            <rect x="66" y="106" width="8" height="6" />
          </g>
        </g>
      </svg>
    </div>
  );
}
