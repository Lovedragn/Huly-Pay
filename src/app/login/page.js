"use client";

import React, { useState, useEffect, Suspense } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth } from "@/context/AuthContext";

function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const {
    user,
    isAuthenticated,
    signInWithGoogle,
    signInWithGitHub,
  } = useAuth();

  const isCallbackInitial = () => {
    if (typeof window === "undefined") return false;
    return Boolean(
      searchParams?.get("callback") ||
      window.location.hash.includes("access_token")
    );
  };

  const [isLoadingGoogle, setIsLoadingGoogle] = useState(false);
  const [isLoadingGitHub, setIsLoadingGitHub] = useState(false);
  const [isProcessingAuth, setIsProcessingAuth] = useState(() => isCallbackInitial());
  const [errorMessage, setErrorMessage] = useState(null);
  const [policyModal, setPolicyModal] = useState(null); // { title: string, content: string } | null

  // If already authenticated, redirect to /dashboard
  useEffect(() => {
    if (isAuthenticated && user) {
      const redirectTimer = setTimeout(() => {
        router.push("/dashboard");
      }, 300);
      return () => clearTimeout(redirectTimer);
    }
  }, [isAuthenticated, user, router]);

  // Check if returning from OAuth callback
  useEffect(() => {
    const isCallback = searchParams?.get("callback");
    const hasHashToken =
      typeof window !== "undefined" &&
      window.location.hash.includes("access_token");

    if (isCallback || hasHashToken) {
      // Give Supabase a moment to parse the URL hash and fire onAuthStateChange
      const timeout = setTimeout(() => {
        if (!isAuthenticated) {
          setIsProcessingAuth(false);
        }
      }, 5000);
      return () => clearTimeout(timeout);
    }
  }, [searchParams, isAuthenticated]);

  const handleGoogleSignIn = async () => {
    if (isLoadingGoogle || isLoadingGitHub || isProcessingAuth) return;
    setErrorMessage(null);
    setIsLoadingGoogle(true);
    setIsProcessingAuth(true);

    try {
      const redirectUrl =
        typeof window !== "undefined"
          ? `${window.location.origin}/login?callback=true`
          : undefined;

      await signInWithGoogle(redirectUrl);
    } catch (err) {
      console.error("Google Sign-In Error:", err);
      setErrorMessage(
        err?.message ||
          "Could not initialize Google Sign-In. Check your internet connection."
      );
      setIsProcessingAuth(false);
      setIsLoadingGoogle(false);
    }
  };

  const handleGitHubSignIn = async () => {
    if (isLoadingGoogle || isLoadingGitHub || isProcessingAuth) return;
    setErrorMessage(null);
    setIsLoadingGitHub(true);
    setIsProcessingAuth(true);

    try {
      const redirectUrl =
        typeof window !== "undefined"
          ? `${window.location.origin}/login?callback=true`
          : undefined;

      await signInWithGitHub(redirectUrl);
    } catch (err) {
      console.error("GitHub Sign-In Error:", err);
      setErrorMessage(
        err?.message ||
          "Could not initialize GitHub Sign-In. Check your internet connection."
      );
      setIsProcessingAuth(false);
      setIsLoadingGitHub(false);
    }
  };

  const openPolicyDialog = (title, content) => {
    setPolicyModal({ title, content });
  };

  const closePolicyDialog = () => {
    setPolicyModal(null);
  };

  return (
    <div className="relative min-h-screen w-full bg-black text-white flex flex-col justify-between overflow-x-hidden selection:bg-[#FF0000] selection:text-white">
      {/* Background Subtle Gradient & Grid Glow */}
      <div
        className="pointer-events-none absolute inset-0 opacity-20 bg-[radial-gradient(#33333E_1px,transparent_1px)] [background-size:24px_24px]"
        aria-hidden="true"
      />
      <div
        className="pointer-events-none absolute -top-40 left-1/2 -translate-x-1/2 w-[600px] h-[350px] bg-red-600/10 blur-[130px] rounded-full"
        aria-hidden="true"
      />



      {/* Main Body Centerpiece: Exactly replicating Flutter SignInScreen */}
      <main className="relative z-10 w-full max-w-md mx-auto px-6 py-8 flex-1 flex flex-col justify-center">
        {/* Brand Logo & Subtle Glow */}
        <div className="flex flex-col items-center justify-center mb-8 sm:mb-10 text-center">
          <div className="relative mb-5 flex items-center justify-center">
            <div className="absolute inset-0 bg-red-600/20 blur-2xl rounded-full scale-110" />
            <div className="relative w-28 h-28 sm:w-32 sm:h-32 flex items-center justify-center">
              <Image
                src="/assets/Logo-Dark.svg"
                alt="HulyPay Brand Logo"
                width={128}
                height={128}
                priority
                className="w-full h-full object-contain filter drop-shadow-[0_8px_24px_rgba(255,0,0,0.25)]"
              />
            </div>
          </div>

          {/* Heading and Tagline matching Flutter sign_in_screen.dart */}
          <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight text-white font-sans">
            Experience HulyPay
          </h1>
          <p className="mt-2 text-base sm:text-lg text-[#8E8E93] font-medium tracking-wide">
            Track. Pay. Grow.
          </p>
        </div>

        {/* Error Notification Banner if any */}
        {errorMessage && (
          <div className="mb-5 p-3.5 bg-red-950/60 border border-red-800/80 rounded-2xl flex items-start gap-3 text-red-200 text-xs sm:text-sm animate-in fade-in duration-200">
            <svg
              className="w-5 h-5 text-red-400 shrink-0 mt-0.5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            <div className="flex-1">
              <p className="font-semibold">Authentication Notice</p>
              <p className="text-red-300/90 text-xs mt-0.5 leading-relaxed">
                {errorMessage}
              </p>
            </div>
            <button
              type="button"
              onClick={() => setErrorMessage(null)}
              className="text-red-400 hover:text-white text-xs font-mono"
            >
              ✕
            </button>
          </div>
        )}

        {/* Auth Processing Indicator (Flutter-style cancellable pill) */}
        {isProcessingAuth && (
          <div className="mb-4 flex justify-center">
            <button
              type="button"
              onClick={() => {
                setIsProcessingAuth(false);
                setIsLoadingGoogle(false);
                setIsLoadingGitHub(false);
              }}
              className="group inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-[#1E1E24] border border-[#33333E] text-xs font-medium text-white hover:bg-[#282830] transition-colors"
            >
              <span className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              <span>Authenticating... (tap to cancel)</span>
            </button>
          </div>
        )}

        {/* Action Buttons Section */}
        <div className="space-y-3.5">
          {/* Primary Action: Google Sign-In Button (Exact Flutter Replica) */}
          <button
            type="button"
            onClick={handleGoogleSignIn}
            disabled={isProcessingAuth}
            className={`w-full h-14 rounded-full bg-white text-black font-sans font-bold text-base flex items-center justify-center gap-3 transition-all duration-200 shadow-md ${
              isProcessingAuth
                ? "opacity-60 cursor-not-allowed"
                : "hover:bg-neutral-100 hover:scale-[1.01] active:scale-[0.98] cursor-pointer"
            }`}
          >
            {isLoadingGoogle ? (
              <span className="w-5 h-5 border-2 border-black border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                <Image
                  src="/assets/google.svg"
                  alt="Google"
                  width={22}
                  height={22}
                  className="w-[22px] h-[22px] object-contain shrink-0"
                />
                <span>Google</span>
              </>
            )}
          </button>

          {/* Secondary Action: GitHub Sign-In Button (Exact Flutter Replica) */}
          <button
            type="button"
            onClick={handleGitHubSignIn}
            disabled={isProcessingAuth}
            className={`w-full h-14 rounded-full bg-[#24292E] border border-[#33333E] text-white font-sans font-bold text-base flex items-center justify-center gap-3 transition-all duration-200 ${
              isProcessingAuth
                ? "opacity-60 cursor-not-allowed"
                : "hover:bg-[#2F363D] hover:border-neutral-500 hover:scale-[1.01] active:scale-[0.98] cursor-pointer"
            }`}
          >
            {isLoadingGitHub ? (
              <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                <Image
                  src="/assets/github.svg"
                  alt="GitHub"
                  width={22}
                  height={22}
                  className="w-[22px] h-[22px] object-contain shrink-0 invert"
                />
                <span>GitHub</span>
              </>
            )}
          </button>
        </div>
      </main>

      {/* Bottom Disclaimer: Terms of Service & Privacy Policy (Flutter Replica) */}
      <footer className="relative z-10 w-full max-w-lg mx-auto px-6 pb-8 text-center">
        <p className="text-xs text-[#71717A] leading-relaxed font-sans">
          By continuing, you agree to our{" "}
          <button
            type="button"
            onClick={() =>
              openPolicyDialog(
                "Terms of Service",
                "By accessing or using Huly Pay, you agree to comply with our user agreement, zero-custody settlement standards, and transaction terms. All automated SMS ledger parsing occurs locally under strict user consent."
              )
            }
            className="text-[#9E9EA7] font-medium underline underline-offset-2 hover:text-white transition-colors cursor-pointer"
          >
            Terms of Service
          </button>{" "}
          and{" "}
          <button
            type="button"
            onClick={() =>
              openPolicyDialog(
                "Privacy Policy",
                "Huly Pay protects your financial data using end-to-end encryption and strict zero-knowledge protocols. We do not store or transmit plaintext banking credentials or unmasked card numbers."
              )
            }
            className="text-[#9E9EA7] font-medium underline underline-offset-2 hover:text-white transition-colors cursor-pointer"
          >
            Privacy Policy
          </button>
          .
        </p>
      </footer>

      {/* Modal Dialog matching Flutter _showPolicyDialog */}
      {policyModal && (
        <div
          role="dialog"
          aria-modal="true"
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200"
          onClick={closePolicyDialog}
        >
          <div
            className="w-full max-w-md bg-[#1C1C20] border border-[#33333E] rounded-[20px] p-6 text-left shadow-2xl space-y-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-white font-sans">
                {policyModal.title}
              </h2>
              <button
                type="button"
                onClick={closePolicyDialog}
                className="w-8 h-8 rounded-full bg-[#2A2A30] text-neutral-400 hover:text-white flex items-center justify-center transition-colors"
                aria-label="Close dialog"
              >
                ✕
              </button>
            </div>

            <p className="text-sm text-[#8E8E93] leading-relaxed font-sans">
              {policyModal.content}
            </p>

            <div className="pt-2 flex items-center justify-between border-t border-[#2C2C34]">
              <Link
                href="/privacy-terms"
                onClick={closePolicyDialog}
                className="font-mono text-xs text-[#FF0000] hover:underline"
              >
                Read Full Legal Doc →
              </Link>
              <button
                type="button"
                onClick={closePolicyDialog}
                className="px-5 py-2 rounded-xl bg-white text-black font-sans font-bold text-sm hover:bg-neutral-200 transition-colors cursor-pointer"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen w-full bg-black flex items-center justify-center text-white font-mono text-sm">
          Loading authentication gateway...
        </div>
      }
    >
      <LoginContent />
    </Suspense>
  );
}
