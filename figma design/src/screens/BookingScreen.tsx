import { useState } from "react";
import { useTheme } from "../theme";

const bookings = [
  { id: "b1", provider: "Kamal Perera", service: "Plumbing", emoji: "🔧", date: "Today, 2:30 PM", status: "upcoming", price: "Rs. 1,500", color: "#3b82f6" },
  { id: "b2", provider: "Chamari Silva", service: "House Cleaning", emoji: "🧹", date: "Yesterday, 10:00 AM", status: "completed", price: "Rs. 2,400", color: "#34d399" },
  { id: "b3", provider: "Nuwan Jayasinghe", service: "Electrical", emoji: "⚡", date: "Jul 3, 9:00 AM", status: "completed", price: "Rs. 3,000", color: "#f59e0b" },
  { id: "b4", provider: "Dilini Fernando", service: "Salon & Beauty", emoji: "💇", date: "Jul 10, 4:00 PM", status: "upcoming", price: "Rs. 800", color: "#f472b6" },
];

export default function BookingScreen() {
  const [tab, setTab] = useState<"upcoming" | "completed">("upcoming");
  const { theme } = useTheme();
  const filtered = bookings.filter((b) => b.status === tab);

  return (
    <div style={{ background: theme.bg, minHeight: "100%", color: theme.textPrimary, padding: "4px 20px 20px", transition: "background 0.35s, color 0.35s" }}>
      <h1 style={{ fontSize: 22, fontWeight: 800, letterSpacing: "-0.03em", marginBottom: 4, color: theme.textPrimary, transition: "color 0.35s" }}>
        My Bookings
      </h1>
      <p style={{ fontSize: 13, color: theme.textMuted, margin: "0 0 20px", transition: "color 0.35s" }}>
        Track and manage your service requests
      </p>

      {/* Tabs */}
      <div
        style={{
          display: "flex",
          background: theme.bgTab,
          borderRadius: 12,
          padding: 4,
          marginBottom: 20,
          transition: "background 0.35s",
        }}
      >
        {(["upcoming", "completed"] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            style={{
              flex: 1,
              padding: "9px 0",
              borderRadius: 9,
              border: "none",
              background: tab === t ? "#f97316" : "transparent",
              color: tab === t ? "white" : theme.textMuted,
              fontSize: 13,
              fontWeight: 700,
              cursor: "pointer",
              textTransform: "capitalize",
              transition: "all 0.2s",
              letterSpacing: "0.01em",
            }}
          >
            {t}
          </button>
        ))}
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
        {filtered.length === 0 && (
          <div style={{ textAlign: "center", padding: "40px 0", color: theme.textMuted, fontSize: 14, transition: "color 0.35s" }}>
            No {tab} bookings
          </div>
        )}
        {filtered.map((b) => (
          <div
            key={b.id}
            className="animate-fade-up"
            style={{
              background: theme.bgCard,
              border: `1px solid ${theme.borderCard}`,
              borderRadius: 18,
              padding: "16px",
              position: "relative",
              overflow: "hidden",
              boxShadow: theme.mode === "light" ? "0 2px 12px rgba(0,0,0,0.06)" : "none",
              transition: "background 0.35s, border-color 0.35s",
            }}
          >
            <div style={{ position: "absolute", left: 0, top: 16, bottom: 16, width: 3, borderRadius: 2, background: b.color }} />

            <div style={{ display: "flex", alignItems: "flex-start", gap: 12, paddingLeft: 10 }}>
              <div
                style={{
                  width: 44, height: 44, borderRadius: 13,
                  background: b.color + "18",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 20, flexShrink: 0,
                }}
              >
                {b.emoji}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 2, color: theme.textPrimary, transition: "color 0.35s" }}>{b.provider}</div>
                <div style={{ fontSize: 12, color: theme.textMuted, marginBottom: 8, transition: "color 0.35s" }}>{b.service}</div>
                <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2">
                    <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                  </svg>
                  <span style={{ fontSize: 12, color: theme.textMuted, transition: "color 0.35s" }}>{b.date}</span>
                </div>
              </div>
              <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 8 }}>
                <span style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{b.price}</span>
                <span style={{
                  fontSize: 10, fontWeight: 700, padding: "3px 9px", borderRadius: 20,
                  background: b.status === "upcoming" ? "rgba(249,115,22,0.12)" : "rgba(34,197,94,0.1)",
                  color: b.status === "upcoming" ? "#f97316" : "#22c55e",
                  letterSpacing: "0.04em", textTransform: "uppercase",
                }}>
                  {b.status}
                </span>
              </div>
            </div>

            {b.status === "upcoming" && (
              <div style={{ display: "flex", gap: 8, marginTop: 12, paddingLeft: 10 }}>
                <button style={{
                  flex: 1, padding: "8px 0", borderRadius: 10,
                  border: `1px solid ${theme.border}`,
                  background: "transparent",
                  color: theme.textSecondary,
                  fontSize: 12, fontWeight: 600, cursor: "pointer",
                  transition: "border-color 0.35s, color 0.35s",
                }}>
                  Reschedule
                </button>
                <button style={{
                  flex: 1, padding: "8px 0", borderRadius: 10, border: "none",
                  background: "linear-gradient(135deg, #f97316, #ea580c)",
                  color: "white", fontSize: 12, fontWeight: 700, cursor: "pointer",
                }}>
                  Message
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
