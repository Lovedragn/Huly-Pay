"use client";

import * as React from "react";
import { useTheme } from "@/context/ThemeContext";

export default function ThemeToggle({ fullHeight = false, className = "" }) {
  const { theme, toggleTheme, mounted } = useTheme();

  // Prevent hydration mismatch
  const isDark = mounted ? theme === "dark" : false;

  if (fullHeight) {
    return (
      <button
        type="button"
        onClick={toggleTheme}
        className={`h-full px-3 sm:px-4.5 bg-white dark:bg-[#181920] hover:bg-[#FFFFEB] dark:hover:bg-[#252830] transition-colors flex items-center justify-center gap-2 border-l-[3px] border-black dark:border-neutral-700 font-mono text-xs font-bold cursor-pointer select-none group text-black dark:text-white ${className}`}
        title={`Switch to ${isDark ? "Light" : "Dark"} Mode (Saved to Local Storage)`}
        aria-label="Toggle Dark and Light Mode"
      >
        {isDark ? (
          <>
            <svg
              className="w-4 h-4 text-[#D8FF00] group-hover:rotate-90 transition-transform duration-300 shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
              />
            </svg>
            <span className="hidden sm:inline font-pixel text-xs text-[#D8FF00]">
              LIGHT
            </span>
          </>
        ) : (
          <>
            <svg
              className="w-4 h-4 text-black group-hover:-rotate-45 transition-transform duration-300 shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
              />
            </svg>
            <span className="hidden sm:inline font-pixel text-xs text-black">
              DARK
            </span>
          </>
        )}
      </button>
    );
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      className={`px-3 py-1.5 border-2 border-black dark:border-neutral-400 bg-white dark:bg-[#181920] hover:bg-neutral-100 dark:hover:bg-[#252830] text-black dark:text-white transition-all cursor-pointer font-mono text-xs font-bold shadow-[2px_2px_0px_#000000] dark:shadow-[2px_2px_0px_#ffffff] active:translate-x-0.5 active:translate-y-0.5 flex items-center gap-2 group ${className}`}
      title={`Switch to ${isDark ? "Light" : "Dark"} Mode (Saved to Local Storage)`}
      aria-label="Toggle Dark and Light Mode"
    >
      {isDark ? (
        <>
          <svg
            className="w-3.5 h-3.5 text-[#D8FF00] group-hover:rotate-90 transition-transform duration-300 shrink-0"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
            />
          </svg>
          <span className="font-pixel text-xs">LIGHT</span>
        </>
      ) : (
        <>
          <svg
            className="w-3.5 h-3.5 text-black group-hover:-rotate-45 transition-transform duration-300 shrink-0"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
            />
          </svg>
          <span className="font-pixel text-xs">DARK</span>
        </>
      )}
    </button>
  );
}
