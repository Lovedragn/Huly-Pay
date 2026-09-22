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
import { SIGNATURE_STROKE_LENGTH } from "./signaturePaths";

const TransitionContext = createContext({
  navigate: () => {},
  isTransitioning: false,
});

export const usePageTransition = () => useContext(TransitionContext);

/**
 * TransitionProvider Component
 *
 * Implements the Codegrid GSAP Page Transitions pattern:
 * - Intercepts route navigation to other pages.
 * - Slides in a full-screen white curtain with GSAP.
 * - Plays the normal given SVG signature animation (~1.1s).
 * - Pushes the new route.
 * - Lifts the curtain cleanly with GSAP (power3.inOut) to reveal the new page.
 */
export default function TransitionProvider({ children }) {
  const router = useRouter();
  const pathname = usePathname();

  const [isTransitioning, setIsTransitioning] = useState(false);
  const [sigKey, setSigKey] = useState(0);

  const overlayRef = useRef(null);
  const sigWrapperRef = useRef(null);
  const maskPathRef = useRef(null);
  const fillPathRef = useRef(null);
  const targetHrefRef = useRef(null);
  const isNavigatingRef = useRef(false);

  // Initial GSAP setup for the transition overlay
  useEffect(() => {
    if (overlayRef.current) {
      gsap.set(overlayRef.current, { yPercent: 100, pointerEvents: "none" });
      gsap.set(sigWrapperRef.current, { opacity: 0, scale: 0.95 });
    }
  }, []);

  // When pathname changes after router.push, perform the "Enter" reveal animation
  useEffect(() => {
    if (isNavigatingRef.current) {
      isNavigatingRef.current = false;

      // Ensure window is scrolled to top on new page
      window.scrollTo(0, 0);

      // Give the new page component a brief tick to mount cleanly
      const timer = setTimeout(() => {
        const tl = gsap.timeline({
          onComplete: () => {
            if (overlayRef.current) {
              gsap.set(overlayRef.current, {
                yPercent: 100,
                pointerEvents: "none",
              });
            }
            setIsTransitioning(false);
          },
        });

        // Fade out signature slightly before lifting curtain
        tl.to(sigWrapperRef.current, {
          opacity: 0,
          y: -15,
          duration: 0.25,
          ease: "power2.in",
        });

        // White curtain lifts up off the screen to reveal new content
        tl.to(
          overlayRef.current,
          {
            yPercent: -100,
            duration: 0.55,
            ease: "power3.inOut",
          },
          "-=0.1",
        );
      }, 80);

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
          // If hash changed, let browser handle smooth scroll
          if (targetUrl.hash) {
            window.location.hash = targetUrl.hash;
          }
          return;
        }
      } catch {
        // Fallback standard push if URL parsing fails
        router.push(href);
        return;
      }

      isNavigatingRef.current = true;
      targetHrefRef.current = href;
      setIsTransitioning(true);
      setSigKey((prev) => prev + 1);

      // Lock pointer events and reset initial positions
      gsap.set(overlayRef.current, { yPercent: 100, pointerEvents: "auto" });
      gsap.set(sigWrapperRef.current, { opacity: 1, y: 0, scale: 1 });
      gsap.set(maskPathRef.current, {
        strokeDashoffset: SIGNATURE_STROKE_LENGTH,
      });

      const tl = gsap.timeline({
        onComplete: () => {
          // Push new route once the normal SVG animation and curtain cover are finished
          router.push(href);

          // Safety fallback: if pathname doesn't update within 4 seconds, release overlay
          setTimeout(() => {
            if (isNavigatingRef.current && overlayRef.current) {
              isNavigatingRef.current = false;
              gsap.to(overlayRef.current, {
                yPercent: -100,
                duration: 0.4,
                ease: "power3.out",
                onComplete: () => {
                  gsap.set(overlayRef.current, {
                    yPercent: 100,
                    pointerEvents: "none",
                  });
                  setIsTransitioning(false);
                },
              });
            }
          }, 4000);
        },
      });

      // 1. Curtain slides in from bottom to cover screen (Codegrid style)
      tl.to(overlayRef.current, {
        yPercent: 0,
        duration: 0.45,
        ease: "power3.inOut",
      });

      // 2. Play normal given SVG animation (~1.1s stroke draw)
      tl.to(
        maskPathRef.current,
        {
          strokeDashoffset: 0,
          duration: 1.1,
          ease: "power1.inOut",
        },
        "-=0.1",
      );

      // 3. Brief elegant pause before router swap
      tl.to({}, { duration: 0.15 });
    },
    [isTransitioning, router],
  );

  // Global link interception for automatic smooth page transitions
  useEffect(() => {
    const handleDocumentClick = (e) => {
      // Find closest anchor tag
      const anchor = e.target.closest("a");
      if (!anchor) return;

      const href = anchor.getAttribute("href");
      if (!href) return;

      // Ignore clicks with modifier keys (new tab, download, etc.)
      if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      if (e.defaultPrevented) return;
      if (anchor.target === "_blank") return;
      if (anchor.hasAttribute("download")) return;
      if (anchor.getAttribute("rel") === "external") return;
      if (anchor.getAttribute("data-no-transition")) return;

      // Ignore hash links
      if (href.startsWith("#")) return;

      // Check origin
      try {
        const targetUrl = new URL(href, window.location.href);
        if (targetUrl.origin !== window.location.origin) return;

        // If target is same pathname, don't trigger transition
        if (targetUrl.pathname === window.location.pathname) return;

        // Internal page navigation intercepted!
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

      {/* Codegrid-Style Page Transition Overlay */}
      <div
        ref={overlayRef}
        className="fixed inset-0 z-[99990] bg-white flex flex-col items-center justify-center select-none overflow-hidden"
        style={{ willChange: "transform" }}
        aria-hidden={!isTransitioning}
      >
        <div
          ref={sigWrapperRef}
          className="flex items-center justify-center px-6 w-full"
        >
          {/* Normal Mode Signature Animation (1.1s) — Pure Signature Only */}
          <AnimatedSignature
            key={sigKey}
            maskPathRef={maskPathRef}
            fillPathRef={fillPathRef}
            mode="initial" // Controlled via GSAP for synchronous perfection
            color="#0a0a0a"
            className="w-[100px] sm:w-[140px] md:w-[180px] max-w-[85vw]"
          />
        </div>
      </div>
    </TransitionContext.Provider>
  );
}
