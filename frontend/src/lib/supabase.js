import { createClient } from "@supabase/supabase-js";

const supabaseUrl =
  process.env.NEXT_PUBLIC_SUPABASE_URL ||
  "https://aszhhxnbzstzemyhcjvi.supabase.co";

const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzemhoeG5ienN0emVteWhjanZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkxMDUzNTcsImV4cCI6MjEwNDY4MTM1N30.phMhGk86eV0ddNj9rNQJOo58fNQ7j1tok3osOe9thUo";

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});

/**
 * Sign in using Google OAuth (matches Flutter AuthService.signInWithGoogle)
 */
export async function signInWithGoogle(redirectTo) {
  const origin =
    typeof window !== "undefined"
      ? window.location.origin
      : "http://localhost:3000";

  const targetRedirect = redirectTo || `${origin}/login?callback=true`;

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: targetRedirect,
      queryParams: {
        access_type: "offline",
        prompt: "consent",
      },
    },
  });

  if (error) throw error;
  return data;
}

/**
 * Sign in using GitHub OAuth (matches Flutter AuthService.signInWithGitHub)
 */
export async function signInWithGitHub(redirectTo) {
  const origin =
    typeof window !== "undefined"
      ? window.location.origin
      : "http://localhost:3000";

  const targetRedirect = redirectTo || `${origin}/login?callback=true`;

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "github",
    options: {
      redirectTo: targetRedirect,
    },
  });

  if (error) throw error;
  return data;
}

/**
 * Sign out of Supabase session
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}

/**
 * Get current authenticated user
 */
export async function getCurrentUser() {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
}

/**
 * Get current session
 */
export async function getCurrentSession() {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  return session;
}
