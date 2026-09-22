"use client";

import Image from "next/image";
import Link from "next/link";
import { useState, useEffect, useRef } from "react";

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isVisible, setIsVisible] = useState(true);
  const lastScrollY = useRef(0);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;

      // Always show navbar at the very top of the page
      if (currentScrollY <= 10) {
        setIsVisible(true);
        lastScrollY.current = currentScrollY;
        return;
      }

      // Do not hide if mobile menu is currently expanded
      if (mobileMenuOpen) {
        lastScrollY.current = currentScrollY;
        return;
      }

      const diff = currentScrollY - lastScrollY.current;

      // Scroll Down -> Disappear
      if (diff > 5) {
        setIsVisible(false);
      }
      // Scroll Up (pull down) -> Reappear immediately
      else if (diff < -5) {
        setIsVisible(true);
      }

      lastScrollY.current = currentScrollY;
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, [mobileMenuOpen]);

  return (
    <>
      {/* Navbar: fixed at top, hides immediately on scroll down and reappears on scroll up without any animation */}
      <header
        className={`w-full bg-white border-b border-[#D4D4D8] fixed top-0 left-0 z-50 ${
          isVisible ? "block" : "hidden"
        }`}
      >
        {/* Outer wrapper: left has standard margin/padding, right extends flush to the edge (pr-0) */}
        <div className="w-full pl-6 sm:pl-10 lg:pl-16 xl:pl-24 pr-0 h-20 md:h-[80px] flex items-center justify-between relative">
          {/* Left Section: Logo + Brand Name (no right border, matching navbar.png) */}
          <div className="flex items-center h-full z-10">
            <Link
              href="/"
              className="h-full flex items-center gap-3 hover:opacity-85 transition-opacity"
            >
              <div className="w-7 h-7 relative flex items-center justify-center">
                <Image
                  src="/assets/logo-Light.svg"
                  alt="Huly Pay Logo"
                  width={28}
                  height={28}
                  priority
                  className="w-7 h-7 object-contain"
                />
              </div>
              <span className="font-pixel text-lg sm:text-xl tracking-wider text-black select-none">
                HULYPAY
              </span>
            </Link>
          </div>

          {/* Center Section: Navigation Links (DashBoard | Blogs v | Download v) */}
          <div className="hidden md:flex items-center h-full absolute left-1/2 -translate-x-1/2">
            <Link
              href="/dashboard"
              className="h-full flex items-center justify-center px-6 lg:px-8 xl:px-10 border-l border-r border-[#D4D4D8] font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none"
            >
              DashBoard
            </Link>
            <Link
              href="#blogs"
              className="group h-full flex items-center justify-center gap-2 px-6 lg:px-8 xl:px-10 border-r border-[#D4D4D8] font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none"
            >
              <span>Blogs</span>
              <svg
                className="w-2.5 h-1.5 text-black transition-transform duration-200 group-hover:translate-y-0.5"
                viewBox="0 0 10 6"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M1 1L5 5L9 1"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
            <Link
              href="#download"
              className="group h-full flex items-center justify-center gap-2 px-6 lg:px-8 xl:px-10 border-r border-[#D4D4D8] font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none"
            >
              <span>Download</span>
              <svg
                className="w-2.5 h-1.5 text-black transition-transform duration-200 group-hover:translate-y-0.5"
                viewBox="0 0 10 6"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M1 1L5 5L9 1"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
          </div>

          {/* Right Section: Mobile menu toggle + Open Link Box */}
          <div className="flex items-center h-full z-10">
            {/* Mobile Menu Button (Visible only on small screens) */}
            <button
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden mr-3 p-2 text-black hover:bg-neutral-100 rounded focus:outline-none"
              aria-label="Toggle navigation menu"
            >
              <svg
                className="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                {mobileMenuOpen ? (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                ) : (
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M4 6h16M4 12h16M4 18h16"
                  />
                )}
              </svg>
            </button>

            {/* Open Link Box (Solid Black Square extending flush to the right edge) */}
            <Link
              href="/dashboard"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Open Dashboard in new tab"
              className="h-full w-16 sm:w-20 md:w-24 lg:w-28 xl:w-36 bg-black flex items-center justify-center cursor-pointer hover:bg-neutral-900 transition-colors"
            >
              <svg
                width="15"
                height="15"
                viewBox="-1 -1 19 19"
                fill="none"
                className="overflow-visible"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M16 12V16H1V1H5M6 11L16 1M16 8V1H9"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
          </div>
        </div>

        {/* Mobile Drawer Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-[#D4D4D8] bg-white px-6 py-4 flex flex-col gap-4 font-pixel text-[14px]">
            <Link
              href="/dashboard"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 hover:text-neutral-600 transition-colors"
            >
              DashBoard
            </Link>
            <Link
              href="#blogs"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 flex items-center justify-between hover:text-neutral-600 transition-colors"
            >
              <span>Blogs</span>
              <svg
                className="w-2.5 h-1.5 text-black"
                viewBox="0 0 10 6"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M1 1L5 5L9 1"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
            <Link
              href="#download"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 flex items-center justify-between hover:text-neutral-600 transition-colors"
            >
              <span>Download</span>
              <svg
                className="w-2.5 h-1.5 text-black"
                viewBox="0 0 10 6"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M1 1L5 5L9 1"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
          </div>
        )}
      </header>

      {/* Static Spacer to prevent page jumping when navbar hides/shows */}
      <div className="w-full h-20 md:h-[80px]" aria-hidden="true" />
    </>
  );
}
