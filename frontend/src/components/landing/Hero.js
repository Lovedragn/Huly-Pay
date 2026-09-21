"use client";

import Image from "next/image";

export default function Hero() {
  const scrollToNext = () => {
    const workflowSection = document.getElementById("workflow");
    if (workflowSection) {
      workflowSection.scrollIntoView({ behavior: "smooth" });
    }
  };

  return (
    <section id="hero" className="relative w-full bg-white pt-10 sm:pt-14 md:pt-16">
      {/* Sticky Floating Action Button (Bottom Left, visible on load, floats gently, sticks until Hero scrolls out) */}
      <div className="absolute inset-y-0 left-4 sm:left-8 lg:left-14 w-14 pointer-events-none z-30">
        <div className="sticky top-[calc(100vh-80px)] sm:top-[calc(100vh-90px)] md:top-[calc(100vh-100px)] pointer-events-auto">
          <button
            type="button"
            onClick={scrollToNext}
            aria-label="Scroll down to workflow"
            className="animate-float w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-[#111111] flex items-center justify-center cursor-pointer shadow-xl shadow-black/25"
          >
            <Image
              src="/assets/arrow_back.svg"
              alt="Scroll down"
              width={16}
              height={10}
              className="w-4 h-2.5 object-contain"
            />
          </button>
        </div>
      </div>

      {/* Title */}
      <div className="w-full flex justify-center px-4">
        <h1 className="font-pixel text-4xl sm:text-6xl md:text-7xl lg:text-[88px] xl:text-[96px] font-bold tracking-[0.14em] sm:tracking-[0.2em] text-black text-center select-none uppercase">
          PAY<span className="text-[#E53E3E]">.</span>TRACK<span className="text-[#E53E3E]">.</span>GROW
        </h1>
      </div>

      {/* Main Showcase Container (Phones reduced by 30%) */}
      <div className="relative max-w-[1720px] mx-auto px-4 sm:px-8 lg:px-16 mt-6 sm:mt-10 md:mt-12 overflow-hidden">
        {/* 3 iPhone Mockups Staggered Display */}
        <div className="flex items-start justify-center gap-3 sm:gap-6 md:gap-8 lg:gap-12 w-full">
          
          {/* Left iPhone (30% reduced size) */}
          <div className="w-[126px] sm:w-[160px] md:w-[190px] lg:w-[205px] mt-8 sm:mt-12 md:mt-16 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_left.svg"
              alt="Huly Pay iPhone Left View"
              width={205}
              height={485}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Middle iPhone (Highest, Center Stage, 30% reduced size) */}
          <div className="w-[140px] sm:w-[182px] md:w-[220px] lg:w-[235px] mt-0 z-10 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_middle.svg"
              alt="Huly Pay iPhone Dashboard View"
              width={235}
              height={454}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

          {/* Right iPhone (30% reduced size) */}
          <div className="w-[126px] sm:w-[160px] md:w-[195px] lg:w-[210px] mt-12 sm:mt-16 md:mt-24 flex-shrink-0">
            <Image
              src="/assets/hero_mock_iphone_right.svg"
              alt="Huly Pay iPhone Insights View"
              width={210}
              height={485}
              priority
              className="w-full h-auto object-contain select-none pointer-events-none"
            />
          </div>

        </div>
      </div>
    </section>
  );
}
