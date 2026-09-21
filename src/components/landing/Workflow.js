"use client";

import Image from "next/image";

export default function Workflow() {
  return (
    <section id="workflow" className="relative w-full bg-black text-white py-24 sm:py-32 lg:py-40 overflow-hidden">
      <div className="relative max-w-[1720px] mx-auto px-6 sm:px-12 lg:px-24">
        
        {/* Header Section */}
        <div className="mb-20 sm:mb-28 lg:mb-36">
          <div className="flex items-start gap-3 sm:gap-4">
            {/* Vertical YOUR */}
            <span
              className="font-pixel text-xl sm:text-2xl lg:text-3xl font-bold text-[#FF0000] tracking-widest uppercase select-none leading-none pt-1"
              style={{ writingMode: "vertical-rl", textOrientation: "upright" }}
            >
              YOUR
            </span>

            {/* Money Control */}
            <div className="flex flex-col">
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-8xl font-bold text-white tracking-wider leading-none select-none">
                Money
              </h2>
              <h2 className="font-pixel text-5xl sm:text-7xl lg:text-8xl font-bold text-white tracking-wider leading-none select-none mt-2 sm:mt-3">
                Control
              </h2>
            </div>
          </div>

          {/* Subtitle */}
          <p className="font-pixel text-xs sm:text-sm lg:text-base text-[#D4D4D8] tracking-wide mt-6 max-w-2xl leading-relaxed">
            HulyPay An open-source payment and expense tracking platform built to help anyone pay, track, and understand their money.
          </p>
        </div>

        {/* Workflow Interactive Roadmap */}
        <div className="relative w-full">

          {/* S-CURVE 1 (Connecting Step 1 to Step 2) - Desktop & Large Screens */}
          <div className="hidden lg:block absolute left-[18%] right-[12%] top-[140px] pointer-events-none z-0">
            <svg
              viewBox="0 0 892 229"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="w-full h-auto"
            >
              <path
                d="M2.50098 2.50073C2.50098 2.50073 101.163 236.829 445.751 114.251C810.501 -15.4993 889.001 226.001 889.001 226.001"
                stroke="white"
                strokeWidth="5"
                strokeLinecap="round"
              />
            </svg>
          </div>

          {/* S-CURVE 2 (Connecting Step 2 to Step 3) - Desktop & Large Screens */}
          <div className="hidden lg:block absolute left-[18%] right-[12%] top-[570px] pointer-events-none z-0">
            <svg
              viewBox="0 0 924 123"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="w-full h-auto"
            >
              <path
                d="M921.5 2.50073C921.5 2.50073 844 178.356 437 61.5007C30 -55.355 2.5 120.501 2.5 120.501"
                stroke="white"
                strokeWidth="5"
                strokeLinecap="round"
              />
            </svg>
          </div>

          {/* STEP 1: QR Badge on Left, 2X Text on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12 mb-28 sm:mb-36 lg:mb-48">
            {/* Left Badge: QR Scanner */}
            <div className="lg:col-span-5 flex justify-start lg:pl-6">
              <div className="w-[180px] sm:w-[220px] lg:w-[250px] relative">
                <Image
                  src="/assets/Frame 145.svg"
                  alt="Scan QR Badge"
                  width={323}
                  height={357}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>

            {/* Right Text: 2X Times Scan QR to pay */}
            <div className="lg:col-span-7 flex items-center justify-start lg:pl-8">
              <div className="flex items-center gap-4 sm:gap-6">
                {/* 2X Graphic */}
                <div className="flex flex-col items-center justify-center font-pixel leading-none select-none">
                  <span className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white tracking-tighter">
                    2
                  </span>
                  <span className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#62D800] -mt-1 sm:-mt-2">
                    X
                  </span>
                </div>

                {/* Description Lines */}
                <div className="flex flex-col font-pixel text-xl sm:text-2xl lg:text-3xl font-semibold text-[#D4D4D8] tracking-wide leading-snug select-none">
                  <span>Times Scan QR to pay</span>
                  <span>Faster Tracking</span>
                </div>
              </div>
            </div>
          </div>

          {/* STEP 2: Secure Text on Left, Chevron Badge on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12 mb-28 sm:mb-36 lg:mb-48">
            {/* Left Text: Keep your transactions (Secure) & Expenses Organized. */}
            <div className="order-2 lg:order-1 lg:col-span-7 flex justify-start lg:justify-end lg:pr-12">
              <p className="font-pixel text-2xl sm:text-3xl lg:text-4xl font-semibold text-[#D4D4D8] tracking-wide leading-snug max-w-xl select-none">
                Keep your transactions{" "}
                <span className="text-[#D8FF00] font-bold">(Secure)</span> &amp;
                Expenses Organized.
              </p>
            </div>

            {/* Right Badge: Down Chevrons */}
            <div className="order-1 lg:order-2 lg:col-span-5 flex justify-start lg:justify-end lg:pr-6">
              <div className="w-[180px] sm:w-[220px] lg:w-[250px] relative">
                <Image
                  src="/assets/Frame 143.svg"
                  alt="Secure Transactions Badge"
                  width={248}
                  height={299}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>
          </div>

          {/* STEP 3: Shield Badge on Left, Visual Data Text on Right */}
          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 items-center gap-8 lg:gap-12">
            {/* Left Badge: Star Shield */}
            <div className="lg:col-span-5 flex justify-start lg:pl-6">
              <div className="w-[180px] sm:w-[220px] lg:w-[250px] relative">
                <Image
                  src="/assets/Frame 144.svg"
                  alt="Visual Data Sparkle Shield"
                  width={309}
                  height={342}
                  className="w-full h-auto object-contain select-none"
                />
              </div>
            </div>

            {/* Right Text: Turn your spending into useful Visual Data. */}
            <div className="lg:col-span-7 flex justify-start lg:pl-8">
              <p className="font-pixel text-2xl sm:text-3xl lg:text-4xl font-semibold text-[#D4D4D8] tracking-wide leading-snug select-none">
                Turn your spending into useful{" "}
                <span className="text-[#FF00F5] font-bold">Visual</span> Data.
              </p>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
