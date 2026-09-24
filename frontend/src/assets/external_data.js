/**
 * Centralized External Links & Data Configuration for Huly.pay
 */

export const EXTERNAL_LINKS = {
  // Mobile app downloads
  downloads: {
    androidApk:
      "https://github.com/Lovedragn/Huly-Pay/releases/download/v2.3.0/Hulypay_v2.3.0.apk",
    apkFilename: "Hulypay_v2.3.0.apk",
    iosApp: "#download-ios",
  },

  // Social & Community & Personal Profiles
  social: {
    github: "https://github.com/Lovedragn",
    linkedin: "https://www.linkedin.com/in/sujith-sappani/",
    personal_portfolio: "https://sujithsappani.vercel.app",
    twitter: "https://twitter.com/HulyPay",
  },

  // Navigation & Internal anchors
  nav: {
    portfolio: "https://sujithsappani.vercel.app",
    blogs: "#blogs",
    download: "#download",
    dashboard: "/dashboard",
    login: "/login",
    privacyTerms: "/privacy-terms",
  },

  // Blogs dropdown menu items matching navbar_Blogs_open_.png
  blogsDropdown: [
    { label: "Features", href: "/features" },
    { label: "Design", href: "/design" },
    { label: "Q&A", href: "/qna" },
    { label: "Tools", href: "/tools" },
  ],

  // Downloads dropdown menu items matching navbar_downloads_open.png
  downloadsDropdown: [
    {
      label: "Android",
      href: "https://github.com/Lovedragn/Huly-Pay/releases/download/v2.3.0/Hulypay_v2.3.0.apk",
    },
    {
      label: "IOS",
      href: "#download-ios",
    },
  ],
};

export default EXTERNAL_LINKS;
