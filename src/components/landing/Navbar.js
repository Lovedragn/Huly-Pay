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
        <div className="w-full pl-4 sm:pl-8 lg:pl-16 pr-0 h-20 md:h-[80px] flex items-center justify-between">
          {/* Left Section: Logo, Blogs, Download */}
          <div className="flex items-center h-full">
            {/* Logo + Brand Name */}
            <Link
              href="/"
              className="h-full flex items-center gap-3 pr-6 sm:pr-8 md:pr-10 border-r border-[#D4D4D8] hover:opacity-85 transition-opacity"
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
              <span className="font-pixel text-lg sm:text-xl font-bold tracking-wider text-black select-none">
                HULYPAY
              </span>
            </Link>

            {/* Navigation Links (Desktop) */}
            <div className="hidden md:flex items-center h-full">
              <Link
                href="#blogs"
                className="h-full flex items-center justify-center px-8 lg:px-10 border-r border-[#D4D4D8] font-pixel text-sm sm:text-base text-black hover:bg-neutral-50 transition-colors select-none"
              >
                Blogs
              </Link>
              <Link
                href="#download"
                className="h-full flex items-center justify-center px-8 lg:px-10 border-r border-[#D4D4D8] font-pixel text-sm sm:text-base text-black hover:bg-neutral-50 transition-colors select-none"
              >
                Download
              </Link>
            </div>
          </div>

          {/* Right Section: Mobile menu toggle, DashBoard, Open Link Icon */}
          <div className="flex items-center h-full">
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

            {/* Dashboard Link */}
            <Link
              href="/dashboard"
              className="h-full flex items-center justify-center px-6 sm:px-8 lg:px-10 border-l border-r border-[#D4D4D8] font-pixel text-sm sm:text-base text-black hover:bg-neutral-50 transition-colors select-none"
            >
              DashBoard
            </Link>

            {/* Open Link Box (Solid Black Square extending flush to the right edge) */}
            <Link
              href="/dashboard"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Open Dashboard in new tab"
              className="h-full w-16 sm:w-20 md:w-[80px] bg-black flex items-center justify-center cursor-pointer"
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 17 17"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M16 12V16H1V1H5M6 11L16 1M16 8V1H9"
                  stroke="white"
                  strokeWidth="2"
                  strokeLinejoin="round"
                />
              </svg>
            </Link>
          </div>
        </div>

        {/* Mobile Drawer Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-[#D4D4D8] bg-white px-6 py-4 flex flex-col gap-4 font-pixel text-base">
            <Link
              href="#blogs"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 hover:text-neutral-600 transition-colors"
            >
              Blogs
            </Link>
            <Link
              href="#download"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 hover:text-neutral-600 transition-colors"
            >
              Download
            </Link>
            <Link
              href="/dashboard"
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 hover:text-neutral-600 transition-colors"
            >
              DashBoard
            </Link>
          </div>
        )}
      </header>

      {/* Static Spacer to prevent page jumping when navbar hides/shows */}
      <div className="w-full h-20 md:h-[80px]" aria-hidden="true" />
    </>
  );
}
