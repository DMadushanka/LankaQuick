import { useTheme } from "../theme";
import type { Tab } from "../App";

interface Props {
  activeTab: Tab;
  onTabChange: (tab: Tab) => void;
}

const tabs: { id: Tab; label: string; accent: string; icon: (active: boolean, color: string) => React.ReactNode }[] = [
  {
    id: "home", label: "Home", accent: "#f97316",
    icon: (active, c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill={active ? c : "none"} stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
        <polyline points="9 22 9 12 15 12 15 22"/>
      </svg>
    ),
  },
  {
    id: "map", label: "Nearby", accent: "#f97316",
    icon: (active, c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill={active ? c : "none"} stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="3 11 22 2 13 21 11 13 3 11"/>
      </svg>
    ),
  },
  {
    id: "market", label: "Market", accent: "#22c55e",
    icon: (active, c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.5 : 2} strokeLinecap="round" strokeLinejoin="round">
        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" fill={active ? c + "28" : "none"}/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 0 1-8 0"/>
      </svg>
    ),
  },
  {
    id: "gammiris", label: "ගම්මිරිස්", accent: "#f59e0b",
    icon: (active, c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.5 : 2} strokeLinecap="round" strokeLinejoin="round">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" stroke={active ? c : "currentColor"}/>
      </svg>
    ),
  },
  {
    id: "profile", label: "Profile", accent: "#f97316",
    icon: (active, _c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.5 : 2} strokeLinecap="round" strokeLinejoin="round">
        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
        <circle cx="12" cy="7" r="4"/>
      </svg>
    ),
  },
];

export default function BottomNav({ activeTab, onTabChange }: Props) {
  const { theme } = useTheme();

  return (
    <div style={{
      display: "flex",
      borderTop: `1px solid ${theme.navBorder}`,
      background: theme.navBg,
      backdropFilter: "blur(20px)",
      flexShrink: 0,
      paddingBottom: 2,
      transition: "background 0.35s, border-color 0.35s",
    }}>
      {tabs.map((tab) => {
        const active = tab.id === activeTab;
        const accent = tab.accent;
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            style={{
              flex: 1,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              gap: 2,
              padding: "8px 0 6px",
              background: "none",
              border: "none",
              cursor: "pointer",
              color: active ? accent : theme.navInactive,
              transition: "color 0.2s",
              position: "relative",
            }}
          >
            {active && (
              <div style={{
                position: "absolute", top: 0, left: "50%",
                transform: "translateX(-50%)",
                width: 24, height: 2, borderRadius: 1,
                background: accent,
              }} />
            )}
            <div style={{ transform: active ? "scale(1.08)" : "scale(1)", transition: "transform 0.2s" }}>
              {tab.icon(active, accent)}
            </div>
            <span style={{
              fontSize: tab.id === "gammiris" ? 8 : 9.5,
              fontWeight: active ? 700 : 500,
              letterSpacing: "0.01em",
              lineHeight: 1.2,
              textAlign: "center",
            }}>
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
