/**
 * Centralized External Links & Data Configuration for Huly.pay
 */
export const download_link = "https://github.com/Lovedragn/Huly-Pay/releases/download/v2.5.0/hulypay_v2.5.0.apk"; 
export const download_version = "hulypay_v2.5.0.apk"; 

export const EXTERNAL_LINKS = {
  // Mobile app downloads
  downloads: {
    androidApk:
      download_link,
    apkFilename: download_version,
    version: download_version,
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
      href:download_link 
    },
    {
      label: "IOS",
      href: "#download-ios",
    },
  ],
};

export default EXTERNAL_LINKS;
