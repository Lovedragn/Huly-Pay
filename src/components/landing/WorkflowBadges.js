"use client";

// Frame 145: Scan QR Code Badge (Step 1)
export function Frame145Badge({ svgRef, className = "" }) {
  return (
    <svg
      ref={svgRef}
      viewBox="0 0 323 357"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Outer Bracket Frame */}
      <g className="badge-frame" fill="#D9D9D9">
        <rect x="62" y="16" width="186" height="27" />
        <rect x="31" y="42.7144" width="31" height="42.7143" />
        <path d="M248 42.7141H279V85.4284H248V42.7141Z" />
        <rect y="85.4285" width="31" height="85.4286" />
        <rect x="278" y="85.4287" width="31" height="85.4286" />
        <rect width="43" height="43" transform="matrix(1 0 0 -1 19 214)" />
        <rect width="132" height="28" transform="matrix(1 0 0 -1 72 284)" />
        <rect width="22" height="28" transform="matrix(1 0 0 -1 204 260)" />
        <rect width="31" height="64" transform="matrix(1 0 0 -1 41 278)" />
        <rect x="295" y="208" width="14" height="65" />
        <rect x="309" y="161" width="14" height="47" />
        <rect width="71" height="14" transform="matrix(1 0 0 -1 226 274)" />
      </g>
      {/* Inner QR Matrix Pixels (animates to 30% darker tone) */}
      <g className="badge-inner" fill="white">
        <rect width="34.5" height="34.5" transform="translate(94 88)" />
        <rect width="34.5" height="34.5" transform="translate(197.5 88)" />
        <rect width="34.5" height="34.5" transform="translate(94 187.36)" />
        <rect width="17.94" height="17.94" transform="translate(128.5 169.42)" />
        <rect width="17.94" height="17.94" transform="translate(146.44 151.48)" />
        <rect width="17.94" height="17.94" transform="translate(164.38 133.54)" />
        <rect width="17.94" height="17.94" transform="translate(185.08 169.42)" />
        <rect width="17.94" height="17.94" transform="translate(203.02 151.48)" />
        <rect width="17.94" height="17.94" transform="translate(203.02 187.36)" />
        <rect width="17.94" height="17.94" transform="translate(185.08 205.3)" />
        <rect width="17.94" height="17.94" transform="translate(147.82 205.3)" />
        <rect width="17.94" height="17.94" transform="translate(146.44 115.6)" />
        <rect width="17.94" height="17.94" transform="translate(164.38 97.6599)" />
        <rect width="17.94" height="17.94" transform="translate(182.32 133.54)" />
        <rect width="17.94" height="17.94" transform="translate(110.56 151.48)" />
      </g>
      {/* Inner QR Core Finder Dots */}
      <g className="badge-core" fill="#D6D6D6">
        <rect width="17.94" height="17.94" transform="translate(102.28 96.28)" />
        <rect width="17.94" height="17.94" transform="translate(205.78 96.28)" />
        <rect width="17.94" height="17.94" transform="translate(102.28 195.64)" />
      </g>
    </svg>
  );
}

// Frame 143: Secure Transactions Down Chevron Badge (Step 2)
export function Frame143Badge({ svgRef, className = "" }) {
  return (
    <svg
      ref={svgRef}
      viewBox="0 0 248 299"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Outer Bracket Frame */}
      <g className="badge-frame" fill="#D9D9D9">
        <rect y="42" width="25" height="194" />
        <rect x="223" y="42" width="25" height="194" />
        <rect x="25" y="21" width="46" height="21" />
        <rect x="177" y="21" width="46" height="21" />
        <rect x="71" width="80" height="21" />
        <rect x="165" width="12" height="21" />
        <rect width="46" height="21" transform="matrix(1 0 0 -1 25 257)" />
        <rect width="46" height="21" transform="matrix(1 0 0 -1 177 257)" />
        <rect width="80" height="21" transform="matrix(1 0 0 -1 71 278)" />
        <rect width="14" height="21" transform="matrix(1 0 0 -1 151 299)" />
        <rect width="12" height="21" transform="matrix(1 0 0 -1 165 278)" />
      </g>
      {/* Inner Chevrons Pixels (animates to 30% darker tone) */}
      <g className="badge-inner" fill="white">
        <rect width="19" height="15" transform="translate(71 133)" />
        <rect width="18" height="15" transform="translate(84 148)" />
        <rect width="20" height="15" transform="translate(97 163)" />
        <rect width="18" height="15" transform="translate(160 133)" />
        <rect width="17" height="15" transform="translate(148 148)" />
        <rect width="19" height="15" transform="translate(133 163)" />
        <rect width="13" height="15" transform="translate(110 178)" />
        <rect width="16" height="15" transform="translate(123 178)" />
        <rect width="16" height="15" transform="translate(117 193)" />
        <rect width="19" height="15" transform="translate(71 81)" />
        <rect width="18" height="15" transform="translate(84 96)" />
        <rect width="20" height="15" transform="translate(97 111)" />
        <rect width="18" height="15" transform="translate(160 81)" />
        <rect width="17" height="15" transform="translate(148 96)" />
        <rect width="19" height="15" transform="translate(133 111)" />
        <rect width="13" height="15" transform="translate(110 126)" />
        <rect width="16" height="15" transform="translate(123 126)" />
        <rect width="16" height="15" transform="translate(117 141)" />
      </g>
    </svg>
  );
}

// Frame 144: Visual Data Star Shield Badge (Step 3)
export function Frame144Badge({ svgRef, className = "" }) {
  return (
    <svg
      ref={svgRef}
      viewBox="0 0 309 342"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      {/* Outer Bracket Frame */}
      <g className="badge-frame" fill="#D9D9D9">
        <rect x="62" width="186" height="43" />
        <rect x="31" y="42.7144" width="31" height="42.7143" />
        <path d="M248 42.7141H279V85.4284H248V42.7141Z" />
        <rect y="85.4285" width="31" height="85.4286" />
        <rect x="278" y="85.4287" width="31" height="85.4286" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 31 213.572)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 62 256.286)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 247 213.714)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 216 256.429)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 185 299.286)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 93 299)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 124 342)" />
        <rect width="31" height="42.7143" transform="matrix(1 0 0 -1 155 341.714)" />
      </g>
      {/* Inner Sparkle Star Shield (animates to 30% darker tone) */}
      <g className="badge-inner" fill="white">
        <rect width="24" height="24" transform="translate(154 114)" />
        <rect width="24" height="24" transform="translate(154 90)" />
        <rect width="24" height="24" transform="translate(154 138)" />
        <rect width="24" height="24" transform="translate(154 162)" />
        <rect width="24" height="24" transform="translate(154 186)" />
        <rect width="24" height="24" transform="translate(178 114)" />
        <rect width="24" height="24" transform="translate(178 162)" />
        <rect width="24" height="24" transform="translate(202 138)" />
        <rect width="14" height="14" transform="translate(226 143)" />
        <rect width="14" height="14" transform="translate(147 210)" />
        <rect width="14" height="14" transform="translate(147 76)" />
        <rect width="14" height="14" transform="translate(69 143)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 155 114)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 155 90)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 155 138)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 155 162)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 155 186)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 131 114)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 131 162)" />
        <rect width="24" height="24" transform="matrix(-1 0 0 1 107 138)" />
      </g>
    </svg>
  );
}
