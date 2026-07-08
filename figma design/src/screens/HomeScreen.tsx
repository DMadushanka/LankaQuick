import { useState } from "react";
import { useTheme } from "../theme";
import CategoryGrid from "../components/CategoryGrid";
import ProviderCard from "../components/ProviderCard";
import { PROVIDERS } from "../data/providers";

interface Props {
  onCategorySelect: (cat: string) => void;
}

export default function HomeScreen({ onCategorySelect }: Props) {
  const [search, setSearch] = useState("");
  const { theme } = useTheme();
  const featured = PROVIDERS.slice(0, 4);

  return (
    <div style={{ background: theme.bg, minHeight: "100%", color: theme.textPrimary, transition: "background 0.35s, color 0.35s" }}>
      {/* Header */}
      <div style={{ padding: "4px 20px 20px", background: theme.bgHeader, transition: "background 0.35s" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 20 }}>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 4 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="#f97316" stroke="none">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
              </svg>
              <span style={{ color: theme.textMuted, fontSize: 12, fontWeight: 500, transition: "color 0.35s" }}>
                Gampaha, Western Province
              </span>
            </div>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, lineHeight: 1.2, letterSpacing: "-0.03em", color: theme.textPrimary, transition: "color 0.35s" }}>
              Find Local <span style={{ color: "#f97316" }}>Experts</span>
            </h1>
          </div>
          <div
            style={{
              width: 40,
              height: 40,
              borderRadius: 20,
              background: "linear-gradient(135deg, #f97316, #ea580c)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 15,
              fontWeight: 700,
              color: "white",
              flexShrink: 0,
              boxShadow: "0 4px 12px rgba(249,115,22,0.3)",
            }}
          >
            A
          </div>
        </div>

        {/* Search */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            background: theme.bgInput,
            border: `1px solid ${theme.border}`,
            borderRadius: 14,
            padding: "11px 14px",
            transition: "background 0.35s, border-color 0.35s",
          }}
        >
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2.5">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.35-4.35"/>
          </svg>
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search services or providers..."
            style={{
              flex: 1,
              background: "none",
              border: "none",
              outline: "none",
              color: theme.textPrimary,
              fontSize: 14,
              fontFamily: "inherit",
            }}
          />
          <div
            style={{
              background: "#f97316",
              borderRadius: 9,
              padding: "5px 10px",
              fontSize: 11,
              fontWeight: 700,
              color: "white",
              letterSpacing: "0.03em",
              whiteSpace: "nowrap",
            }}
          >
            Filter
          </div>
        </div>
      </div>

      <div style={{ padding: "0 0 16px" }}>
        {/* Stats row */}
        <div style={{ display: "flex", gap: 10, padding: "16px 20px", overflowX: "auto", scrollbarWidth: "none" }}>
          {[
            { label: "Providers Nearby", value: "148", color: "#f97316" },
            { label: "Avg Response", value: "12 min", color: "#a78bfa" },
            { label: "Avg Rating", value: "4.8 ★", color: "#34d399" },
          ].map((s) => (
            <div
              key={s.label}
              style={{
                flexShrink: 0,
                background: theme.bgCard,
                border: `1px solid ${theme.border}`,
                borderRadius: 14,
                padding: "12px 16px",
                minWidth: 100,
                boxShadow: theme.mode === "light" ? "0 2px 8px rgba(0,0,0,0.06)" : "none",
                transition: "background 0.35s, border-color 0.35s",
              }}
            >
              <div style={{ fontSize: 18, fontWeight: 800, color: s.color, letterSpacing: "-0.03em" }}>
                {s.value}
              </div>
              <div style={{ fontSize: 11, color: theme.textMuted, marginTop: 2, fontWeight: 500, transition: "color 0.35s" }}>
                {s.label}
              </div>
            </div>
          ))}
        </div>

        {/* Categories */}
        <div style={{ padding: "0 20px 4px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <h2 style={{ margin: 0, fontSize: 16, fontWeight: 700, letterSpacing: "-0.02em", color: theme.textPrimary, transition: "color 0.35s" }}>
              Categories
            </h2>
            <button style={{ background: "none", border: "none", color: "#f97316", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
              See all
            </button>
          </div>
        </div>
        <CategoryGrid onSelect={onCategorySelect} />

        {/* Nearby Providers */}
        <div style={{ padding: "20px 20px 0" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <h2 style={{ margin: 0, fontSize: 16, fontWeight: 700, letterSpacing: "-0.02em", color: theme.textPrimary, transition: "color 0.35s" }}>
              Nearby Providers
            </h2>
            <button style={{ background: "none", border: "none", color: "#f97316", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
              See all
            </button>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {featured.map((p, i) => (
              <ProviderCard key={p.id} provider={p} delay={i * 60} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
