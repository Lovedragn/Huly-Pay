export default function Features() {
  const featureCards = [
    {
      id: "qr-scan-and-pay",
      title: "QR SCAN & PAY",
      theme: {
        cardBg: "bg-[#FF0000]",
        titleColor: "text-white",
        textColor: "text-white",
        bulletColor: "bg-white",
      },
      bullets: [
        "Scan a merchant QR code directly from HulyPay.",
        "The app decodes the payment details and amount.",
        "Choose your preferred supported payment application.",
        "HulyPay launches the payment app with the required details.",
        "The transaction is then captured and added to your payment history.",
      ],
    },
    {
      id: "notification",
      title: "NOTIFICATION",
      theme: {
        cardBg: "bg-[#FF0000]",
        titleColor: "text-white",
        textColor: "text-white",
        bulletColor: "bg-white",
      },
      bullets: [
        "Complete a payment through your preferred payment application.",
        "HulyPay detects the payment notification from the device.",
        "Relevant transaction details are extracted from the notification.",
        "The payment is matched with your transaction record.",
        "Your dashboard is automatically updated with the latest payment.",
      ],
    },
    {
      id: "offline-first",
      title: "OFFLINE FIRST",
      theme: {
        cardBg: "bg-[#FF0000]",
        titleColor: "text-white",
        textColor: "text-white",
        bulletColor: "bg-white",
      },
      bullets: [
        "Transactions are saved locally on the device first.",
        "You can continue using HulyPay even without an internet connection.",
        "Pending transactions remain safely queued for synchronization.",
        "When connectivity returns, HulyPay sends them to the backend.",
        "The local record is then updated after successful server synchronization.",
      ],
    },
    {
      id: "authentication-and-jwt",
      title: "AUTHENTICATION & JWT",
      theme: {
        cardBg: "bg-[#FF0000]",
        titleColor: "text-white",
        textColor: "text-white",
        bulletColor: "bg-white",
      },
      bullets: [
        "Users securely authenticate before accessing their account.",
        "Authentication is handled through the configured auth system.",
        "The backend validates JWT tokens with protected API requests.",
        "Unauthorized or expired sessions are rejected automatically.",
        "User and transaction data remain accessible only to authenticated users.",
      ],
    },
    {
      id: "smart-charts",
      title: "SMART CHARTS",
      theme: {
        cardBg: "bg-[#FF0000]",
        titleColor: "text-white",
        textColor: "text-white",
        bulletColor: "bg-white",
      },
      bullets: [
        "HulyPay collects your transaction and spending data.",
        "Transactions are organized into categories and time periods.",
        "The data is transformed into visual charts and heatmaps.",
        "Users can identify spending patterns, trends, and high-activity periods.",
        "Financial activity becomes easier to understand at a glance.",
      ],
    },
  ];

  return (
    <section
      id="features"
      className="w-full bg-[#FFFFEB] py-16 sm:py-24 md:py-32 px-4 sm:px-8 md:px-12 lg:px-16"
    >
      <div className="max-w-[1240px] mx-auto flex flex-col gap-10 md:gap-14">
        {featureCards.map((card) => (
          <div
            key={card.id}
            className={`w-full ${card.theme.cardBg} rounded-[28px] sm:rounded-[36px] md:rounded-[40px] p-8 sm:p-12 md:p-14 lg:p-16 transition-all`}
          >
            {/* Feature Title in Doto font with font-bolder */}
            <h2
              className={`font-doto font-bolder font-black text-3xl sm:text-4xl md:text-5xl tracking-wider ${card.theme.titleColor} uppercase mb-8 sm:mb-10 select-none`}
            >
              {card.title}
            </h2>

            {/* Bullet Points with Square Pixel Bullets and Indentation */}
            <ul className="space-y-4 sm:space-y-5 pl-2 sm:pl-8 md:pl-10 max-w-4xl">
              {card.bullets.map((bullet, idx) => (
                <li key={idx} className="flex items-start gap-3.5 sm:gap-4 md:gap-5">
                  {/* Square Pixel Bullet */}
                  <span
                    aria-hidden="true"
                    className={`w-1.5 h-1.5 sm:w-2 sm:h-2 ${card.theme.bulletColor} mt-2 sm:mt-2.5 flex-shrink-0 select-none`}
                  />
                  {/* Bullet Content */}
                  <p
                    className={`font-pixel text-sm sm:text-base md:text-lg lg:text-[19px] ${card.theme.textColor} leading-relaxed tracking-wide select-none`}
                  >
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
