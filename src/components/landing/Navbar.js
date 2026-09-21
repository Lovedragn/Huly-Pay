"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="w-full bg-white border-b border-[#D4D4D8] sticky top-0 z-50">
      {/* Outer wrapper matching the margins from the design */}
      <div className="max-w-[1720px] mx-auto px-4 sm:px-8 lg:px-16 h-20 md:h-[90px] flex items-center justify-between">
        
        {/* Left Section: Logo, Blogs, Download */}
        <div className="flex items-center h-full">
          {/* Logo + Brand Name */}
          <Link
            href="/landing"
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

        {/* Right Section: DashBoard, Open Link Icon */}
        <div className="flex items-center h-full">
          {/* Dashboard Link */}
          <Link
            href="/landing/dashboard"
            className="h-full flex items-center justify-center px-6 sm:px-8 lg:px-10 border-l border-r border-[#D4D4D8] font-pixel text-sm sm:text-base text-black hover:bg-neutral-50 transition-colors select-none"
          >
            DashBoard
          </Link>

          {/* Open Link Box (Solid Black Square) */}
          <Link
            href="/landing/dashboard"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Open Dashboard in new tab"
            className="h-full w-16 sm:w-20 md:w-[90px] bg-black flex items-center justify-center hover:bg-neutral-800 active:bg-neutral-900 transition-colors group cursor-pointer"
          >
            <svg
              width="18"
              height="18"
              viewBox="0 0 17 17"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="transition-transform duration-200 group-hover:scale-110 group-hover:-translate-y-0.5 group-hover:translate-x-0.5"
            >
              <path
                d="M16 12V16H1V1H5M6 11L16 1M16 8V1H9"
                stroke="white"
                strokeWidth="2"
                strokeLinejoin="round"
              />
            </svg>
          </Link>

          {/* Mobile Menu Button (Visible only on small screens) */}
          <button
            type="button"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden ml-3 p-2 text-black hover:bg-neutral-100 rounded focus:outline-none"
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
            href="/landing/dashboard"
            onClick={() => setMobileMenuOpen(false)}
            className="py-2 hover:text-neutral-600 transition-colors"
          >
            DashBoard
          </Link>
        </div>
      )}
    </header>
  );
}
