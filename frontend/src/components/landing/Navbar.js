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
        {/* Outer wrapper: flush edges with equal left and right sections */}
        <div className="w-full px-0 h-20 md:h-[80px] flex items-center justify-between relative">
          {/* Left Section: Logo + Brand Name (equal length to right dashboard button) */}
          <div className="flex items-center h-full z-10 w-[180px] sm:w-[200px] md:w-[220px]">
            <Link
              href="/"
              className="h-full w-full flex items-center justify-center gap-3 hover:opacity-85 transition-opacity px-4 sm:px-6"
            >
              <div className="w-7 h-7 relative flex items-center justify-center shrink-0">
                <Image
                  src="/assets/logo-Light.svg"
                  alt="Huly Pay Logo"
                  width={28}
                  height={28}
                  priority
                  className="w-7 h-7 object-contain"
                />
              </div>
              <span className="font-pixel text-lg sm:text-xl tracking-wider text-black select-none whitespace-nowrap">
                HULYPAY
              </span>
            </Link>
          </div>

          {/* Center Section: Navigation Links (Portfolio | Blogs v | Download v) */}
          <div className="hidden md:flex items-center h-full absolute left-1/2 -translate-x-1/2">
            <Link
              href="#portfolio"
              className="h-full flex items-center justify-center px-6 lg:px-8 xl:px-10 border-l border-r border-[#D4D4D8] font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none"
            >
              Portfolio
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

            {/* Open Dashboard Link Box (Solid Black Button matching left section length) */}
            <Link
              href="/dashboard"
              aria-label="Open Dashboard"
              className="h-full w-[180px] sm:w-[200px] md:w-[220px] bg-black flex items-center justify-center gap-2 cursor-pointer hover:bg-neutral-900 transition-colors select-none"
            >
              <span className="font-pixel text-[14px] text-white tracking-wider whitespace-nowrap">
                DashBoard
              </span>
              <Image
                src="/assets/Open_Link.svg"
                alt="Open Link"
                width={10}
                height={10}
                className="w-[10px] h-[10px] object-contain shrink-0"
              />
            </Link>
          </div>
        </div>

        {/* Mobile Drawer Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-[#D4D4D8] bg-white px-6 py-4 flex flex-col gap-4 font-pixel text-[14px]">
            <Link
              href="#portfolio"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 hover:text-neutral-600 transition-colors"
            >
              Portfolio
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
