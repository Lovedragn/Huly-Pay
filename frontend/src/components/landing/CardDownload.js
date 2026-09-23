"use client";

import VeinTextFlow from "../../../public/assets/download/VeinTextFlow";
import { EXTERNAL_LINKS } from "../../assets/external_data";

export default function CardDownload() {
  return (
    <section
      id="download"
      className="w-full bg-[#FFFFEB] relative overflow-x-clip pt-4 pb-12 sm:pb-16 lg:pb-20"
    >
      {/* Full-width SVG path spanning from window corner to corner */}
      <VeinTextFlow />

      <div className="relative w-full max-w-[1550px] mx-auto flex flex-col px-6 sm:px-12 md:px-16 xl:px-[105px] mt-2 sm:mt-4">
        {/* Top-Left Heading */}
        <div className="select-none mb-8 sm:mb-10 lg:mb-14">
          <h2 className="font-pixel text-3xl sm:text-5xl md:text-6xl lg:text-[64px] text-black leading-[1.12] tracking-wide">
            Ready to take control <br className="hidden sm:inline" />
            of your money?
          </h2>
        </div>

        {/* Download Platform Cards Container */}
        <div className="w-full flex flex-col lg:flex-row items-center justify-center gap-6 lg:gap-10 xl:gap-14">
          {/* Card 1: Android & Dev Platforms (Red) */}
          <div className="relative w-full max-w-[460px] h-[235px] sm:h-[250px] bg-[#FF0000] border-[8px] border-[#B30003] rounded-[20px] sm:rounded-[24px] p-5 sm:p-6 flex flex-col justify-between select-none shadow-xl transition-all duration-200 hover:-translate-y-1 hover:shadow-2xl">
            {/* Header Title (Dot-Matrix Font - Bold/Black) */}
            <div>
              <h3 className="font-doto font-bolder font-black text-2xl sm:text-3xl lg:text-[34px] text-white tracking-wider leading-none">
                ANDROID
              </h3>
            </div>

            {/* Description Text (Bolder Pixel Font) */}
            <div className="my-auto">
              <p className="font-pixel font-bold text-xs sm:text-sm lg:text-[15px] text-white leading-[1.3] tracking-wide">
                For Android Phone, Windows, Non-macos
                <br />
                Laptops &amp; Much more Dev Enviroment.
              </p>
            </div>

            {/* Action Pill Button */}
            <div className="w-full flex justify-center">
              <a
                href={EXTERNAL_LINKS.downloads.androidApk}
                target=""
                rel="noopener noreferrer"
                download={EXTERNAL_LINKS.downloads.apkFilename}
                className="w-full max-w-[290px] h-[42px] sm:h-[46px] bg-white rounded-full flex items-center justify-center font-pixel font-bolder font-black text-sm sm:text-base text-[#FF0000] tracking-wider shadow-md hover:bg-neutral-100 hover:scale-[1.02] active:scale-[0.98] transition-all cursor-pointer select-none"
              >
                DOWNLOAD
              </a>
            </div>
          </div>

          {/* Card 2: iOS & Apple Platform (Black) */}
          <div className="relative w-full max-w-[460px] h-[235px] sm:h-[250px] bg-black border-[8px] border-[#666666] rounded-[20px] sm:rounded-[24px] p-5 sm:p-6 flex flex-col justify-between select-none shadow-xl transition-all duration-200 hover:-translate-y-1 hover:shadow-2xl">
            {/* Header Title (Dot-Matrix Font - Bold/Black) */}
            <div>
              <h3 className="font-doto font-bolder font-black text-2xl sm:text-3xl lg:text-[34px] text-white tracking-wider leading-none">
                IOS
              </h3>
            </div>

            {/* Description Text (Bolder Pixel Font) */}
            <div className="my-auto">
              <p className="font-pixel font-bold text-xs sm:text-sm lg:text-[15px] text-white leading-[1.3] tracking-wide">
                For IPhone, MacOS &amp; Apple Enviroment.
              </p>
            </div>

            {/* Action Pill Button */}
            <div className="w-full flex justify-center">
              <button
                type="button"
                disabled
                className="w-full max-w-[290px] h-[42px] sm:h-[46px] bg-white/90 rounded-full flex items-center justify-center font-pixel font-bolder font-black text-xs sm:text-sm text-black tracking-wider shadow-md opacity-80 cursor-not-allowed select-none"
              >
                COMING SOON
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
