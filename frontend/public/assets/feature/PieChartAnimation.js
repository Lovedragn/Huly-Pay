"use client";

export default function PieChartAnimation({ className = "" }) {
  return (
    <div className={`relative flex items-center justify-center ${className}`}>
      <svg
        viewBox="0 0 140 140"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-28 h-28 sm:w-32 sm:h-32 md:w-36 md:h-36 overflow-visible select-none drop-shadow-[0_0_10px_rgba(255,255,255,0.4)]"
      >
        {/* Barcode in Square Container (Initial state that transforms into the Pie Chart) */}
        <g className="barcode-container">
          {/* Square Pixel Outline Container with Corner Brackets */}
          <g fill="white" className="barcode-box">
            {/* Top & Bottom Walls */}
            <rect x="22" y="22" width="96" height="6" />
            <rect x="22" y="112" width="96" height="6" />

            {/* Left & Right Walls */}
            <rect x="22" y="28" width="6" height="84" />
            <rect x="112" y="28" width="6" height="84" />

            {/* Pixel Corner Brackets */}
            <rect x="18" y="18" width="10" height="10" />
            <rect x="112" y="18" width="10" height="10" />
            <rect x="18" y="112" width="10" height="10" />
            <rect x="112" y="112" width="10" height="10" />
          </g>

          {/* Barcode Stripes of varying widths */}
          <g fill="white" className="barcode-bars">
            <rect x="34" y="34" width="4" height="64" className="barcode-bar" />
            <rect x="42" y="34" width="8" height="64" className="barcode-bar" />
            <rect x="54" y="34" width="3" height="64" className="barcode-bar" />
            <rect x="61" y="34" width="6" height="64" className="barcode-bar" />
            <rect x="71" y="34" width="10" height="64" className="barcode-bar" />
            <rect x="85" y="34" width="3" height="64" className="barcode-bar" />
            <rect x="92" y="34" width="6" height="64" className="barcode-bar" />
            <rect x="102" y="34" width="6" height="64" className="barcode-bar" />
          </g>

          {/* Bottom Barcode Digital Data Markings */}
          <g fill="white" className="barcode-data">
            <rect x="34" y="102" width="12" height="4" />
            <rect x="52" y="102" width="8" height="4" />
            <rect x="66" y="102" width="16" height="4" />
            <rect x="88" y="102" width="6" height="4" />
            <rect x="98" y="102" width="10" height="4" />
          </g>
        </g>

        {/* Pie Chart (Transforms from the Barcode on scroll) */}
        <g className="pie-chart-group">
          {/* Main Base Pie Chart Body (Left and Lower Slices) */}
          <g fill="white" className="pie-body">
            {/* Circular pixel outline / blocks for lower-left 3/4 */}
            <rect x="42" y="32" width="28" height="10" />
            <rect x="30" y="42" width="40" height="10" />
            <rect x="22" y="52" width="48" height="10" />
            <rect x="18" y="62" width="52" height="16" />
            <rect x="22" y="78" width="48" height="12" />
            <rect x="28" y="90" width="42" height="10" />
            <rect x="38" y="100" width="32" height="10" />
            <rect x="50" y="110" width="20" height="8" />

            {/* Lower-Right slice quadrant */}
            <rect x="70" y="70" width="38" height="10" />
            <rect x="70" y="80" width="34" height="10" />
            <rect x="70" y="90" width="26" height="10" />
            <rect x="70" y="100" width="16" height="10" />
          </g>

          {/* Separated Top-Right Pie Slice (Exploded Accent Slice) */}
          <g fill="white" className="pie-slice">
            <rect x="76" y="24" width="22" height="8" />
            <rect x="76" y="32" width="32" height="10" />
            <rect x="76" y="42" width="38" height="10" />
            <rect x="76" y="52" width="34" height="10" />
            <rect x="76" y="62" width="24" height="8" />
          </g>
        </g>
      </svg>
    </div>
  );
}
