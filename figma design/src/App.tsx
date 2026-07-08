import { useState } from "react";
import HomeScreen from "./screens/HomeScreen";
import MapScreen from "./screens/MapScreen";
import BookingScreen from "./screens/BookingScreen";
import ProfileScreen from "./screens/ProfileScreen";
import MarketScreen from "./screens/MarketScreen";
import GammirisScreen from "./screens/GammirisScreen";
import BottomNav from "./components/BottomNav";
import { ThemeContext, dark, light } from "./theme";
import "./app.css";

export type Tab = "home" | "map" | "market" | "gammiris" | "profile";

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>("home");
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [themeMode, setThemeMode] = useState<"dark" | "light">("dark");

  const theme = themeMode === "dark" ? dark : light;
  const toggle = () => setThemeMode((m) => (m === "dark" ? "light" : "dark"));

  const renderScreen = () => {
    switch (activeTab) {
      case "home":
        return (
          <HomeScreen
            onCategorySelect={(cat) => {
              setSelectedCategory(cat);
              setActiveTab("map");
            }}
          />
        );
      case "map":
        return <MapScreen selectedCategory={selectedCategory} />;
      case "market":
        return <MarketScreen />;
      case "gammiris":
        return <GammirisScreen />;
      case "profile":
        return <ProfileScreen onToggleTheme={toggle} />;
    }
  };

  return (
    <ThemeContext.Provider value={{ theme, toggle }}>
      <div
        className="app-shell"
        style={{
          background: themeMode === "dark"
            ? "radial-gradient(ellipse 80% 60% at 50% 0%, #1e1430 0%, #0f0f14 70%)"
            : "radial-gradient(ellipse 80% 60% at 50% 0%, #ffe8d6 0%, #e8e8f0 70%)",
          transition: "background 0.35s ease",
        }}
      >
        <div
          className="phone-frame"
          style={{
            background: theme.bg,
            boxShadow: themeMode === "dark"
              ? "0 0 0 1px rgba(255,255,255,0.08), 0 0 0 10px #1a1a24, 0 0 0 11px rgba(255,255,255,0.05), 0 40px 100px rgba(0,0,0,0.7)"
              : "0 0 0 1px rgba(0,0,0,0.1), 0 0 0 10px #d8d8e0, 0 0 0 11px rgba(0,0,0,0.06), 0 40px 100px rgba(0,0,0,0.25)",
            transition: "background 0.35s ease, box-shadow 0.35s ease",
          }}
        >
          {/* Status bar */}
          <div className="status-bar" style={{ color: theme.statusBar, transition: "color 0.35s" }}>
            <span>9:41</span>
            <div className="status-icons">
              <svg width="16" height="11" viewBox="0 0 16 11" fill="currentColor">
                <rect x="0" y="4" width="3" height="7" rx="0.5" opacity="0.4"/>
                <rect x="4.5" y="2.5" width="3" height="8.5" rx="0.5" opacity="0.7"/>
                <rect x="9" y="0.5" width="3" height="10.5" rx="0.5"/>
                <rect x="14" y="3" width="2" height="5" rx="0.5" opacity="0.3"/>
              </svg>
              <svg width="15" height="11" viewBox="0 0 15 11" fill="currentColor">
                <path d="M7.5 2.5C9.8 2.5 11.9 3.4 13.4 4.9L14.8 3.5C12.9 1.6 10.3 0.5 7.5 0.5C4.7 0.5 2.1 1.6 0.2 3.5L1.6 4.9C3.1 3.4 5.2 2.5 7.5 2.5Z" opacity="0.5"/>
                <path d="M7.5 5.5C9 5.5 10.3 6.1 11.3 7.1L12.7 5.7C11.3 4.3 9.5 3.5 7.5 3.5C5.5 3.5 3.7 4.3 2.3 5.7L3.7 7.1C4.7 6.1 6 5.5 7.5 5.5Z" opacity="0.75"/>
                <circle cx="7.5" cy="9.5" r="1.5"/>
              </svg>
              <svg width="25" height="12" viewBox="0 0 25 12" fill="currentColor">
                <rect x="0.5" y="0.5" width="21" height="11" rx="3.5" stroke="currentColor" strokeOpacity="0.35" fill="none"/>
                <rect x="2" y="2" width="16" height="8" rx="2" fill="currentColor"/>
                <path d="M23 4v4a2 2 0 0 0 0-4z" opacity="0.4"/>
              </svg>
            </div>
          </div>

          {/* Screen content */}
          <div className="screen-content">
            {renderScreen()}
          </div>

          {/* Bottom nav */}
          <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />

          {/* Home indicator */}
          <div className="home-indicator">
            <div
              className="home-bar"
              style={{ background: themeMode === "dark" ? "rgba(255,255,255,0.25)" : "rgba(0,0,0,0.18)" }}
            />
          </div>
        </div>
      </div>
    </ThemeContext.Provider>
  );
}
