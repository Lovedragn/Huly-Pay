"use client";

import Image from "next/image";
import Link from "next/link";
import { useState, useEffect, useRef } from "react";
import gsap from "gsap";

function NavLink({ href, label, icon, isFirst = false }) {
  const lineRef = useRef(null);

  useEffect(() => {
    if (lineRef.current) {
      gsap.set(lineRef.current, { xPercent: -100, x: 0 });
    }
  }, []);

  const handleMouseEnter = () => {
    if (!lineRef.current) return;
    gsap.killTweensOf(lineRef.current);
    gsap.fromTo(
      lineRef.current,
      { xPercent: -100, x: 0 },
      { xPercent: 0, x: 0, duration: 0.32, ease: "power2.out" },
    );
  };

  const handleMouseLeave = () => {
    if (!lineRef.current) return;
    gsap.killTweensOf(lineRef.current);
    gsap.to(lineRef.current, {
      xPercent: 100,
      x: 0,
      duration: 0.28,
      ease: "power2.in",
      onComplete: () => {
        if (lineRef.current) {
          gsap.set(lineRef.current, { xPercent: -100, x: 0 });
        }
      },
    });
  };

  return (
    <Link
      href={href}
      prefetch={false}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      className={`group h-full flex items-center justify-center gap-2 px-6 lg:px-8 xl:px-10 border-r border-[#D4D4D8] ${
        isFirst ? "border-l" : ""
      } font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none`}
    >
      <span className="relative inline-block leading-none">
        <span>{label}</span>
        {/* Animated Underline: starts from left, kept while hovering, ends to right on leave */}
        <span
          className="absolute -bottom-[2px] left-0 w-full h-[2px] overflow-hidden pointer-events-none"
          aria-hidden="true"
        >
          <span ref={lineRef} className="block w-full h-full bg-[#000000]" />
        </span>
      </span>
      {icon}
    </Link>
  );
}

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isVisible, setIsVisible] = useState(true);
  const headerRef = useRef(null);
  const lastScrollY = useRef(0);
  const isFirstRender = useRef(true);

  // Synchronize scroll position and determine hide/show direction
  useEffect(() => {
    lastScrollY.current = window.scrollY;

    const handleScroll = () => {
      const currentScrollY = window.scrollY;

      // Always show navbar at the very top of the page
      if (currentScrollY <= 20) {
        setIsVisible(true);
        lastScrollY.current = Math.max(0, currentScrollY);
        return;
      }

      // Do not hide if mobile menu is currently expanded
      if (mobileMenuOpen) {
        lastScrollY.current = currentScrollY;
        return;
      }

      // Safeguard against bottom rubber-band overscroll
      const maxScroll =
        document.documentElement.scrollHeight - window.innerHeight;
      if (currentScrollY >= maxScroll - 10) {
        return;
      }

      const diff = currentScrollY - lastScrollY.current;

      // Threshold to prevent micro-jitter from small scroll steps
      if (Math.abs(diff) < 8) return;

      if (diff > 0) {
        // Scrolling Down -> smoothly slide up and hide
        setIsVisible(false);
      } else {
        // Scrolling Up -> smoothly slide down and reveal
        setIsVisible(true);
      }

      lastScrollY.current = currentScrollY;
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, [mobileMenuOpen]);

  // Smooth GSAP slide animation on visibility change
  useEffect(() => {
    if (!headerRef.current) return;

    // Avoid animating on first mount
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }

    if (isVisible) {
      gsap.to(headerRef.current, {
        yPercent: 0,
        y: 0,
        duration: 0.9,
        ease: "power2.out",
        overwrite: "auto",
      });
    } else {
      gsap.to(headerRef.current, {
        yPercent: -100,
        y: -4,
        duration: 0.9,
        ease: "power2.out",
        overwrite: "auto",
      });
    }
  }, [isVisible]);

  return (
    <>
      {/* Navbar: fixed at top with smooth GSAP slide animation */}
      <header
        ref={headerRef}
        className="w-full bg-white border-b border-[#D4D4D8] fixed top-0 left-0 z-50 will-change-transform"
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
            <NavLink href="#portfolio" label="Portfolio" isFirst />
            <NavLink
              href="#blogs"
              label="Blogs"
              icon={
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
              }
            />
            <NavLink
              href="#download"
              label="Download"
              icon={
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
              }
            />
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
