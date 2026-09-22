"use client";

import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

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
      title: "Smart Charts",
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

        // Sequentially animate each card into the stack
        for (let i = 1; i < totalCards; i++) {
          // Slide card i up from bottom into its exact cascading stack position
          tl.to(
            cardsRef.current[i],
            {
              y: i * tabOffset,
              ease: "none",
              duration: 1,
            },
            i - 1
          );

          // Gently shift stack upward so the combined deck remains perfectly centered vertically
          tl.to(
            stackRef.current,
            {
              y: -(i * tabOffset) / 2,
              ease: "none",
              duration: 1,
            },
            i - 1
          );
        }

        // Buffer pause so user can view the full 5-card stack together before unpinning
        tl.to({}, { duration: 0.4 });
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

        for (let i = 1; i < totalCards; i++) {
          tl.to(
            cardsRef.current[i],
            {
              y: i * tabOffset,
              ease: "none",
              duration: 1,
            },
            i - 1
          );

          tl.to(
            stackRef.current,
            {
              y: -(i * tabOffset) / 2,
              ease: "none",
              duration: 1,
            },
            i - 1
          );
        }

        tl.to({}, { duration: 0.4 });
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
        className="w-full h-screen flex items-center justify-center px-4 sm:px-6 md:px-8"
      >
        {/* Animated Stack Deck Container */}
        <div
          ref={stackRef}
          className="relative w-full max-w-[1060px] mx-auto flex items-start justify-center"
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
              {/* Feature Title using Doto font, increased by 2 */}
              <h2 className="font-doto font-bold text-[26px] sm:text-[32px] md:text-[36px] tracking-wide text-white mb-5 sm:mb-6 select-none">
                {card.title}
              </h2>

              {/* Bullet Points with Square Pixel Bullets and font size increased by 2 */}
              <ul className="space-y-3 sm:space-y-4 pl-3 sm:pl-6 md:pl-8 max-w-3xl">
                {card.bullets.map((bullet, idx) => (
                  <li key={idx} className="flex items-start gap-3 sm:gap-4">
                    {/* Square Pixel Bullet */}
                    <span
                      aria-hidden="true"
                      className="w-2 h-2 sm:w-2.5 sm:h-2.5 bg-white mt-2 sm:mt-2.5 flex-shrink-0 select-none"
                    />
                    {/* Bullet Content increased by 2px */}
                    <p className="font-pixel text-[18px] sm:text-[20px] md:text-[22px] text-white leading-relaxed tracking-wide select-none">
                      {bullet}
                    </p>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
