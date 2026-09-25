"use client";

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
} from "react";
import { useRouter } from "next/navigation";
import {
  supabase,
  signInWithGoogle as supaSignInGoogle,
  signInWithGitHub as supaSignInGitHub,
  signOut as supaSignOut,
} from "@/lib/supabase";
import { getCurrentUserProfile } from "@/lib/api";

const AuthContext = createContext({
  user: null,
  session: null,
  isAuthenticated: false,
  isLoading: true,
  signInWithGoogle: async () => {},
  signInWithGitHub: async () => {},
  loginAsDemoUser: () => {},
  signOut: async () => {},
  backendProfile: null,
});

export const useAuth = () => useContext(AuthContext);

const LOCAL_STORAGE_USER_KEY = "hulypay_auth_user";
const LOCAL_STORAGE_SESSION_KEY = "hulypay_auth_session";

function getInitialAuth() {
  if (typeof window === "undefined") {
    return { user: null, session: null, isLoading: true };
  }
  try {
    const cachedUser = localStorage.getItem(LOCAL_STORAGE_USER_KEY);
    const cachedSession = localStorage.getItem(LOCAL_STORAGE_SESSION_KEY);
    if (cachedUser) {
      return {
        user: JSON.parse(cachedUser),
        session: cachedSession ? JSON.parse(cachedSession) : null,
        isLoading: false,
      };
    }
  } catch {}
  return { user: null, session: null, isLoading: true };
}

export function AuthProvider({ children }) {
  const router = useRouter();
  const [user, setUser] = useState(() => getInitialAuth().user);
  const [session, setSession] = useState(() => getInitialAuth().session);
  const [backendProfile, setBackendProfile] = useState(null);
  const [isLoading, setIsLoading] = useState(() => getInitialAuth().isLoading);

  // Sync profile with Spring Boot backend
  const syncWithBackend = useCallback(async (token, currentAuthUser) => {
    if (!token) return;
    try {
      const profile = await getCurrentUserProfile(token);
      if (profile) {
        setBackendProfile(profile);
      }
    } catch {
      // Backend might be offline or using local mock
    }
  }, []);

  // Format Supabase user to standard shape matching Flutter UserProfile
  const mapSupabaseUser = (sbUser) => {
    if (!sbUser) return null;
    const meta = sbUser.user_metadata || {};
    const appMeta = sbUser.app_metadata || {};

    const fullName =
      meta.full_name ||
      meta.name ||
      (meta.first_name ? `${meta.first_name} ${meta.last_name || ""}`.trim() : null) ||
      (sbUser.email ? sbUser.email.split("@")[0] : "Huly User");

    const avatarUrl = meta.avatar_url || meta.picture || null;
    const authProvider = appMeta.provider || "google";

    return {
      id: sbUser.id,
      email: sbUser.email || "",
      fullName,
      firstName: meta.first_name || fullName.split(" ")[0] || "User",
      lastName: meta.last_name || fullName.split(" ").slice(1).join(" ") || "",
      avatarUrl,
      authProvider,
      active: true,
    };
  };

  useEffect(() => {
    let isMounted = true;

    // Fetch active session from Supabase
    async function initAuth() {
      try {
        const {
          data: { session: currentSession },
        } = await supabase.auth.getSession();

        if (!isMounted) return;

        if (currentSession?.user) {
          const mapped = mapSupabaseUser(currentSession.user);
          setUser(mapped);
          setSession(currentSession);

          try {
            localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mapped));
            localStorage.setItem(
              LOCAL_STORAGE_SESSION_KEY,
              JSON.stringify(currentSession)
            );
          } catch {}

          syncWithBackend(currentSession.access_token, mapped);
        } else {
          // If no session from Supabase and not a demo user
          try {
            const cachedUser = localStorage.getItem(LOCAL_STORAGE_USER_KEY);
            if (cachedUser) {
              const parsed = JSON.parse(cachedUser);
              if (parsed?.isDemo) {
                setUser(parsed);
                setIsLoading(false);
                return;
              }
            }
          } catch {}

          setUser(null);
          setSession(null);
          try {
            localStorage.removeItem(LOCAL_STORAGE_USER_KEY);
            localStorage.removeItem(LOCAL_STORAGE_SESSION_KEY);
          } catch {}
        }
      } catch (err) {
        console.error("Auth init error:", err);
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    initAuth();

    // 3. Listen to Supabase Auth state changes (OAuth redirects, token refresh, logout)
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, newSession) => {
      if (!isMounted) return;

      if (newSession?.user) {
        const mapped = mapSupabaseUser(newSession.user);
        setUser(mapped);
        setSession(newSession);

        try {
          localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mapped));
          localStorage.setItem(
            LOCAL_STORAGE_SESSION_KEY,
            JSON.stringify(newSession)
          );
        } catch {}

        syncWithBackend(newSession.access_token, mapped);
      } else if (event === "SIGNED_OUT") {
        setUser(null);
        setSession(null);
        setBackendProfile(null);
        try {
          localStorage.removeItem(LOCAL_STORAGE_USER_KEY);
          localStorage.removeItem(LOCAL_STORAGE_SESSION_KEY);
        } catch {}
      }
      setIsLoading(false);
    });

    return () => {
      isMounted = false;
      subscription?.unsubscribe();
    };
  }, [syncWithBackend]);

  const signInWithGoogle = async (redirectTo) => {
    return await supaSignInGoogle(redirectTo);
  };

  const signInWithGitHub = async (redirectTo) => {
    return await supaSignInGitHub(redirectTo);
  };

  // Demo user login for testing or offline exploration
  const loginAsDemoUser = () => {
    const demoUser = {
      id: "demo-user-8842-4f1b-a9b0",
      email: "alex.mercer@hulypay.io",
      fullName: "Alex Mercer",
      firstName: "Alex",
      lastName: "Mercer",
      avatarUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=120&q=80",
      authProvider: "google",
      active: true,
      isDemo: true,
    };
    setUser(demoUser);
    setSession({
      access_token: "mock_demo_jwt_token_hulypay",
      user: demoUser,
    });
    try {
      localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(demoUser));
      localStorage.setItem(
        LOCAL_STORAGE_SESSION_KEY,
        JSON.stringify({ access_token: "mock_demo_jwt_token_hulypay" })
      );
    } catch {}
  };

  const signOut = async () => {
    try {
      await supaSignOut();
    } catch {
      // Local clean up even if remote fails
    }
    setUser(null);
    setSession(null);
    setBackendProfile(null);
    try {
      localStorage.removeItem(LOCAL_STORAGE_USER_KEY);
      localStorage.removeItem(LOCAL_STORAGE_SESSION_KEY);
    } catch {}

    if (typeof window !== "undefined") {
      router.push("/");
    }
  };

  const isAuthenticated = Boolean(user);

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        isAuthenticated,
        isLoading,
        signInWithGoogle,
        signInWithGitHub,
        loginAsDemoUser,
        signOut,
        backendProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}
