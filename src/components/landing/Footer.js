import Image from "next/image";
import Link from "next/link";
import { EXTERNAL_LINKS } from "./external_data";

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
        <div className="w-full mt-10 sm:mt-14 lg:mt-[94px] flex flex-col sm:flex-row items-center justify-between gap-6 sm:gap-4 border-t border-neutral-900/60 sm:border-t-0 pt-6 sm:pt-0">
          {/* Left: @HulyPay, Portfolio, Privacy, Terms */}
          <div className="flex items-center gap-6 sm:gap-8 md:gap-10 lg:gap-14 font-pixel text-[14px] text-white">
            <Link
              href={EXTERNAL_LINKS.social.twitter}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-neutral-400 transition-colors select-none"
            >
              <span className="text-[17px] inline-block align-baseline">@</span>
              HulyPay
            </Link>
            <a
              href={EXTERNAL_LINKS.social.personal_portfolio}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-neutral-400 transition-colors select-none"
            >
              Portfolio
            </a>
            <Link
              href={EXTERNAL_LINKS.nav.privacy}
              className="hover:text-neutral-400 transition-colors select-none"
            >
              Privacy
            </Link>
            <Link
              href={EXTERNAL_LINKS.nav.terms}
              className="hover:text-neutral-400 transition-colors select-none"
            >
              Terms
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
              className="text-white hover:text-neutral-400 hover:scale-110 transition-all select-none"
            >
              <svg
                className="w-4 h-4 sm:w-[18px] sm:h-[18px]"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                />
              </svg>
            </a>

            {/* LinkedIn */}
            <a
              href={EXTERNAL_LINKS.social.linkedin}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="LinkedIn Profile"
              className="text-white hover:text-neutral-400 hover:scale-110 transition-all select-none"
            >
              <svg
                className="w-4 h-4 sm:w-[17px] sm:h-[17px]"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.88 8.56a1.68 1.68 0 0 0 1.68-1.68c0-.93-.75-1.69-1.68-1.69a1.69 1.69 0 0 0-1.69 1.69c0 .93.76 1.68 1.69 1.68m1.39 9.94v-8.37H5.5v8.37h2.77z" />
              </svg>
            </a>

            {/* Open Personal Portfolio Link */}
            <a
              href={EXTERNAL_LINKS.social.personal_portfolio}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Personal Portfolio"
              className="text-white hover:text-neutral-400 hover:scale-110 transition-all select-none"
            >
              <svg
                className="w-3.5 h-3.5 sm:w-[15px] sm:h-[15px] overflow-visible"
                viewBox="-1 -1 19 19"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M16 12V16H1V1H5M6 11L16 1M16 8V1H9"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
