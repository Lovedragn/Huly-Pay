import Navbar from "@/components/landing/Navbar";
import Hero from "@/components/landing/Hero";
import Workflow from "@/components/landing/Workflow";
import Features from "@/components/landing/Features";
import CardDownload from "@/components/landing/CardDownload";
import Footer from "@/components/landing/Footer";

export default function Home() {
  return (
    <main className="min-h-screen bg-white w-full overflow-x-clip">
      <Navbar />
      <Hero />
      <Workflow />
      <Features />
      <CardDownload />
      <Footer />
    </main>
  );
}
