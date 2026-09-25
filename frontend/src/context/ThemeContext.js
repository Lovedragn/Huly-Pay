"use client";

import * as React from "react";

const ThemeContext = React.createContext({
  theme: "light",
  toggleTheme: () => {},
  setTheme: () => {},
  mounted: false,
});

const listeners = new Set();

function notifyListeners() {
  listeners.forEach((listener) => {
    try {
      listener();
    } catch {
      // Ignore
    }
  });
}

function subscribe(callback) {
  listeners.add(callback);
  if (typeof window !== "undefined") {
    window.addEventListener("storage", callback);
  }
  return () => {
    listeners.delete(callback);
    if (typeof window !== "undefined") {
      window.removeEventListener("storage", callback);
    }
  };
}

function getSnapshot() {
  if (typeof window === "undefined") return "light";
  try {
    const rawPrefs = localStorage.getItem("user_preference_website");
    if (rawPrefs) {
      const parsed = JSON.parse(rawPrefs);
      if (parsed.theme === "dark" || parsed.theme === "light") {
        return parsed.theme;
      }
    }
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      return "dark";
    }
  } catch {
    // Fallback on restricted localStorage
  }
  return "light";
}

function getServerSnapshot() {
  return "light";
}

const emptySubscribe = () => () => {};

export function ThemeProvider({ children }) {
  const theme = React.useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot
  );

  // Idiomatic SSR hydration check without setState in effect
  const mounted = React.useSyncExternalStore(
    emptySubscribe,
    () => true,
    () => false
  );

  React.useEffect(() => {
    if (typeof document === "undefined") return;
    const root = document.documentElement;
    if (theme === "dark") {
      root.classList.add("dark");
      root.setAttribute("data-theme", "dark");
    } else {
      root.classList.remove("dark");
      root.setAttribute("data-theme", "light");
    }
  }, [theme]);

  const setTheme = React.useCallback((nextTheme) => {
    try {
      const rawPrefs = localStorage.getItem("user_preference_website");
      let prefs = {};
      if (rawPrefs) {
        try {
          prefs = JSON.parse(rawPrefs);
        } catch {}
      }
      prefs.theme = nextTheme;
      localStorage.setItem("user_preference_website", JSON.stringify(prefs));
    } catch {
      // Ignore write errors
    }
    notifyListeners();
  }, []);

  const toggleTheme = React.useCallback(() => {
    const current = getSnapshot();
    const next = current === "dark" ? "light" : "dark";
    setTheme(next);
  }, [setTheme]);

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme, setTheme, mounted }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = React.useContext(ThemeContext);
  if (!context) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}
