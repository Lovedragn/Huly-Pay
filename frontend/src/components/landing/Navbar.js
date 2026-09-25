"use client";

import Image from "next/image";
import Link from "next/link";
import { useState, useEffect, useRef } from "react";
import gsap from "gsap";
import { EXTERNAL_LINKS } from "../../assets/external_data";
import { NAV_BG_SVGS } from "@/assets";
import { useAuth } from "@/context/AuthContext";
import ThemeToggle from "@/components/ThemeToggle";

function NavLink({
  href,
  label,
  icon,
  isFirst = false,
  isActive = false,
  onMouseEnter,
  onMouseLeave,
  onClick,
}) {
  const lineRef = useRef(null);
  const [isHovered, setIsHovered] = useState(false);

  // The underline should be displayed when either the item is hovered or its dropdown is active
  const isHighlighted = isHovered || isActive;

  useEffect(() => {
    if (!lineRef.current) return;
    gsap.killTweensOf(lineRef.current);

    if (isHighlighted) {
      // Animate in from the left
      gsap.fromTo(
        lineRef.current,
        { xPercent: -100, x: 0 },
        { xPercent: 0, x: 0, duration: 0.28, ease: "power2.out" }
      );
    } else {
      // Slide out smoothly to the right, then reset position to left
      gsap.to(lineRef.current, {
        xPercent: 100,
        x: 0,
        duration: 0.2,
        ease: "power2.in",
        onComplete: () => {
          if (lineRef.current) {
            gsap.set(lineRef.current, { xPercent: -100, x: 0 });
          }
        },
      });
    }
  }, [isHighlighted]);

  const handleMouseEnter = (e) => {
    setIsHovered(true);
    onMouseEnter?.(e);
  };

  const handleMouseLeave = (e) => {
    setIsHovered(false);
    onMouseLeave?.(e);
  };

  const isExternal = href.startsWith("http");

  return (
    <Link
      href={href}
      prefetch={false}
      target={isExternal ? "_blank" : undefined}
      rel={isExternal ? "noopener noreferrer" : undefined}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      onClick={onClick}
      className={`group h-full flex items-center justify-center gap-2 px-6 lg:px-8 xl:px-10 border-r border-[#D4D4D8] ${
        isFirst ? "border-l" : ""
      } font-pixel text-[14px] text-black hover:bg-neutral-50 transition-colors select-none`}
    >
      <span className="relative inline-block leading-none">
        <span>{label}</span>
        {/* Animated Underline: starts from left, kept while hovering or active, ends to right on leave */}
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

function DashboardButton() {
  const { isAuthenticated, user, signOut } = useAuth();
  const lineRef = useRef(null);
  const [showUserMenu, setShowUserMenu] = useState(false);

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
      duration: 0.18,
      ease: "power2.in",
      onComplete: () => {
        if (lineRef.current) {
          gsap.set(lineRef.current, { xPercent: -100, x: 0 });
        }
      },
    });
  };

  // If user is NOT logged in previously: display "Login" pointing to /login
  if (!isAuthenticated) {
    return (
      <Link
        href={EXTERNAL_LINKS.nav.login || "/login"}
        aria-label="Login to HulyPay"
        prefetch={false}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        className="group h-full w-[220px] bg-black hidden md:flex items-center justify-center gap-2 cursor-pointer hover:bg-neutral-900 transition-colors select-none"
      >
        <span className="relative inline-block leading-none">
          <span className="font-pixel text-[14px] text-white tracking-wider whitespace-nowrap">
            Login
          </span>
          {/* Animated White Underline: starts from left, kept while hovering, ends to right on leave */}
          <span
            className="absolute -bottom-[2px] left-0 w-full h-[2px] overflow-hidden pointer-events-none"
            aria-hidden="true"
          >
            <span ref={lineRef} className="block w-full h-full bg-white" />
          </span>
        </span>
        <Image
          src="/assets/Open_Link.svg"
          alt="Login"
          width={10}
          height={10}
          className="w-[10px] h-[10px] object-contain shrink-0"
        />
      </Link>
    );
  }

  // If user IS logged in previously: display "DashBoard" pointing to /dashboard
  return (
    <div
      className="relative h-full hidden md:block"
      onMouseEnter={() => setShowUserMenu(true)}
      onMouseLeave={() => setShowUserMenu(false)}
    >
      <Link
        href={EXTERNAL_LINKS.nav.dashboard}
        aria-label="Open Dashboard"
        prefetch={false}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        className="group h-full w-[220px] bg-black flex items-center justify-center gap-2 cursor-pointer hover:bg-neutral-900 transition-colors select-none"
      >
        <span className="w-2 h-2 rounded-full bg-[#62D800] shrink-0 animate-pulse" />
        <span className="relative inline-block leading-none">
          <span className="font-pixel text-[14px] text-white tracking-wider whitespace-nowrap">
            DashBoard
          </span>
          {/* Animated White Underline */}
          <span
            className="absolute -bottom-[2px] left-0 w-full h-[2px] overflow-hidden pointer-events-none"
            aria-hidden="true"
          >
            <span ref={lineRef} className="block w-full h-full bg-white" />
          </span>
        </span>
        <Image
          src="/assets/Open_Link.svg"
          alt="Open Link"
          width={10}
          height={10}
          className="w-[10px] h-[10px] object-contain shrink-0"
        />
      </Link>

      {/* User Quick Dropdown */}
      {showUserMenu && (
        <div className="absolute top-full right-0 w-[220px] bg-black border border-[#33333E] shadow-2xl p-3 z-50 text-white font-mono text-xs space-y-2 animate-in fade-in duration-150">
          <div className="border-b border-[#2A2A34] pb-2">
            <p className="text-[10px] uppercase text-[#62D800] font-bold">
              Authenticated
            </p>
            <p className="text-white font-bold truncate text-xs mt-0.5">
              {user?.fullName || user?.email || "Huly User"}
            </p>
          </div>
          <Link
            href="/dashboard"
            className="block py-1 hover:text-[#FF0000] transition-colors"
          >
            → Dashboard Console
          </Link>
          <button
            type="button"
            onClick={() => signOut()}
            className="w-full text-left py-1 text-red-400 hover:text-red-300 transition-colors cursor-pointer"
          >
            → Sign Out
          </button>
        </div>
      )}
    </div>
  );
}


