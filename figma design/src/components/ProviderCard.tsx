import { useState } from "react";
import { useTheme } from "../theme";
import type { Provider } from "../data/providers";

interface Props {
  provider: Provider;
  delay?: number;
}

const AVATAR_COLORS = ["#f97316", "#a78bfa", "#34d399", "#3b82f6", "#f472b6", "#22d3ee", "#fb923c", "#4ade80"];

export default function ProviderCard({ provider, delay = 0 }: Props) {
  const [hired, setHired] = useState(false);
  const { theme } = useTheme();
  const color = AVATAR_COLORS[parseInt(provider.id) % AVATAR_COLORS.length];

  return (
    <div
      className="animate-fade-up"
      style={{
        background: theme.bgCard,
        border: `1px solid ${theme.borderCard}`,
        borderRadius: 18,
        padding: "14px 16px",
        display: "flex",
        alignItems: "center",
        gap: 12,
        animationDelay: `${delay}ms`,
        boxShadow: theme.mode === "light" ? "0 2px 12px rgba(0,0,0,0.06)" : "none",
        transition: "background 0.35s, border-color 0.35s",
      }}
    >
      {/* Avatar */}
      <div style={{ position: "relative", flexShrink: 0 }}>
        <div
          style={{
            width: 52,
            height: 52,
            borderRadius: 16,
            background: `linear-gradient(135deg, ${color}, ${color}99)`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 20,
            fontWeight: 800,
            color: "white",
          }}
        >
          {provider.avatar}
        </div>
        {provider.available && (
          <div
            style={{
              position: "absolute",
              bottom: 2,
              right: 2,
              width: 11,
              height: 11,
              borderRadius: 6,
              background: "#22c55e",
              border: `2px solid ${theme.bg}`,
              transition: "border-color 0.35s",
            }}
          />
        )}
      </div>

      {/* Info */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 2 }}>
          <span style={{ fontSize: 14, fontWeight: 700, color: theme.textPrimary, letterSpacing: "-0.02em", transition: "color 0.35s" }}>
            {provider.name}
          </span>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="#3b82f6" style={{ flexShrink: 0 }}>
            <path d="M9 12l2 2 4-4M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/>
          </svg>
        </div>
        <div style={{ fontSize: 12, color: theme.textMuted, marginBottom: 6, transition: "color 0.35s" }}>
          {provider.category} · {provider.distance} away
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 3 }}>
            <span style={{ color: "#fbbf24", fontSize: 11 }}>★</span>
            <span style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{provider.rating}</span>
            <span style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>({provider.reviews})</span>
          </div>
          <span style={{ color: theme.textMuted, fontSize: 10 }}>·</span>
          <span style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>{provider.jobs} jobs</span>
        </div>
      </div>

      {/* Right side */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 8, flexShrink: 0 }}>
        <span style={{ fontSize: 11, fontWeight: 600, color: theme.textSecondary, transition: "color 0.35s" }}>
          {provider.price}
        </span>
        <button
          onClick={() => setHired(!hired)}
          style={{
            padding: "7px 14px",
            borderRadius: 10,
            border: "none",
            background: hired
              ? "rgba(34,197,94,0.12)"
              : "linear-gradient(135deg, #f97316, #ea580c)",
            color: hired ? "#22c55e" : "white",
            fontSize: 12,
            fontWeight: 700,
            cursor: "pointer",
            transition: "all 0.2s",
            letterSpacing: "0.01em",
          }}
        >
          {hired ? "✓ Hired" : "Hire"}
        </button>
      </div>
    </div>
  );
}
