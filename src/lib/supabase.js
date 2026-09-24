import { createClient } from "@supabase/supabase-js";

const supabaseUrl =
  process.env.SUPABASE_URL ||
  process.env.NEXT_PUBLIC_SUPABASE_URL ||
  process.env.SUPABASE_API_URL ||
  "";

const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY ||
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  process.env.SUPABASE_API_ANON_KEY ||
  "";

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
