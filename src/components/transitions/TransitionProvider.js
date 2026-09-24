"use client";

import React, {
  createContext,
  useContext,
  useState,
  useRef,
  useEffect,
  useCallback,
} from "react";
import { useRouter, usePathname } from "next/navigation";
import gsap from "gsap";
import AnimatedSignature from "./AnimatedSignature";

const SEGMENT_COUNT = 20;

const TransitionContext = createContext({
  navigate: () => {},
  isTransitioning: false,
});

export const usePageTransition = () => useContext(TransitionContext);

/**
 * TransitionProvider Component
 *
 * Implements 20-segmentation vertical rectangle page transitions:
 * - Intercepts route navigation to other pages.
 * - 20 vertical white rectangles (no borders) sweep and fill from left to right.
 * - Signature begins its smooth GSAP handwriting stroke animation in the center.
 * - Pushes the new route.
 * - 20 vertical white rectangles exit from left to right, revealing the new page.
 */
export default function TransitionProvider({ children }) {
  const router = useRouter();
  const pathname = usePathname();

  const [isTransitioning, setIsTransitioning] = useState(false);
  const [sigKey, setSigKey] = useState(0);

  const overlayRef = useRef(null);
  const sigWrapperRef = useRef(null);
  const blocksRef = useRef([]);
  const isNavigatingRef = useRef(false);

  // Initial GSAP setup for the transition overlay
  useEffect(() => {
    const blocks = blocksRef.current.filter(Boolean);
    if (overlayRef.current) {
      gsap.set(overlayRef.current, { pointerEvents: "none" });
      gsap.set(blocks, {
        clipPath: "inset(0% 100% 0% 0%)",
        webkitClipPath: "inset(0% 100% 0% 0%)",
      });
      gsap.set(sigWrapperRef.current, { opacity: 0 });
    }
  }, []);

  // When pathname changes after router.push, perform the "Enter" reveal animation
  useEffect(() => {
    if (isNavigatingRef.current) {
      isNavigatingRef.current = false;

      // Ensure window is scrolled to top on new page
      window.scrollTo(0, 0);

      const blocks = blocksRef.current.filter(Boolean);

      // Give the new page component a brief tick to mount cleanly
      const timer = setTimeout(() => {
        const tl = gsap.timeline({
          onComplete: () => {
            if (overlayRef.current) {
              gsap.set(overlayRef.current, { pointerEvents: "none" });
            }
            setIsTransitioning(false);
          },
        });

        // 1. Fade out signature slightly before opening curtains
        tl.to(sigWrapperRef.current, {
          opacity: 0,
          y: -10,
          duration: 0.2,
          ease: "power2.in",
        });

        // 2. 20 vertical white rectangles exit from left side to right side (revealing the new page)
        tl.to(
          blocks,
          {
            clipPath: "inset(-1% -1% -1% 101%)",
            webkitClipPath: "inset(-1% -1% -1% 101%)",
            duration: 0.62,
            ease: "power3.inOut",
            stagger: {
              each: 0.022,
              from: "start", // reveals from left to right
            },
          },
          "-=0.08",
        );
      }, 70);

      return () => clearTimeout(timer);
    }
  }, [pathname]);

  // Execute transition navigation
  const navigate = useCallback(
    (href) => {
      if (!href) return;
      if (isNavigatingRef.current || isTransitioning) return;

      // Ignore hash links or same-page navigation
      try {
        const targetUrl = new URL(href, window.location.href);
        const currentUrl = new URL(window.location.href);

        if (
          targetUrl.pathname === currentUrl.pathname &&
          targetUrl.search === currentUrl.search
        ) {
          if (targetUrl.hash) {
            window.location.hash = targetUrl.hash;
          }
          return;
        }
      } catch {
        router.push(href);
        return;
      }

      isNavigatingRef.current = true;
      setIsTransitioning(true);
      setSigKey((prev) => prev + 1);

      const blocks = blocksRef.current.filter(Boolean);

      // Lock pointer events and reset initial positions
      gsap.set(overlayRef.current, { pointerEvents: "auto" });
      gsap.set(blocks, {
        clipPath: "inset(0% 100% 0% 0%)",
        webkitClipPath: "inset(0% 100% 0% 0%)",
      });
      gsap.set(sigWrapperRef.current, { opacity: 0, y: 0 });

      const tl = gsap.timeline({
        onComplete: () => {
          // Push new route once the signature animation and rectangle cover are finished
          router.push(href);

          // Safety fallback: if pathname doesn't update within 4 seconds, release overlay
          setTimeout(() => {
            if (isNavigatingRef.current && overlayRef.current) {
              isNavigatingRef.current = false;
              gsap.to(blocks, {
                clipPath: "inset(-1% -1% -1% 101%)",
                webkitClipPath: "inset(-1% -1% -1% 101%)",
                duration: 0.5,
                stagger: { each: 0.02, from: "start" },
                ease: "power3.out",
                onComplete: () => {
                  gsap.set(overlayRef.current, { pointerEvents: "none" });
                  setIsTransitioning(false);
                },
              });
            }
          }, 4000);
        },
      });

      // 1. 20 segmentation vertical white rectangles fill from left to right
      tl.to(blocks, {
        clipPath: "inset(-1% -1% -1% -1%)",
        webkitClipPath: "inset(-1% -1% -1% -1%)",
        duration: 0.52,
        ease: "power3.inOut",
        stagger: {
          each: 0.022,
          from: "start", // Left side to right side
        },
      });

      // 2. Signature fades in and cursive handwriting stroke plays
      tl.to(
        sigWrapperRef.current,
        {
          opacity: 1,
          duration: 0.22,
          ease: "power2.out",
        },
        "-=0.18",
      );

      // Duration for signature handwriting stroke animation to finish
      tl.to({}, { duration: 1.35 });
    },
    [isTransitioning, router],
  );

  // Global link interception for automatic smooth page transitions
  useEffect(() => {
    const handleDocumentClick = (e) => {
      const anchor = e.target.closest("a");
      if (!anchor) return;

      const href = anchor.getAttribute("href");
      if (!href) return;

      if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      if (e.defaultPrevented) return;
      if (anchor.target === "_blank") return;
      if (anchor.hasAttribute("download")) return;
      if (anchor.getAttribute("rel") === "external") return;
      if (anchor.getAttribute("data-no-transition")) return;
      if (href.startsWith("#")) return;

      try {
        const targetUrl = new URL(href, window.location.href);
        if (targetUrl.origin !== window.location.origin) return;
        if (targetUrl.pathname === window.location.pathname) return;

        e.preventDefault();
        navigate(href);
      } catch {
        // Not a standard URL, allow default
      }
    };

    document.addEventListener("click", handleDocumentClick, { capture: true });
    return () => {
      document.removeEventListener("click", handleDocumentClick, {
        capture: true,
      });
    };
  }, [navigate]);

  return (
    <TransitionContext.Provider value={{ navigate, isTransitioning }}>
      {children}

      {/* 20-Segmentation Vertical Rectangles Page Transition Overlay */}
      <div
        ref={overlayRef}
        className="fixed inset-0 z-[99990] pointer-events-none select-none overflow-hidden bg-transparent"
        aria-hidden={!isTransitioning}
      >
        {/* 20 segmentation of vertical rectangles with brand red color #FF0000, no border colors */}
        <div className="absolute inset-0 flex flex-row pointer-events-none overflow-hidden w-full h-full">
          {Array.from({ length: SEGMENT_COUNT }).map((_, i) => (
            <div
              key={i}
              ref={(el) => {
                blocksRef.current[i] = el;
              }}
              className="h-full flex-1 bg-[#FF0000] border-0 outline-none select-none pointer-events-none"
              style={{
                clipPath: "inset(0% 100% 0% 0%)",
                WebkitClipPath: "inset(0% 100% 0% 0%)",
                willChange: "clip-path",
              }}
            />
          ))}
        </div>

        {/* Centered signature */}
        <div
          ref={sigWrapperRef}
          className="relative z-10 w-full h-full flex items-center justify-center px-6 pointer-events-none"
          style={{ opacity: 0 }}
        >
          <AnimatedSignature
            key={sigKey}
            delay={0.45}
            duration={1.3}
            color="#1a1a1a"
            className="w-[110px] sm:w-[150px] md:w-[190px] max-w-[85vw]"
          />
        </div>
      </div>
    </TransitionContext.Provider>
  );
}
