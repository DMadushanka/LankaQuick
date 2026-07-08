import { useState } from "react";
import { useTheme } from "../theme";
import { PROVIDERS, CATEGORIES, type Provider } from "../data/providers";
import ProviderCard from "../components/ProviderCard";

interface Props {
  selectedCategory: string | null;
}

const MAP_PINS = PROVIDERS.map((p, i) => ({
  ...p,
  x: 20 + ((i * 47) % 70),
  y: 15 + ((i * 61) % 65),
}));

const AVATAR_COLORS = ["#f97316", "#a78bfa", "#34d399", "#3b82f6", "#f472b6", "#22d3ee", "#fb923c", "#4ade80"];

export default function MapScreen({ selectedCategory }: Props) {
  const [activePin, setActivePin] = useState<Provider | null>(null);
  const [filterCat, setFilterCat] = useState<string | null>(selectedCategory);
  const { theme } = useTheme();

  const visiblePins = filterCat
    ? MAP_PINS.filter((p) => p.categoryKey === filterCat)
    : MAP_PINS;

  const activeCat = CATEGORIES.find((c) => c.id === filterCat);

  const roadColor = theme.mode === "dark" ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.08)";
  const blockColor = theme.mode === "dark" ? "rgba(255,255,255,0.025)" : "rgba(0,0,0,0.04)";

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: theme.bg, transition: "background 0.35s" }}>
      {/* Top bar */}
      <div style={{ padding: "4px 16px 12px", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
          <div>
            <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 2, transition: "color 0.35s" }}>Showing providers near</div>
            <div style={{ fontSize: 16, fontWeight: 800, color: theme.textPrimary, letterSpacing: "-0.03em", transition: "color 0.35s" }}>
              Your Location
            </div>
          </div>
          <div
            style={{
              background: "rgba(249,115,22,0.12)",
              border: "1px solid rgba(249,115,22,0.3)",
              borderRadius: 10,
              padding: "6px 12px",
              fontSize: 12,
              fontWeight: 700,
              color: "#f97316",
            }}
          >
            {visiblePins.length} nearby
          </div>
        </div>

        {/* Filter chips */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", scrollbarWidth: "none" }}>
          <button
            onClick={() => setFilterCat(null)}
            style={{
              flexShrink: 0,
              padding: "6px 14px",
              borderRadius: 20,
              border: `1px solid ${!filterCat ? "#f97316" : theme.border}`,
              background: !filterCat ? "rgba(249,115,22,0.12)" : theme.bgCard,
              color: !filterCat ? "#f97316" : theme.textMuted,
              fontSize: 12,
              fontWeight: 600,
              cursor: "pointer",
              transition: "background 0.35s, border-color 0.35s, color 0.35s",
            }}
          >
            All
          </button>
          {CATEGORIES.slice(0, 6).map((cat) => (
            <button
              key={cat.id}
              onClick={() => setFilterCat(cat.id === filterCat ? null : cat.id)}
              style={{
                flexShrink: 0,
                padding: "6px 12px",
                borderRadius: 20,
                border: `1px solid ${filterCat === cat.id ? cat.color + "88" : theme.border}`,
                background: filterCat === cat.id ? cat.color + "18" : theme.bgCard,
                color: filterCat === cat.id ? cat.color : theme.textMuted,
                fontSize: 12,
                fontWeight: 600,
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                gap: 4,
                transition: "background 0.35s",
              }}
            >
              <span style={{ fontSize: 13 }}>{cat.emoji}</span>
              {cat.label}
            </button>
          ))}
        </div>
      </div>

      {/* Map */}
      <div
        style={{
          flex: "0 0 300px",
          position: "relative",
          overflow: "hidden",
          margin: "0 16px",
          borderRadius: 20,
          border: `1px solid ${theme.border}`,
          transition: "border-color 0.35s",
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 0,
            background: theme.bgMap,
            backgroundImage: `
              linear-gradient(${theme.mode === "dark" ? "rgba(255,255,255,0.03)" : "rgba(0,0,0,0.04)"} 1px, transparent 1px),
              linear-gradient(90deg, ${theme.mode === "dark" ? "rgba(255,255,255,0.03)" : "rgba(0,0,0,0.04)"} 1px, transparent 1px)
            `,
            backgroundSize: "40px 40px",
            transition: "background 0.35s",
          }}
        />

        <svg style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }} viewBox="0 0 358 300">
          <line x1="0" y1="150" x2="358" y2="150" stroke={roadColor} strokeWidth="12"/>
          <line x1="179" y1="0" x2="179" y2="300" stroke={roadColor} strokeWidth="10"/>
          <line x1="0" y1="80" x2="358" y2="180" stroke={roadColor} strokeWidth="8"/>
          <line x1="80" y1="0" x2="300" y2="300" stroke={roadColor} strokeWidth="6"/>
          <line x1="0" y1="220" x2="358" y2="80" stroke={roadColor} strokeWidth="5"/>
          {[0,40,80,120,160,200,240,280,320].map(x => (
            <line key={x} x1={x} y1="150" x2={x+24} y2="150"
              stroke={theme.mode === "dark" ? "rgba(255,255,255,0.08)" : "rgba(0,0,0,0.1)"}
              strokeWidth="1.5" strokeDasharray="16 8"/>
          ))}
          <rect x="20" y="20" width="90" height="50" rx="4" fill={blockColor}/>
          <rect x="130" y="20" width="80" height="55" rx="4" fill={blockColor}/>
          <rect x="230" y="30" width="100" height="40" rx="4" fill={blockColor}/>
          <rect x="20" y="170" width="70" height="60" rx="4" fill={blockColor}/>
          <rect x="120" y="175" width="95" height="50" rx="4" fill={blockColor}/>
          <rect x="250" y="165" width="85" height="70" rx="4" fill={blockColor}/>
        </svg>

        {/* User location */}
        <div style={{ position: "absolute", left: "50%", top: "50%", transform: "translate(-50%, -50%)", zIndex: 10 }}>
          <div className="pulse-ring" style={{
            width: 52, height: 52, borderRadius: 26,
            background: "rgba(249,115,22,0.15)",
            border: "2px solid rgba(249,115,22,0.4)",
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <div style={{
              width: 18, height: 18, borderRadius: 9,
              background: "#f97316",
              border: "3px solid white",
              boxShadow: "0 2px 8px rgba(249,115,22,0.6)",
            }} />
          </div>
        </div>

        {/* Provider pins */}
        {visiblePins.map((pin) => {
          const color = AVATAR_COLORS[parseInt(pin.id) % AVATAR_COLORS.length];
          const isActive = activePin?.id === pin.id;
          const cat = CATEGORIES.find(c => c.id === pin.categoryKey);
          return (
            <button
              key={pin.id}
              onClick={() => setActivePin(isActive ? null : pin)}
              className="map-pin-anim"
              style={{
                position: "absolute",
                left: `${pin.x}%`,
                top: `${pin.y}%`,
                transform: "translate(-50%, -100%)",
                background: "none", border: "none", cursor: "pointer",
                zIndex: isActive ? 20 : 5,
                animationDelay: `${parseInt(pin.id) * 0.3}s`,
              }}
            >
              <div style={{
                background: isActive ? color : theme.bgCard,
                border: `2px solid ${color}`,
                borderRadius: isActive ? 12 : 20,
                padding: isActive ? "4px 8px" : "5px 7px",
                display: "flex", alignItems: "center", gap: 4,
                boxShadow: `0 4px 16px ${color}44`,
                transition: "all 0.2s",
                whiteSpace: "nowrap",
              }}>
                <span style={{ fontSize: isActive ? 11 : 13 }}>{cat?.emoji}</span>
                {isActive && (
                  <span style={{ fontSize: 10, fontWeight: 700, color: "white" }}>{pin.name.split(" ")[0]}</span>
                )}
              </div>
              <div style={{
                width: 0, height: 0,
                borderLeft: "5px solid transparent",
                borderRight: "5px solid transparent",
                borderTop: `6px solid ${color}`,
                margin: "0 auto",
              }} />
            </button>
          );
        })}

        <div style={{
          position: "absolute", bottom: 0, left: 0, right: 0, height: 60,
          background: theme.mode === "dark"
            ? "linear-gradient(transparent, rgba(18,18,26,0.8))"
            : "linear-gradient(transparent, rgba(245,245,247,0.8))",
          pointerEvents: "none",
          transition: "background 0.35s",
        }} />

        <div style={{ position: "absolute", right: 12, bottom: 16, display: "flex", flexDirection: "column", gap: 4 }}>
          {["+", "−"].map((btn) => (
            <button key={btn} style={{
              width: 32, height: 32, borderRadius: 10,
              background: theme.bgCard,
              border: `1px solid ${theme.border}`,
              color: theme.textPrimary,
              fontSize: 16, fontWeight: 600, cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center",
              boxShadow: theme.mode === "light" ? "0 2px 8px rgba(0,0,0,0.08)" : "none",
              transition: "background 0.35s",
            }}>{btn}</button>
          ))}
        </div>
      </div>

      {/* Pin detail / list */}
      <div style={{ flex: 1, padding: "12px 16px", overflowY: "auto", scrollbarWidth: "none" }}>
        {activePin ? (
          <div className="animate-fade-up">
            <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 8, fontWeight: 600, transition: "color 0.35s" }}>
              SELECTED PROVIDER
            </div>
            <ProviderCard provider={activePin} />
          </div>
        ) : (
          <>
            <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 8, fontWeight: 600, transition: "color 0.35s" }}>
              {filterCat ? `${activeCat?.label.toUpperCase()} PROVIDERS` : "ALL NEARBY"} — TAP PIN TO SELECT
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              {visiblePins.slice(0, 3).map((p, i) => (
                <ProviderCard key={p.id} provider={p} delay={i * 50} />
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
