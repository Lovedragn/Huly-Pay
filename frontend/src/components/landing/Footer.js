import Image from "next/image";
import Link from "next/link";
import { EXTERNAL_LINKS } from "../../assets/external_data";

export default function Footer() {
  return (
    <footer className="w-full bg-black text-white overflow-hidden selection:bg-neutral-800 selection:text-white">
      <div className="w-full max-w-[1920px] mx-auto px-4 sm:px-8 md:px-12 lg:px-16 xl:px-[136px] pt-12 sm:pt-16 lg:pt-[120px] pb-8 sm:pb-10 lg:pb-[38px] flex flex-col justify-between">
        {/* Top Section: Pixel-Perfect Brand Lockup (Logo + HULYPAY) - Scales smoothly without overflow */}
        <div className="w-full flex items-center justify-start select-none">
          <Image
            src="/assets/footer_brand_lockup.png"
            alt="HulyPay Logo and Brand"
            width={1664}
            height={298}
            priority
            className="w-full h-auto object-contain max-w-[1664px]"
          />
          <h2 className="sr-only">HulyPay</h2>
        </div>

        {/* Bottom Section: Links & Social Icons */}
        <div className="w-full mt-10 sm:mt-14 lg:mt-[94px] flex flex-row items-center justify-between gap-4 border-t border-neutral-900/60 sm:border-t-0 pt-6 sm:pt-0">
          {/* Left: Privacy & Terms */}
          <div className="font-pixel text-[13px] sm:text-[14px] text-white">
            <Link
              href={EXTERNAL_LINKS.nav.privacyTerms}
              className="hover:text-neutral-400 transition-colors select-none whitespace-nowrap"
            >
              Privacy &amp; Terms
            </Link>
          </div>

          {/* Right: GitHub, LinkedIn, External Link to Personal Portfolio */}
          <div className="flex items-center gap-5 sm:gap-7 lg:gap-[36px]">
            {/* GitHub */}
            <a
              href={EXTERNAL_LINKS.social.github}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="GitHub Profile"
              className="text-white hover:opacity-75 hover:scale-110 transition-all select-none flex items-center justify-center"
            >
              <Image
                src="/assets/github.svg"
                alt="GitHub"
                width={18}
                height={18}
                className="w-4 h-4 sm:w-[18px] sm:h-[18px] object-contain"
              />
            </a>

            {/* LinkedIn */}
            <a
              href={EXTERNAL_LINKS.social.linkedin}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="LinkedIn Profile"
              className="text-white hover:opacity-75 hover:scale-110 transition-all select-none flex items-center justify-center"
            >
              <Image
                src="/assets/linkedin.svg"
                alt="LinkedIn"
                width={17}
                height={17}
                className="w-4 h-4 sm:w-[17px] sm:h-[17px] object-contain"
              />
            </a>

            {/* Open Personal Portfolio Link */}
            <a
              href={EXTERNAL_LINKS.social.personal_portfolio}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Personal Portfolio"
              className="text-white hover:opacity-75 hover:scale-110 transition-all select-none flex items-center justify-center"
            >
              <Image
                src="/assets/Open_Link.svg"
                alt="Open Link"
                width={15}
                height={15}
                className="w-3.5 h-3.5 sm:w-[15px] sm:h-[15px] object-contain"
              />
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