export default function Navbar() {
  const { isAuthenticated, user, signOut } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [mobileBlogsExpanded, setMobileBlogsExpanded] = useState(false);
  const [mobileDownloadExpanded, setMobileDownloadExpanded] = useState(false);
  const [activeDropdown, setActiveDropdown] = useState(null); // 'blogs' | 'download' | null
  const [isVisible, setIsVisible] = useState(true);
  const headerRef = useRef(null);
  const lastScrollY = useRef(0);
  const isFirstRender = useRef(true);
  const dropdownTimeoutRef = useRef(null);

  const handleDropdownEnter = (menuName) => {
    if (dropdownTimeoutRef.current) {
      clearTimeout(dropdownTimeoutRef.current);
      dropdownTimeoutRef.current = null;
    }
    setActiveDropdown(menuName);
  };

  const handleDropdownLeave = () => {
    if (dropdownTimeoutRef.current) {
      clearTimeout(dropdownTimeoutRef.current);
    }
    dropdownTimeoutRef.current = setTimeout(() => {
      setActiveDropdown(null);
    }, 150);
  };

  const closeDropdownImmediately = () => {
    if (dropdownTimeoutRef.current) {
      clearTimeout(dropdownTimeoutRef.current);
      dropdownTimeoutRef.current = null;
    }
    setActiveDropdown(null);
  };

  useEffect(() => {
    return () => {
      if (dropdownTimeoutRef.current) {
        clearTimeout(dropdownTimeoutRef.current);
      }
    };
  }, []);

  // Prevent background scroll when mobile menu drawer is open
  useEffect(() => {
    if (mobileMenuOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [mobileMenuOpen]);

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
        setActiveDropdown(null);
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
        className="w-full bg-white fixed top-0 left-0 z-50 will-change-transform"
      >
        {/* Outer wrapper: flush edges with equal left and right sections - layered on top of dropdown */}
        <div className="w-full px-0 h-20 md:h-[80px] flex items-center justify-between relative z-20 bg-white border-b border-[#D4D4D8]">
          {/* Left Section: Logo only on mobile, Logo + HULYPAY on desktop */}
          <div className="flex items-center h-full z-10 w-auto md:w-[220px]">
            <Link
              href="/"
              onClick={closeDropdownImmediately}
              className="h-full flex items-center justify-center gap-3 hover:opacity-85 transition-opacity px-4 sm:px-6"
            >
              <div className="w-7 h-7 relative flex items-center justify-center shrink-0">
                <Image
                  src="/assets/logo-Light.svg"
                  alt="Huly Pay Logo"
                  width={28}
                  height={28}
                  priority
                  className="w-7 h-7 object-contain dark:hidden"
                />
                <Image
                  src="/assets/Logo-Dark.svg"
                  alt="Huly Pay Logo"
                  width={28}
                  height={28}
                  priority
                  className="w-7 h-7 object-contain hidden dark:block"
                />
              </div>
              <span className="hidden md:inline font-pixel text-lg sm:text-xl tracking-wider text-black select-none whitespace-nowrap">
                HULYPAY
              </span>
            </Link>
          </div>

          {/* Center Section: Navigation Links (Portfolio | Blogs v | Download v) */}
          <div className="hidden md:flex items-center h-full absolute left-1/2 -translate-x-1/2">
            <NavLink
              href={EXTERNAL_LINKS.nav.portfolio}
              label="Portfolio"
              isFirst
              onMouseEnter={closeDropdownImmediately}
            />
            <NavLink
              href={EXTERNAL_LINKS.nav.blogs}
              label="Blogs"
              isActive={activeDropdown === "blogs"}
              onMouseEnter={() => handleDropdownEnter("blogs")}
              onMouseLeave={handleDropdownLeave}
              icon={
                <svg
                  className={`w-2.5 h-1.5 text-black transition-transform duration-300 ease-in-out ${
                    activeDropdown === "blogs"
                      ? "rotate-180"
                      : "group-hover:rotate-180"
                  }`}
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
              href={EXTERNAL_LINKS.nav.download}
              label="Download"
              isActive={activeDropdown === "download"}
              onMouseEnter={() => handleDropdownEnter("download")}
              onMouseLeave={handleDropdownLeave}
              icon={
                <svg
                  className={`w-2.5 h-1.5 text-black transition-transform duration-300 ease-in-out ${
                    activeDropdown === "download"
                      ? "rotate-180"
                      : "group-hover:rotate-180"
                  }`}
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
              className="md:hidden mr-3 sm:mr-4 p-2 text-black hover:bg-neutral-100 rounded focus:outline-none cursor-pointer"
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

            {/* Theme Toggle Button */}
            <ThemeToggle fullHeight={false} className="mr-2 sm:mr-3 hidden sm:flex" />

            {/* Open Dashboard Link Box (Solid Black Button matching left section length) with animated white underline */}
            <DashboardButton />
          </div>
        </div>

        {/* Dropdown Mega-Menu Panel (matches Asserts_external/navbar_Blogs_open_.png and navbar_downloads_open.png) */}
        <div
          onMouseEnter={() => {
            if (activeDropdown) handleDropdownEnter(activeDropdown);
          }}
          onMouseLeave={handleDropdownLeave}
          className={`hidden md:block absolute top-full left-0 w-full bg-white border-b border-[#D4D4D8] z-10 transition-all duration-300 ease-out origin-top ${
            activeDropdown
              ? "opacity-100 translate-y-0 pointer-events-auto visible"
              : "opacity-0 -translate-y-4 pointer-events-none invisible"
          }`}
        >
          <div className="w-full p-2">
            {/* Blogs 4-column mega menu */}
            <div
              className={`grid grid-cols-4 gap-2 w-full ${
                activeDropdown === "blogs" ? "" : "hidden"
              }`}
            >
              {EXTERNAL_LINKS.blogsDropdown.map((item, index) => {
                const isExt = item.href.startsWith("http");
                const SvgComponent = NAV_BG_SVGS[item.label];
                return (
                  <Link
                    key={item.label}
                    href={item.href}
                    prefetch={false}
                    target={isExt ? "_blank" : undefined}
                    rel={isExt ? "noopener noreferrer" : undefined}
                    onClick={closeDropdownImmediately}
                    style={{ animationDelay: `${index * 100}ms` }}
                    className="group/card animate-nav-card h-[250px] w-full bg-[#E6E6E6] active:scale-[0.99] rounded-[6px] flex flex-col items-center justify-center gap-4 cursor-pointer select-none"
                  >
                    {/* SVG on top, full opacity black */}
                    {SvgComponent && (
                      <SvgComponent className="w-28 h-28 md:w-36 md:h-36 text-black shrink-0" />
                    )}

                    {/* Text below */}
                    <span className="font-pixel text-[16px] text-black tracking-wider leading-none">
                      {item.label}
                    </span>
                  </Link>
                );
              })}
            </div>

            {/* Download mega menu: 2 cards in first two columns matching navbar_downloads_open.png */}
            <div
              className={`grid grid-cols-4 gap-2 w-full ${
                activeDropdown === "download" ? "" : "hidden"
              }`}
            >
              {EXTERNAL_LINKS.downloadsDropdown.map((item, index) => {
                const isExt = item.href.startsWith("http");
                const SvgComponent = NAV_BG_SVGS[item.label];
                return (
                  <Link
                    key={item.label}
                    href={item.href}
                    prefetch={false}
                    target={isExt ? "_blank" : undefined}
                    rel={isExt ? "noopener noreferrer" : undefined}
                    onClick={closeDropdownImmediately}
                    style={{ animationDelay: `${index * 100}ms` }}
                    className="group/card animate-nav-card h-[250px] w-full bg-[#E6E6E6] active:scale-[0.99] rounded-[6px] flex flex-col items-center justify-center gap-4 cursor-pointer select-none"
                  >
                    {/* SVG on top, full opacity black */}
                    {SvgComponent && (
                      <SvgComponent className="w-28 h-28 md:w-36 md:h-36 text-black shrink-0" />
                    )}

                    {/* Text below */}
                    <span className="font-pixel text-[16px] text-black tracking-wider leading-none">
                      {item.label}
                    </span>
                  </Link>
                );
              })}
            </div>
          </div>
        </div>



        {/* Mobile Drawer Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-[#D4D4D8] bg-white px-6 py-4 flex flex-col gap-4 font-pixel text-[14px] max-h-[calc(100vh-80px)] overflow-y-auto">
            {/* Theme Toggle in Mobile Menu */}
            <div className="py-2 border-b border-neutral-100 flex items-center justify-between">
              <span className="text-black font-bold">Display Theme</span>
              <ThemeToggle />
            </div>

            <Link
              href={EXTERNAL_LINKS.nav.portfolio}
              onClick={() => setMobileMenuOpen(false)}
              className="py-2 border-b border-neutral-100 hover:text-neutral-600 transition-colors"
            >
              Portfolio
            </Link>

            {/* Mobile Blogs with Accordion */}
            <div className="border-b border-neutral-100 pb-2">
              <button
                type="button"
                onClick={() => setMobileBlogsExpanded(!mobileBlogsExpanded)}
                className="w-full py-2 flex items-center justify-between hover:text-neutral-600 transition-colors text-left"
              >
                <span>Blogs</span>
                <svg
                  className={`w-2.5 h-1.5 text-black transition-transform duration-200 ${
                    mobileBlogsExpanded ? "rotate-180" : ""
                  }`}
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
              </button>

              {mobileBlogsExpanded && (
                <div className="grid grid-cols-2 gap-2 mt-2 pt-1 pb-1">
                  {EXTERNAL_LINKS.blogsDropdown.map((item, index) => {
                    const isExt = item.href.startsWith("http");
                    const SvgComponent = NAV_BG_SVGS[item.label];
                    return (
                      <Link
                        key={item.label}
                        href={item.href}
                        target={isExt ? "_blank" : undefined}
                        rel={isExt ? "noopener noreferrer" : undefined}
                        onClick={() => {
                          setMobileMenuOpen(false);
                          setMobileBlogsExpanded(false);
                        }}
                        style={{ animationDelay: `${index * 100}ms` }}
                        className="group/mob animate-nav-card bg-[#E6E6E6] p-3 rounded-[6px] flex flex-col items-center justify-center gap-2 text-[12px] text-black"
                      >
                        {SvgComponent && (
                          <SvgComponent className="w-14 h-14 text-black shrink-0" />
                        )}
                        <span>{item.label}</span>
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Mobile Download with Accordion */}
            <div className="pb-2">
              <button
                type="button"
                onClick={() =>
                  setMobileDownloadExpanded(!mobileDownloadExpanded)
                }
                className="w-full py-2 flex items-center justify-between hover:text-neutral-600 transition-colors text-left"
              >
                <span>Download</span>
                <svg
                  className={`w-2.5 h-1.5 text-black transition-transform duration-200 ${
                    mobileDownloadExpanded ? "rotate-180" : ""
                  }`}
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
              </button>

              {mobileDownloadExpanded && (
                <div className="grid grid-cols-2 gap-2 mt-2 pt-1 pb-1">
                  {EXTERNAL_LINKS.downloadsDropdown.map((item, index) => {
                    const isExt = item.href.startsWith("http");
                    const SvgComponent = NAV_BG_SVGS[item.label];
                    return (
                      <Link
                        key={item.label}
                        href={item.href}
                        target={isExt ? "_blank" : undefined}
                        rel={isExt ? "noopener noreferrer" : undefined}
                        onClick={() => {
                          setMobileMenuOpen(false);
                          setMobileDownloadExpanded(false);
                        }}
                        style={{ animationDelay: `${index * 100}ms` }}
                        className="group/mob animate-nav-card bg-[#E6E6E6] p-3 rounded-[6px] flex flex-col items-center justify-center gap-2 text-[12px] text-black"
                      >
                        {SvgComponent && (
                          <SvgComponent className="w-14 h-14 text-black shrink-0" />
                        )}
                        <span>{item.label}</span>
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Direct Dashboard / Login Link for mobile drawer */}
            <div className="pt-2 border-t border-neutral-200">
              {!isAuthenticated ? (
                <Link
                  href={EXTERNAL_LINKS.nav.login || "/login"}
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full h-11 bg-black text-white flex items-center justify-center gap-2 rounded-[4px] font-pixel text-sm hover:bg-neutral-800 transition-colors"
                >
                  <span>Login</span>
                  <Image
                    src="/assets/Open_Link.svg"
                    alt=""
                    width={10}
                    height={10}
                    className="w-2.5 h-2.5 invert"
                  />
                </Link>
              ) : (
                <div className="space-y-2">
                  <Link
                    href={EXTERNAL_LINKS.nav.dashboard}
                    onClick={() => setMobileMenuOpen(false)}
                    className="w-full h-11 bg-black text-white flex items-center justify-center gap-2 rounded-[4px] font-pixel text-sm hover:bg-neutral-800 transition-colors"
                  >
                    <span className="w-2 h-2 rounded-full bg-[#62D800]" />
                    <span>Open Dashboard</span>
                    <Image
                      src="/assets/Open_Link.svg"
                      alt=""
                      width={10}
                      height={10}
                      className="w-2.5 h-2.5 invert"
                    />
                  </Link>
                  <button
                    type="button"
                    onClick={() => {
                      signOut();
                      setMobileMenuOpen(false);
                    }}
                    className="w-full py-1 text-center font-mono text-xs text-red-600 hover:underline cursor-pointer"
                  >
                    Sign Out ({user?.firstName || "User"})
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      </header>

      {/* Static Spacer to prevent page jumping when navbar hides/shows */}
      <div className="w-full h-20 md:h-[80px]" aria-hidden="true" />
    </>
  );
}
