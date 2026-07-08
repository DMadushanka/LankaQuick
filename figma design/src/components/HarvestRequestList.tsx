import { useState } from "react";
import { useTheme } from "../theme";
import { SAMPLE_REQUESTS, PEPPER_TYPES } from "../data/gammiris";
import type { HarvestRequest } from "../data/gammiris";

const PEPPER_COLORS: Record<string, string> = {
  black: "#f59e0b",
  white: "#c9b89a",
  green: "#22c55e",
  mixed: "#a78bfa",
};

const STATUS_CONFIG: Record<HarvestRequest["status"], { label: string; color: string; bg: string }> = {
  pending:   { label: "Available",  color: "#22c55e", bg: "rgba(34,197,94,0.12)" },
  contacted: { label: "In Contact", color: "#f59e0b", bg: "rgba(245,158,11,0.12)" },
  sold:      { label: "Sold",       color: "#94a3b8", bg: "rgba(148,163,184,0.12)" },
};

export default function HarvestRequestList() {
  const { theme } = useTheme();
  const [filter, setFilter] = useState<"all" | string>("all");
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [contactedIds, setContactedIds] = useState<string[]>([]);

  const requests = SAMPLE_REQUESTS.map((r) => ({
    ...r,
    status: contactedIds.includes(r.id) ? "contacted" as const : r.status,
  }));

  const filtered = filter === "all" ? requests : requests.filter((r) => r.pepperType === filter);

  return (
    <div style={{ padding: "16px 20px 0" }}>
      {/* Filter */}
      <div style={{ display: "flex", gap: 8, overflowX: "auto", scrollbarWidth: "none", marginBottom: 16 }}>
        <button
          onClick={() => setFilter("all")}
          style={{
            flexShrink: 0, padding: "5px 14px", borderRadius: 20, fontSize: 11, fontWeight: 700,
            cursor: "pointer",
            border: `1px solid ${filter === "all" ? "#f59e0b" : theme.border}`,
            background: filter === "all" ? "rgba(245,158,11,0.15)" : theme.bgCard,
            color: filter === "all" ? "#f59e0b" : theme.textMuted,
            transition: "all 0.18s",
          }}
        >
          All Listings
        </button>
        {PEPPER_TYPES.map((pt) => (
          <button
            key={pt.id}
            onClick={() => setFilter(pt.id)}
            style={{
              flexShrink: 0, padding: "5px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700,
              cursor: "pointer", display: "flex", alignItems: "center", gap: 5,
              border: `1px solid ${filter === pt.id ? PEPPER_COLORS[pt.id] : theme.border}`,
              background: filter === pt.id ? PEPPER_COLORS[pt.id] + "20" : theme.bgCard,
              color: filter === pt.id ? PEPPER_COLORS[pt.id] : theme.textMuted,
              transition: "all 0.18s",
            }}
          >
            <div style={{ width: 7, height: 7, borderRadius: 4, background: PEPPER_COLORS[pt.id] }} />
            {pt.name.split(" ")[0]}
          </button>
        ))}
      </div>

      {/* Count */}
      <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 12, fontWeight: 600, letterSpacing: "0.04em", transition: "color 0.35s" }}>
        {filtered.length} LISTING{filtered.length !== 1 ? "S" : ""} AVAILABLE
      </div>

      {/* Cards */}
      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
        {filtered.map((req) => {
          const pepperColor = PEPPER_COLORS[req.pepperType];
          const pepperLabel = PEPPER_TYPES.find(p => p.id === req.pepperType)?.name ?? req.pepperType;
          const status = STATUS_CONFIG[req.status];
          const isExpanded = expandedId === req.id;

          return (
            <div
              key={req.id}
              className="animate-fade-up"
              style={{
                background: theme.bgCard, border: `1px solid ${theme.borderCard}`,
                borderRadius: 18, overflow: "hidden",
                boxShadow: theme.mode === "light" ? "0 2px 12px rgba(0,0,0,0.07)" : "none",
                transition: "background 0.35s, border-color 0.35s",
              }}
            >
              {/* Pepper type accent bar */}
              <div style={{ height: 3, background: `linear-gradient(90deg, ${pepperColor}, ${pepperColor}55)` }} />

              <div style={{ padding: "14px 16px" }}>
                {/* Top row */}
                <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 10 }}>
                  {/* Avatar */}
                  <div style={{
                    width: 46, height: 46, borderRadius: 14, flexShrink: 0,
                    background: `linear-gradient(135deg, ${req.avatarColor}, ${req.avatarColor}99)`,
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 18, fontWeight: 800, color: "white",
                  }}>
                    {req.avatar ?? req.farmerName[0]}
                  </div>

                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 2 }}>
                      <span style={{ fontSize: 14, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
                        {req.farmerName}
                      </span>
                      <span style={{
                        fontSize: 9, fontWeight: 700, padding: "2px 7px", borderRadius: 20,
                        background: status.bg, color: status.color, letterSpacing: "0.04em",
                      }}>
                        {status.label}
                      </span>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 4, marginBottom: 4 }}>
                      <svg width="11" height="11" viewBox="0 0 24 24" fill={theme.textMuted} style={{ flexShrink: 0 }}>
                        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
                      </svg>
                      <span style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>
                        {req.location} · {req.district}
                      </span>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                      <div style={{ width: 7, height: 7, borderRadius: 4, background: pepperColor }} />
                      <span style={{ fontSize: 11, fontWeight: 600, color: pepperColor }}>{pepperLabel}</span>
                    </div>
                  </div>

                  {/* Price & qty */}
                  <div style={{ textAlign: "right", flexShrink: 0 }}>
                    <div style={{ fontSize: 18, fontWeight: 800, color: pepperColor, letterSpacing: "-0.03em" }}>
                      Rs.{req.pricePerKg.toLocaleString()}
                    </div>
                    <div style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>per kg</div>
                    <div style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, marginTop: 4, transition: "color 0.35s" }}>
                      {req.quantityKg} kg
                    </div>
                    <div style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>available</div>
                  </div>
                </div>

                {/* Total value row */}
                <div style={{
                  display: "flex", alignItems: "center", justifyContent: "space-between",
                  background: theme.bgInput, borderRadius: 10, padding: "8px 12px", marginBottom: 10,
                  transition: "background 0.35s",
                }}>
                  <div>
                    <span style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>Total Value </span>
                    <span style={{ fontSize: 13, fontWeight: 800, color: theme.textPrimary, transition: "color 0.35s" }}>
                      Rs.{(req.pricePerKg * req.quantityKg).toLocaleString()}
                    </span>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2">
                      <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                    </svg>
                    <span style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>{req.submittedAt}</span>
                  </div>
                </div>

                {/* Expand / collapse */}
                <button
                  onClick={() => setExpandedId(isExpanded ? null : req.id)}
                  style={{
                    width: "100%", padding: "7px 0", borderRadius: 10,
                    border: `1px solid ${theme.border}`,
                    background: "transparent", color: theme.textMuted,
                    fontSize: 11, fontWeight: 600, cursor: "pointer",
                    display: "flex", alignItems: "center", justifyContent: "center", gap: 4,
                    marginBottom: isExpanded ? 10 : 0,
                    transition: "border-color 0.35s, color 0.35s",
                  }}
                >
                  {isExpanded ? "Hide details ↑" : "View details ↓"}
                </button>

                {/* Expanded detail */}
                {isExpanded && (
                  <div className="animate-fade-up">
                    <div style={{
                      background: theme.bgInput, borderRadius: 12, padding: "12px 14px", marginBottom: 10,
                      transition: "background 0.35s",
                    }}>
                      <div style={{ fontSize: 11, color: theme.textMuted, fontWeight: 700, letterSpacing: "0.05em", marginBottom: 8, transition: "color 0.35s" }}>
                        CONTACT DETAILS
                      </div>
                      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2" strokeLinecap="round">
                          <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.56 3.35 2 2 0 0 1 3.53 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9a16 16 0 0 0 6.91 6.91l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
                        </svg>
                        <span style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
                          {req.phone}
                        </span>
                      </div>
                    </div>

                    <div style={{ display: "flex", gap: 8 }}>
                      <a href={`tel:${req.phone}`} style={{ flex: 1 }}>
                        <button style={{
                          width: "100%", padding: "10px 0", borderRadius: 12,
                          border: `1.5px solid ${pepperColor}`,
                          background: pepperColor + "12",
                          color: pepperColor, fontSize: 12, fontWeight: 700, cursor: "pointer",
                          display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                        }}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.56 3.35 2 2 0 0 1 3.53 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9a16 16 0 0 0 6.91 6.91l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
                          </svg>
                          Call Farmer
                        </button>
                      </a>
                      <button
                        onClick={() => setContactedIds((ids) => ids.includes(req.id) ? ids : [...ids, req.id])}
                        style={{
                          flex: 1, padding: "10px 0", borderRadius: 12, border: "none",
                          background: req.status === "contacted"
                            ? "rgba(245,158,11,0.15)"
                            : "linear-gradient(135deg, #f59e0b, #d97706)",
                          color: req.status === "contacted" ? "#f59e0b" : "white",
                          fontSize: 12, fontWeight: 700, cursor: "pointer",
                          display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                          boxShadow: req.status !== "contacted" ? "0 4px 14px rgba(245,158,11,0.3)" : "none",
                          transition: "all 0.2s",
                        }}
                      >
                        {req.status === "contacted" ? "✓ Contacted" : "Make Offer"}
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {filtered.length === 0 && (
        <div style={{ textAlign: "center", padding: "40px 0", color: theme.textMuted }}>
          <div style={{ fontSize: 32, marginBottom: 8 }}>🌾</div>
          <div style={{ fontSize: 14, fontWeight: 600 }}>No listings for this type</div>
        </div>
      )}
    </div>
  );
}
