import Link from "next/link";

export default function PageBanner({
  tag,
  title,
  subtitle,
  accentColor = "#FF0000",
}) {
  return (
    <section className="w-full bg-white border-b border-[#D4D4D8] pt-12 sm:pt-16 pb-12 sm:pb-16 px-6 sm:px-10 lg:px-16">
      <div className="max-w-[1440px] mx-auto flex flex-col items-start">
        {/* Navigation Breadcrumb */}
        <div className="flex items-center gap-2 text-xs sm:text-sm font-pixel text-neutral-500 mb-6 select-none">
          <Link href="/" className="hover:text-black transition-colors">
            HOME
          </Link>
          <span>/</span>
          <span className="text-black font-semibold uppercase">{tag}</span>
        </div>

        {/* Tag Pill */}
        <div className="inline-flex items-center gap-2 px-3 py-1 bg-black text-white text-xs font-pixel tracking-wider uppercase mb-5 select-none">
          <span
            className="w-2 h-2 rounded-full inline-block"
            style={{ backgroundColor: accentColor }}
          />
          <span>{tag}</span>
        </div>

        {/* Main Title */}
        <h1 className="font-pixel text-4xl sm:text-6xl lg:text-7xl font-bold tracking-tight text-black leading-[1.05] max-w-4xl select-none">
          {title}
        </h1>

        {/* Subtitle */}
        {subtitle && (
          <p className="mt-5 text-base sm:text-lg lg:text-xl text-neutral-600 max-w-2xl font-pixel leading-relaxed">
            {subtitle}
          </p>
        )}
      </div>
    </section>
  );
}
