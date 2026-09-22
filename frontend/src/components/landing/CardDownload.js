"use client";

export default function CardDownload() {
  const ribbonPath =
    "M4.5 37.0083C4.5 37.0083 115.797 261.092 653.895 171.366C657.211 170.814 660.715 170.508 664.077 170.508C910.693 170.508 1107.07 170.508 1262.5 170.508C1752.5 194.508 1918.5 495.008 1918.5 495.008";

  return (
    <section
      id="download"
      className="w-full bg-[#FFFFEB] relative overflow-hidden py-14 sm:py-20 lg:py-0 lg:h-[851px]"
    >
      <div className="relative w-full max-w-[1920px] mx-auto h-full flex flex-col justify-between lg:block">
        {/* Top-Left Heading */}
        <div className="px-6 sm:px-12 md:px-16 lg:px-0 lg:absolute lg:top-[105px] lg:left-[105px] z-20 select-none mb-8 sm:mb-12 lg:mb-0">
          <h2 className="font-pixel text-3xl sm:text-5xl md:text-6xl lg:text-[68px] font-bold text-black leading-[1.12] tracking-wide">
            Ready to take control{" "}
            <br className="hidden sm:inline" />
            of your money?
          </h2>
        </div>

        {/* Full-width Canvas SVG Ribbon */}
        <div className="absolute inset-0 w-full h-full flex items-center justify-center pointer-events-none select-none z-10 overflow-hidden">
          <svg
            viewBox="0 0 1920 851"
            className="w-[1400px] sm:w-[1700px] lg:w-full h-full pointer-events-none select-none"
            preserveAspectRatio="xMidYMid slice"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              {/* Translated Path aligned with the 1920x851 canvas coordinate grid */}
              <path
                id="canvasRibbonPath"
                d={ribbonPath}
                transform="translate(0, 293)"
              />
            </defs>

            {/* Black Ribbon Stroke (width: 74px) */}
            <use
              href="#canvasRibbonPath"
              stroke="black"
              strokeWidth="74"
              strokeLinecap="round"
              fill="none"
            />

            {/* Left Side: Unencrypted transaction amounts entering the application card */}
            <text
              fill="white"
              fontFamily="var(--font-pixelify), monospace, sans-serif"
              fontSize="24"
              fontWeight="700"
              letterSpacing="2"
              dominantBaseline="central"
            >
              <textPath href="#canvasRibbonPath" startOffset="0.2%">
                ₹23,000, ₹324, ₹10,000,000, ₹90
              </textPath>
            </text>

            {/* Right Side: Encrypted symbols exiting from behind the card */}
            <text
              fill="white"
              fontFamily="var(--font-pixelify), monospace, sans-serif"
              fontSize="24"
              fontWeight="700"
              letterSpacing="2.5"
              dominantBaseline="central"
            >
              <textPath href="#canvasRibbonPath" startOffset="63.5%">
                *&amp;@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#&amp;*@#
              </textPath>
            </text>
          </svg>
        </div>

        {/* Center Application Red Card */}
        <div className="relative z-20 mx-auto w-[92%] max-w-[420px] sm:max-w-[520px] lg:max-w-none lg:absolute lg:top-[380px] lg:left-1/2 lg:-translate-x-1/2 lg:w-[596px] lg:h-[356px] bg-[#FF0000] rounded-[24px] sm:rounded-[32px] p-4 sm:p-5 lg:p-0 shadow-2xl flex flex-col justify-between lg:block">
          {/* Top White Box */}
          <div className="w-full lg:absolute lg:top-[39px] lg:left-[13px] lg:right-[12px] lg:w-[571px] h-14 sm:h-16 lg:h-[72px] bg-white rounded-[8px] flex items-center pl-4 sm:pl-6 lg:pl-[27px] shadow-sm">
            <h3 className="font-doto font-bolder font-black text-2xl sm:text-3xl lg:text-[46px] text-[#FF0000] tracking-wider leading-none select-none">
              Application
            </h3>
          </div>

          {/* Supported Device List */}
          <div className="mt-4 sm:mt-5 lg:mt-0 lg:absolute lg:top-[129px] lg:left-[70px] select-none">
            <p className="font-pixel text-xs sm:text-sm lg:text-[15px] font-medium text-white mb-1 sm:mb-1.5">
              Suppported Device:
            </p>
            <ul className="space-y-1 pl-4 sm:pl-6 lg:pl-[51px]">
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 bg-white flex-shrink-0" />
                <span className="font-pixel text-xs sm:text-sm lg:text-[15px] text-white">
                  APK
                </span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 bg-white flex-shrink-0" />
                <span className="font-pixel text-xs sm:text-sm lg:text-[15px] text-white">
                  IOS
                </span>
              </li>
            </ul>
          </div>

          {/* Download Action Pill Button */}
          <div className="mt-6 sm:mt-8 lg:mt-0 lg:absolute lg:bottom-[47px] lg:left-1/2 lg:-translate-x-1/2 flex justify-center w-full lg:w-auto">
            <a
              href="#download-app"
              className="w-full max-w-[280px] sm:max-w-[340px] lg:w-[372px] h-12 sm:h-14 lg:h-[57px] bg-white hover:bg-neutral-100 rounded-full flex items-center justify-center font-pixel text-base sm:text-lg lg:text-[20px] font-bold text-[#FF0000] tracking-wider transition-colors shadow-md select-none cursor-pointer"
            >
              DOWNLOAD
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
