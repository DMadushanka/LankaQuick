import { useState } from "react";
import { useTheme } from "../theme";
import {
  DISTRICT_PRICES, WEEKLY_TREND, PEPPER_TYPES, SAMPLE_REQUESTS,
  type DistrictPrice,
} from "../data/gammiris";
import PriceChartSection from "../components/PriceChartSection";
import HarvestRequestForm from "../components/HarvestRequestForm";
import HarvestRequestList from "../components/HarvestRequestList";

type ScreenTab = "prices" | "submit" | "requests";

export default function GammirisScreen() {
  const { theme } = useTheme();
  const [tab, setTab] = useState<ScreenTab>("prices");
  const [selectedDistrict, setSelectedDistrict] = useState<DistrictPrice | null>(null);

  const avgBlack = Math.round(DISTRICT_PRICES.reduce((s, d) => s + d.black, 0) / DISTRICT_PRICES.length);
  const avgWhite = Math.round(DISTRICT_PRICES.reduce((s, d) => s + d.white, 0) / DISTRICT_PRICES.length);
  const latestTrend = WEEKLY_TREND[WEEKLY_TREND.length - 1];
  const prevTrend    = WEEKLY_TREND[WEEKLY_TREND.length - 2];
  const weeklyChange = (((latestTrend.black - prevTrend.black) / prevTrend.black) * 100).toFixed(1);

  return (
    <div style={{ background: theme.bg, minHeight: "100%", transition: "background 0.35s" }}>
      {/* Header */}
      <div style={{ padding: "4px 20px 0", background: theme.bgHeader, transition: "background 0.35s" }}>
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 3, fontWeight: 500, transition: "color 0.35s" }}>
            Live Market Data · Updated today
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, letterSpacing: "-0.03em", color: theme.textPrimary, transition: "color 0.35s" }}>
              ගම්මිරිස් <span style={{ color: "#f59e0b" }}>මිල</span>
            </h1>
            <div style={{
              background: "rgba(245,158,11,0.12)", border: "1px solid rgba(245,158,11,0.3)",
              borderRadius: 10, padding: "5px 10px", fontSize: 11, fontWeight: 700, color: "#f59e0b",
            }}>
              Jul 2026
            </div>
          </div>
          <div style={{ fontSize: 13, color: theme.textSecondary, marginTop: 2, transition: "color 0.35s" }}>
            Pepper Price Tracker
          </div>
        </div>

        {/* KPI strip */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", scrollbarWidth: "none", marginBottom: 16 }}>
          {[
            { label: "Avg Black", value: `Rs.${avgBlack.toLocaleString()}`, sub: "/kg", color: "#f59e0b", icon: "⬛" },
            { label: "Avg White", value: `Rs.${avgWhite.toLocaleString()}`, sub: "/kg", color: "#c9b89a", icon: "⬜" },
            { label: "Week Change", value: `+${weeklyChange}%`, sub: "black", color: "#22c55e", icon: "📈" },
            { label: "Districts", value: `${DISTRICT_PRICES.length}`, sub: "tracked", color: "#a78bfa", icon: "📍" },
          ].map((k) => (
            <div key={k.label} style={{
              flexShrink: 0,
              background: theme.bgCard, border: `1px solid ${theme.border}`,
              borderRadius: 14, padding: "10px 14px",
              boxShadow: theme.mode === "light" ? "0 2px 8px rgba(0,0,0,0.06)" : "none",
              transition: "background 0.35s, border-color 0.35s",
            }}>
              <div style={{ fontSize: 14, marginBottom: 2 }}>{k.icon}</div>
              <div style={{ fontSize: 15, fontWeight: 800, color: k.color, letterSpacing: "-0.03em" }}>{k.value}</div>
              <div style={{ fontSize: 10, color: theme.textMuted, marginTop: 1, transition: "color 0.35s" }}>
                {k.label} <span style={{ opacity: 0.6 }}>{k.sub}</span>
              </div>
            </div>
          ))}
        </div>

        {/* Tab bar */}
        <div style={{ display: "flex", gap: 0, borderBottom: `1px solid ${theme.border}`, transition: "border-color 0.35s" }}>
          {([
            { id: "prices",   label: "📊 Prices",   },
            { id: "submit",   label: "🌿 Sell Now",  },
            { id: "requests", label: "📋 Listings",  },
          ] as { id: ScreenTab; label: string }[]).map((t) => (
            <button key={t.id} onClick={() => setTab(t.id)} style={{
              flex: 1, padding: "10px 0 11px", background: "none", border: "none",
              borderBottom: tab === t.id ? "2.5px solid #f59e0b" : "2.5px solid transparent",
              color: tab === t.id ? "#f59e0b" : theme.textMuted,
              fontSize: 11.5, fontWeight: 700, cursor: "pointer",
              transition: "color 0.2s, border-color 0.2s", letterSpacing: "0.01em",
            }}>
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab content */}
      <div style={{ paddingBottom: 20 }}>
        {tab === "prices" && (
          <PriceChartSection
            selectedDistrict={selectedDistrict}
            onSelectDistrict={setSelectedDistrict}
          />
        )}
        {tab === "submit" && <HarvestRequestForm onSubmitted={() => setTab("requests")} />}
        {tab === "requests" && <HarvestRequestList />}
      </div>
    </div>
  );
}
