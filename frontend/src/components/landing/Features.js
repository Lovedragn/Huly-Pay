export default function Features() {
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
      title: "NOTIFICATION",
      bullets: [
        "Detects payment notifications from your device.",
        "Extracts relevant transaction details automatically.",
        "Updates your HulyPay transaction history.",
      ],
    },
    {
      id: "offline-first",
      title: "OFFLINE FIRST",
      bullets: [
        "Saves transactions locally on your device.",
        "Works even when you're offline.",
        "Syncs data with the server when you're back online.",
      ],
    },
    {
      id: "authentication-and-jwt",
      title: "AUTHENTICATION & JWT",
      bullets: [
        "Securely sign in and access your account.",
        "JWT protects communication with the backend.",
        "Only authenticated users can access their data.",
      ],
    },
    {
      id: "smart-charts",
      title: "SMART CHARTS",
      bullets: [
        "Collects and organizes your transaction data.",
        "Converts spending into charts, trends, and heatmaps.",
        "Helps you understand your spending at a glance.",
      ],
    },
  ];

  return (
    <section
      id="features"
      className="w-full bg-[#FFFFEB] py-14 sm:py-20 md:py-24 px-4 sm:px-8 md:px-12"
    >
      <div className="max-w-[960px] mx-auto flex flex-col gap-6 sm:gap-8">
        {featureCards.map((card) => (
          <div
            key={card.id}
            className="w-full bg-[#FF0000] border-[6px] sm:border-[8px] border-[#CC0000] rounded-[24px] sm:rounded-[32px] p-6 sm:p-8 md:p-10 shadow-md transition-all"
          >
            {/* Feature Title in Doto font */}
            <h2 className="font-doto font-bold text-xl sm:text-2xl md:text-[26px] tracking-wider text-white uppercase mb-5 sm:mb-6 select-none">
              {card.title}
            </h2>

            {/* Bullet Points with Square Pixel Bullets and Indentation */}
            <ul className="space-y-2.5 sm:space-y-3.5 pl-3 sm:pl-6 md:pl-8 max-w-3xl">
              {card.bullets.map((bullet, idx) => (
                <li key={idx} className="flex items-start gap-3 sm:gap-4">
                  {/* Square Pixel Bullet */}
                  <span
                    aria-hidden="true"
                    className="w-1.5 h-1.5 sm:w-2 sm:h-2 bg-white mt-1.5 sm:mt-2 flex-shrink-0 select-none"
                  />
                  {/* Bullet Content */}
                  <p className="font-pixel text-sm sm:text-base md:text-[17px] text-white leading-relaxed tracking-wide select-none">
                    {bullet}
                  </p>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </section>
  );
}
