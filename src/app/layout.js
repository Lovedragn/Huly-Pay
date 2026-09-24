import localFont from "next/font/local";
import { Geist, Geist_Mono } from "next/font/google";
import "lenis/dist/lenis.css";
import "./globals.css";
import SmoothScroll from "@/components/SmoothScroll";
import TransitionProvider from "@/components/transitions/TransitionProvider";
import InitialLoader from "@/components/transitions/InitialLoader";
import { AuthProvider } from "@/context/AuthContext";

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
      <body
        className="min-h-full flex flex-col font-pixel"
        suppressHydrationWarning
      >
        <InitialLoader />
        <AuthProvider>
          <TransitionProvider>
            <SmoothScroll>{children}</SmoothScroll>
          </TransitionProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
