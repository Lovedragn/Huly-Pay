import localFont from "next/font/local";
import { Geist, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "lenis/dist/lenis.css";
import "./globals.css";
import SmoothScroll from "@/components/SmoothScroll";
import TransitionProvider from "@/components/transitions/TransitionProvider";
import InitialLoader from "@/components/transitions/InitialLoader";
import { AuthProvider } from "@/context/AuthContext";
import { ThemeProvider } from "@/context/ThemeContext";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const pixelifySans = localFont({
  src: "./fonts/PixelifySans.ttf",
  variable: "--font-pixelify",
  display: "swap",
});

const dotoFont = localFont({
  src: "./fonts/Doto.ttf",
  variable: "--font-doto",
  display: "swap",
});

export const metadata = {
  title: "Hulypay",
  description: "Huly Pay - Pay, Track, Grow",
};

export default function RootLayout({ children }) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} ${pixelifySans.variable} ${dotoFont.variable} h-full antialiased`}
      suppressHydrationWarning
    >
      <head>
        <Script
          id="theme-init"
          strategy="beforeInteractive"
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  var theme = null;
                  var rawPrefs = localStorage.getItem('user_preference_website');
                  if (rawPrefs) {
                    try {
                      var parsed = JSON.parse(rawPrefs);
                      theme = parsed.theme;
                    } catch (e) {}
                  }
                  if (theme === 'dark' || (!theme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                    document.documentElement.classList.add('dark');
                    document.documentElement.setAttribute('data-theme', 'dark');
                  } else {
                    document.documentElement.classList.remove('dark');
                    document.documentElement.setAttribute('data-theme', 'light');
                  }
                } catch (e) {}
              })();
            `,
          }}
        />
      </head>
      <body
        className="min-h-full flex flex-col font-pixel bg-[#FFFFEB] dark:bg-[#0C0D0F] text-black dark:text-white transition-colors duration-200"
        suppressHydrationWarning
      >
        <InitialLoader />
        <ThemeProvider>
          <AuthProvider>
            <TransitionProvider>
              <SmoothScroll>{children}</SmoothScroll>
            </TransitionProvider>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
