import featureNavbarBg from "../../public/assets/navbar/feature_navbar_bg.svg";
import designNavbarBg from "../../public/assets/navbar/design_navbar_bg.svg";
import qnaNavbarBg from "../../public/assets/navbar/qna_navbar_bg.svg";
import toolsNavbarBg from "../../public/assets/navbar/tools_navbar_bg.svg";
import androidNavbarBg from "../../public/assets/navbar/android_navbar_bg.svg";
import iosNavbarBg from "../../public/assets/navbar/ios_navbar_bg.svg";

/**
 * Raw imported SVG assets from public/assets
 */
export const NAV_BG_ASSETS = {
  Features: featureNavbarBg,
  Design: designNavbarBg,
  "Q&A": qnaNavbarBg,
  Tools: toolsNavbarBg,
  Android: androidNavbarBg,
  IOS: iosNavbarBg,
  iOS: iosNavbarBg,
};

/**
 * Reusable NavBgIcon component that dynamically masks the SVG asset from public/assets
 * and changes color to red (#EF4444) on hover.
 */
export function NavBgIcon({
  src,
  alt = "navbar bg icon",
  className = "w-28 h-28 md:w-36 md:h-36",
  ...props
}) {
  const iconSrc =
    typeof src === "string"
      ? src
      : src?.src || "/assets/navbar/feature_navbar_bg.svg";

  return (
    <span
      className={`inline-block bg-black group-hover/card:bg-[#EF4444] group-hover/mob:bg-[#EF4444] transition-colors duration-200 shrink-0 ${className}`}
      style={{
        maskImage: `url(${iconSrc})`,
        WebkitMaskImage: `url(${iconSrc})`,
        maskSize: "contain",
        WebkitMaskSize: "contain",
        maskRepeat: "no-repeat",
        WebkitMaskRepeat: "no-repeat",
        maskPosition: "center",
        WebkitMaskPosition: "center",
      }}
      role="img"
      aria-label={alt}
      {...props}
    />
  );
}

export function FeaturesNavbarBg(props) {
  return <NavBgIcon src={featureNavbarBg} alt="Features" {...props} />;
}

export function DesignNavbarBg(props) {
  return <NavBgIcon src={designNavbarBg} alt="Design" {...props} />;
}

export function QnaNavbarBg(props) {
  return <NavBgIcon src={qnaNavbarBg} alt="Q&A" {...props} />;
}

export function ToolsNavbarBg(props) {
  return <NavBgIcon src={toolsNavbarBg} alt="Tools" {...props} />;
}

export function AndroidNavbarBg(props) {
  return <NavBgIcon src={androidNavbarBg} alt="Android" {...props} />;
}

export function IosNavbarBg(props) {
  return <NavBgIcon src={iosNavbarBg} alt="IOS" {...props} />;
}

export const NAV_BG_SVGS = {
  Features: FeaturesNavbarBg,
  Design: DesignNavbarBg,
  "Q&A": QnaNavbarBg,
  Tools: ToolsNavbarBg,
  Android: AndroidNavbarBg,
  IOS: IosNavbarBg,
  iOS: IosNavbarBg,
};

export default NAV_BG_SVGS;
