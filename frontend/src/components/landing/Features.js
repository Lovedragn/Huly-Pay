"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import QrToTickAnimation, { MORPH_PIXELS } from "./QrToTickAnimation";
import BellNotificationAnimation from "./BellNotificationAnimation";
import WifiOfflineAnimation from "./WifiOfflineAnimation";
import LockJwtAnimation from "./LockJwtAnimation";
import PieChartAnimation from "./PieChartAnimation";

export default function Features() {
  const sectionRef = useRef(null);
  const containerRef = useRef(null);
  const stackRef = useRef(null);
  const cardsRef = useRef([]);

  const featureCards = [
    {
      id: "qr-scan-and-pay",
      title: "QR SCAN & PAY",
      bullets: [
        "Scan a merchant QR code directly in HulyPay.",
        "Choose your preferred payment application.",
        "Complete the payment and track the transaction.",
      ],
    },
    {
      id: "notification",
      title: "Notification",
      bullets: [
        "Detects payment notifications from your device.",
        "Extracts relevant transaction details automatically.",
        "Updates your HulyPay transaction history.",
      ],
    },
    {
      id: "offline-first",
      title: "Offline First",
      bullets: [
        "Saves transactions locally on your device.",
        "Works even when you're offline.",
        "Syncs data with the server when you're back online.",
      ],
    },
    {
      id: "authentication-and-jwt",
      title: "Authentication & JWT",
      bullets: [
        "Securely sign in and access your account.",
        "JWT protects communication with the backend.",
        "Only authenticated users can access their data.",
      ],
    },
    {
      id: "smart-charts",
      title: "Pie Chart",
      bullets: [
        "Collects and organizes your transaction data.",
        "Converts spending into charts, trends, and heatmaps.",
        "Helps you understand your spending at a glance.",
      ],
    },
  ];

  useEffect(() => {
    if (typeof window === "undefined") return;
    gsap.registerPlugin(ScrollTrigger);

    const setupCardSvgAnimations = (tl, container) => {
      // 1. QR Scan & Pay (Card 0: 0.0 -> 0.85)
      const morphNodes = container.querySelectorAll(".qr-morph-pixel");
      if (morphNodes && morphNodes.length > 0) {
        morphNodes.forEach((node, idx) => {
          const p = MORPH_PIXELS[idx];
          if (p) {
            const dx = p.tickX - p.qrX;
            const dy = p.tickY - p.qrY;
            tl.to(
              node,
              {
                x: dx,
                y: dy,
                ease: "power2.inOut",
                duration: 0.85,
              },
              0,
            );
          }
        });
      }

      const extraNodes = container.querySelectorAll(".qr-extra-pixel");
      if (extraNodes && extraNodes.length > 0) {
        tl.to(
          extraNodes,
          {
            opacity: 0,
            scale: 0,
            transformOrigin: "center center",
            duration: 0.45,
            stagger: 0.02,
            ease: "power2.in",
          },
          0,
        );
      }

      // 2. Bell Notification (Card 1: 0.88 -> 1.45)
      const bellBody = container.querySelectorAll(".bell-body");
      const bellClapper = container.querySelectorAll(".bell-clapper");
      const bellWaves = container.querySelectorAll(
        ".bell-wave-left, .bell-wave-right",
      );

      if (bellBody.length > 0) {
        gsap.set(bellWaves, {
          opacity: 0,
          scale: 0.6,
          transformOrigin: "center center",
        });
        gsap.set(bellBody, {
          transformOrigin: "70px 20px",
          rotation: 0,
        });
        gsap.set(bellClapper, {
          transformOrigin: "70px 96px",
          rotation: 0,
        });

        // Single-play bell shake as card 1 reaches the stack
        tl.to(
          bellBody,
          { rotation: 18, duration: 0.1, ease: "power1.inOut" },
          0.9,
        )
          .to(
            bellBody,
            { rotation: -18, duration: 0.12, ease: "power1.inOut" },
            1.0,
          )
          .to(
            bellBody,
            { rotation: 14, duration: 0.1, ease: "power1.inOut" },
            1.12,
          )
          .to(
            bellBody,
            { rotation: -10, duration: 0.1, ease: "power1.inOut" },
            1.22,
          )
          .to(
            bellBody,
            { rotation: 6, duration: 0.08, ease: "power1.inOut" },
            1.32,
          )
          .to(
            bellBody,
            { rotation: 0, duration: 0.08, ease: "power1.out" },
            1.4,
          );

        tl.to(
          bellClapper,
          { rotation: -14, duration: 0.1, ease: "power1.inOut" },
          0.9,
        )
          .to(
            bellClapper,
            { rotation: 14, duration: 0.12, ease: "power1.inOut" },
            1.0,
          )
          .to(
            bellClapper,
            { rotation: -8, duration: 0.1, ease: "power1.inOut" },
            1.12,
          )
          .to(
            bellClapper,
            { rotation: 0, duration: 0.1, ease: "power1.out" },
            1.22,
          );

        tl.to(
          bellWaves,
          { opacity: 1, scale: 1.15, duration: 0.15, ease: "back.out(2)" },
          1.0,
        ).to(
          bellWaves,
          { opacity: 0, scale: 1.35, duration: 0.22, ease: "power2.out" },
          1.2,
        );
      }

      // 3. Offline First Wi-Fi (Card 2: 1.88 -> 2.6)
      const wifiFloat = container.querySelectorAll(".wifi-float-container");
      const wifiOuter = container.querySelectorAll(".wifi-outer-arc");
      const wifiMid = container.querySelectorAll(".wifi-mid-arc");
      const wifiInner = container.querySelectorAll(".wifi-inner-arc");
      const wifiDot = container.querySelectorAll(".wifi-dot");

      if (wifiFloat.length > 0) {
        gsap.set(wifiFloat, { y: 0 });
        gsap.set([wifiOuter, wifiMid, wifiInner, wifiDot], { opacity: 1 });

        // Single-play gentle floating and sequential signal dim/brighten
        tl.to(wifiFloat, { y: -12, duration: 0.35, ease: "sine.out" }, 1.9).to(
          wifiFloat,
          { y: 0, duration: 0.35, ease: "sine.in" },
          2.25,
        );

        tl.to(
          wifiOuter,
          { opacity: 0.2, duration: 0.18, ease: "power1.inOut" },
          1.95,
        )
          .to(
            wifiMid,
            { opacity: 0.25, duration: 0.18, ease: "power1.inOut" },
            2.05,
          )
          .to(
            wifiInner,
            { opacity: 0.3, duration: 0.18, ease: "power1.inOut" },
            2.15,
          )
          .to(
            wifiDot,
            { opacity: 0.45, duration: 0.15, ease: "power1.inOut" },
            2.22,
          )
          .to(
            [wifiDot, wifiInner, wifiMid, wifiOuter],
            {
              opacity: 1,
              duration: 0.28,
              stagger: 0.04,
              ease: "power2.out",
            },
            2.35,
          );
      }

      // 4. Authentication & JWT Lock (Card 3: 2.88 -> 3.6)
      const lockShackle = container.querySelectorAll(".lock-shackle");
      const lockBody = container.querySelectorAll(".lock-body");
      const lockSpark = container.querySelectorAll(".lock-spark");

      if (lockShackle.length > 0) {
        // Starts unlocked with shackle raised and angled
        gsap.set(lockShackle, {
          y: -24,
          rotation: -14,
          transformOrigin: "42px 56px",
        });
        gsap.set(lockBody, { y: 0 });
        gsap.set(lockSpark, {
          opacity: 0,
          scale: 0,
          transformOrigin: "70px 76px",
        });

        // Single-play snap shut into locked state
        tl.to(
          lockShackle,
          { rotation: 0, duration: 0.18, ease: "power2.in" },
          2.9,
        )
          .to(
            lockShackle,
            { y: 0, duration: 0.22, ease: "back.out(2.2)" },
            3.06,
          )
          .to(lockBody, { y: 3, duration: 0.05, ease: "power1.in" }, 3.26)
          .to(lockBody, { y: 0, duration: 0.07, ease: "power1.out" }, 3.31)
          .fromTo(
            lockSpark,
            { opacity: 0, scale: 0 },
            { opacity: 1, scale: 1.25, duration: 0.12, ease: "back.out(2)" },
            3.3,
          )
          .to(
            lockSpark,
            { opacity: 0, scale: 0.5, duration: 0.18, ease: "power2.in" },
            3.42,
          );
      }

      // 5. Smart Charts / Pie Chart (Card 4: Barcode in Square Container -> Pie Chart)
      const barcodeContainer = container.querySelectorAll(".barcode-container");
      const barcodeBox = container.querySelectorAll(".barcode-box");
      const barcodeBars = container.querySelectorAll(".barcode-bar");
      const barcodeData = container.querySelectorAll(".barcode-data");
      const pieChartGroup = container.querySelectorAll(".pie-chart-group");
      const pieSlice = container.querySelectorAll(".pie-slice");

      if (barcodeContainer.length > 0) {
        // Initial state: Barcode square container is visible, pie chart is hidden
        gsap.set(barcodeContainer, {
          opacity: 1,
          scale: 1,
          transformOrigin: "70px 70px",
        });
        gsap.set(barcodeBox, {
          scale: 1,
          opacity: 1,
          rotation: 0,
          transformOrigin: "70px 70px",
        });
        gsap.set(barcodeBars, {
          scaleY: 1,
          opacity: 1,
          transformOrigin: "center center",
        });
        gsap.set(barcodeData, {
          opacity: 1,
        });
        gsap.set(pieChartGroup, {
          opacity: 0,
          scale: 0.65,
          rotation: -12,
          transformOrigin: "70px 70px",
        });
        gsap.set(pieSlice, { x: 0, y: 0 });

        // Transform barcode square container into Pie Chart
        // 1. Barcode bars compress and dissolve
        tl.to(
          barcodeBars,
          {
            scaleY: 0.1,
            opacity: 0,
            stagger: 0.02,
            duration: 0.22,
            ease: "power2.in",
          },
          3.88,
        )
          // 2. Barcode box shrinks, tilts slightly, and fades out
          .to(
            barcodeBox,
            {
              scale: 0.72,
              rotation: 12,
              opacity: 0,
              duration: 0.25,
              ease: "power2.in",
            },
            3.92,
          )
          .to(
            barcodeData,
            {
              opacity: 0,
              duration: 0.15,
              ease: "power1.in",
            },
            3.88,
          )
          // 3. Pie Chart group emerges, scales up with a back.out bounce and rotates straight
          .to(
            pieChartGroup,
            {
              opacity: 1,
              scale: 1,
              rotation: 0,
              duration: 0.28,
              ease: "back.out(1.8)",
            },
            4.08,
          )
          // 4. Accent pie slice pops outward
          .to(
            pieSlice,
            {
              x: 12,
              y: -12,
              duration: 0.28,
              ease: "power2.out",
            },
            4.26,
          );
      }
    };

    const ctx = gsap.context(() => {
      const mm = gsap.matchMedia();

      // Desktop & Tablets (>= 768px): 68px tab spacing
      mm.add("(min-width: 768px)", () => {
        const tabOffset = 68;
        const totalCards = featureCards.length;

        // Initial setup: Card 0 in center, Cards 1-4 start offscreen below
        gsap.set(cardsRef.current[0], { y: 0, opacity: 1 });
        for (let i = 1; i < totalCards; i++) {
          gsap.set(cardsRef.current[i], { y: "110vh", opacity: 1 });
        }
        gsap.set(stackRef.current, { y: 0 });

        const tl = gsap.timeline({
          scrollTrigger: {
            trigger: sectionRef.current,
            start: "top top",
            end: "+=2200", // comfortable scroll distance (~550px per card transition)
            pin: true,
            scrub: 0.8,
            invalidateOnRefresh: true,
          },
        });

        // Setup all 5 card SVG animations within this scroll timeline
        if (sectionRef.current) {
          setupCardSvgAnimations(tl, sectionRef.current);
        }

        // Sequentially animate Cards 1 to 4 into the stack
        for (let i = 1; i < totalCards; i++) {
          tl.to(
            cardsRef.current[i],
            {
              y: i * tabOffset,
              ease: "none",
              duration: 1,
            },
            i - 1,
          );

          tl.to(
            stackRef.current,
            {
              y: -(i * tabOffset) / 2,
              ease: "none",
              duration: 1,
            },
            i - 1,
          );
        }

        // Buffer pause so user can view the full 5-card stack together before unpinning
        tl.to({}, { duration: 0.8 });
      });

      // Mobile Devices (< 768px): 48px tab spacing
      mm.add("(max-width: 767px)", () => {
        const tabOffset = 48;
        const totalCards = featureCards.length;

        gsap.set(cardsRef.current[0], { y: 0, opacity: 1 });
        for (let i = 1; i < totalCards; i++) {
          gsap.set(cardsRef.current[i], { y: "110vh", opacity: 1 });
        }
        gsap.set(stackRef.current, { y: 0 });

        const tl = gsap.timeline({
          scrollTrigger: {
            trigger: sectionRef.current,
            start: "top top",
            end: "+=1800",
            pin: true,
            scrub: 0.8,
            invalidateOnRefresh: true,
          },
        });

        // Setup all 5 card SVG animations within this scroll timeline
        if (sectionRef.current) {
          setupCardSvgAnimations(tl, sectionRef.current);
        }

        for (let i = 1; i < totalCards; i++) {
          tl.to(
            cardsRef.current[i],
            {
              y: i * tabOffset,
              ease: "none",
              duration: 1,
            },
            i - 1,
          );

          tl.to(
            stackRef.current,
            {
              y: -(i * tabOffset) / 2,
              ease: "none",
              duration: 1,
            },
            i - 1,
          );
        }

        tl.to({}, { duration: 0.8 });
      });
    }, sectionRef);

    return () => ctx.revert();
  }, [featureCards.length]);

  return (
    <section
      ref={sectionRef}
      id="features"
      className="relative w-full bg-[#FFFFEB] overflow-hidden"
    >
      {/* 100% Full Screen Centered Viewport Wrapper */}
      <div
        ref={containerRef}
        className="w-full h-screen flex items-center justify-center px-4 sm:px-6 md:px-8 pt-8 sm:pt-12 md:pt-16"
      >
        {/* Animated Stack Deck Container */}
        <div
          ref={stackRef}
          className="relative w-full max-w-[1060px] mx-auto flex items-start justify-center translate-y-3 sm:translate-y-6"
          style={{ minHeight: "560px" }}
        >
          {featureCards.map((card, index) => (
            <div
              key={card.id}
              ref={(el) => {
                if (el) cardsRef.current[index] = el;
              }}
              className="absolute top-0 left-0 right-0 w-full bg-[#FF0000] border-[7px] sm:border-[9px] md:border-[10px] border-[#CC0000] rounded-[28px] sm:rounded-[36px] md:rounded-[42px] p-6 sm:p-8 md:p-10 pt-5 sm:pt-6 md:pt-7 shadow-[0_12px_32px_rgba(0,0,0,0.22)] select-none"
              style={{
                zIndex: index + 1,
              }}
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
                {/* Left Side: Title and Bullets */}
                <div className="flex-1">
                  <h2
                    className={`font-bold text-[26px] sm:text-[32px] font-doto md:text-[36px] tracking-wide text-white mb-5 sm:mb-6 select-none`}
                  >
                    {card.title}
                  </h2>

                  <ul className="space-y-3 sm:space-y-4 pl-3 sm:pl-6 md:pl-8 max-w-2xl">
                    {card.bullets.map((bullet, idx) => (
                      <li key={idx} className="flex items-start gap-3 sm:gap-4">
                        <span
                          aria-hidden="true"
                          className="w-2 h-2 sm:w-2.5 sm:h-2.5 bg-white mt-2 sm:mt-2.5 flex-shrink-0 select-none"
                        />
                        <p className="font-pixel text-[18px] sm:text-[20px] md:text-[22px] text-white leading-relaxed tracking-wide select-none">
                          {bullet}
                        </p>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Right Side Visual Graphics */}
                <div className="flex-shrink-0 self-center sm:self-auto sm:pr-2">
                  {card.id === "qr-scan-and-pay" && <QrToTickAnimation />}
                  {card.id === "notification" && <BellNotificationAnimation />}
                  {card.id === "offline-first" && <WifiOfflineAnimation />}
                  {card.id === "authentication-and-jwt" && <LockJwtAnimation />}
                  {card.id === "smart-charts" && <PieChartAnimation />}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
