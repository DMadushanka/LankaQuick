import { useTheme } from "../theme";

interface Props {
  onToggleTheme: () => void;
}

const stats = [
  { label: "Services Used", value: "24" },
  { label: "Providers Saved", value: "8" },
  { label: "Reviews Given", value: "19" },
];

const menuItems = [
  { icon: "🔖", label: "Saved Providers" },
  { icon: "💳", label: "Payment Methods" },
  { icon: "🔔", label: "Notifications" },
  { icon: "🌐", label: "Language / භාෂාව" },
  { icon: "⭐", label: "Rate the App" },
  { icon: "🤝", label: "Refer a Friend" },
  { icon: "❓", label: "Help & Support" },
];

export default function ProfileScreen({ onToggleTheme }: Props) {
  const { theme } = useTheme();
  const isDark = theme.mode === "dark";

  return (
    <div style={{ background: theme.bg, minHeight: "100%", color: theme.textPrimary, transition: "background 0.35s, color 0.35s" }}>
      {/* Header */}
      <div
        style={{
          background: theme.bgHeader,
          padding: "4px 20px 24px",
          textAlign: "center",
          transition: "background 0.35s",
        }}
      >
        <div
          style={{
            width: 72, height: 72, borderRadius: 24,
            background: "linear-gradient(135deg, #f97316, #ea580c)",
            margin: "0 auto 12px",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 28, fontWeight: 800, color: "white",
            boxShadow: "0 8px 24px rgba(249,115,22,0.4)",
          }}
        >
          A
        </div>
        <h2 style={{ margin: "0 0 4px", fontSize: 20, fontWeight: 800, letterSpacing: "-0.03em", color: theme.textPrimary, transition: "color 0.35s" }}>
          Amara Wickramasinghe
        </h2>
        <p style={{ margin: "0 0 16px", fontSize: 13, color: theme.textMuted, transition: "color 0.35s" }}>
          +94 77 123 4567 · Gampaha
        </p>

        {/* Stats */}
        <div style={{ display: "flex", gap: 1 }}>
          {stats.map((s, i) => (
            <div
              key={s.label}
              style={{
                flex: 1, padding: "12px 8px",
                background: theme.bgInput,
                borderRadius: i === 0 ? "12px 0 0 12px" : i === stats.length - 1 ? "0 12px 12px 0" : 0,
                borderRight: i < stats.length - 1 ? `1px solid ${theme.border}` : "none",
                transition: "background 0.35s, border-color 0.35s",
              }}
            >
              <div style={{ fontSize: 20, fontWeight: 800, color: "#f97316", letterSpacing: "-0.04em" }}>
                {s.value}
              </div>
              <div style={{ fontSize: 10, color: theme.textMuted, marginTop: 2, fontWeight: 500, transition: "color 0.35s" }}>
                {s.label}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Settings */}
      <div style={{ padding: "16px 20px" }}>
        {/* Theme toggle — prominent row */}
        <div style={{ fontSize: 11, color: theme.textMuted, fontWeight: 700, letterSpacing: "0.08em", marginBottom: 10, transition: "color 0.35s" }}>
          APPEARANCE
        </div>
        <div
          style={{
            background: theme.bgCard,
            border: `1px solid ${theme.borderCard}`,
            borderRadius: 18,
            overflow: "hidden",
            marginBottom: 16,
            boxShadow: theme.mode === "light" ? "0 2px 12px rgba(0,0,0,0.06)" : "none",
            transition: "background 0.35s, border-color 0.35s",
          }}
        >
          <button
            onClick={onToggleTheme}
            style={{
              width: "100%",
              display: "flex",
              alignItems: "center",
              gap: 12,
              padding: "16px 16px",
              background: "none",
              border: "none",
              cursor: "pointer",
              textAlign: "left",
              color: theme.textPrimary,
            }}
          >
            <span style={{ fontSize: 20, width: 24, textAlign: "center" }}>
              {isDark ? "🌙" : "☀️"}
            </span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600, color: theme.textPrimary, transition: "color 0.35s" }}>
                {isDark ? "Dark Mode" : "Light Mode"}
              </div>
              <div style={{ fontSize: 11, color: theme.textMuted, marginTop: 1, transition: "color 0.35s" }}>
                Tap to switch to {isDark ? "light" : "dark"} theme
              </div>
            </div>
            {/* Toggle pill */}
            <div
              style={{
                width: 50,
                height: 28,
                borderRadius: 14,
                background: isDark ? "#f97316" : "rgba(0,0,0,0.12)",
                position: "relative",
                transition: "background 0.3s",
                flexShrink: 0,
              }}
            >
              <div
                style={{
                  position: "absolute",
                  top: 3,
                  left: isDark ? 25 : 3,
                  width: 22,
                  height: 22,
                  borderRadius: 11,
                  background: "white",
                  boxShadow: "0 2px 6px rgba(0,0,0,0.25)",
                  transition: "left 0.3s ease",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 11,
                }}
              >
                {isDark ? "🌙" : "☀️"}
              </div>
            </div>
          </button>
        </div>

        {/* Menu */}
        <div style={{ fontSize: 11, color: theme.textMuted, fontWeight: 700, letterSpacing: "0.08em", marginBottom: 10, transition: "color 0.35s" }}>
          SETTINGS
        </div>
        <div
          style={{
            background: theme.bgCard,
            border: `1px solid ${theme.borderCard}`,
            borderRadius: 18,
            overflow: "hidden",
            boxShadow: theme.mode === "light" ? "0 2px 12px rgba(0,0,0,0.06)" : "none",
            transition: "background 0.35s, border-color 0.35s",
          }}
        >
          {menuItems.map((item, i) => (
            <button
              key={item.label}
              style={{
                width: "100%",
                display: "flex",
                alignItems: "center",
                gap: 12,
                padding: "14px 16px",
                background: "none",
                border: "none",
                borderBottom: i < menuItems.length - 1 ? `1px solid ${theme.border}` : "none",
                cursor: "pointer",
                textAlign: "left",
                color: theme.textPrimary,
                transition: "border-color 0.35s",
              }}
            >
              <span style={{ fontSize: 18, width: 24, textAlign: "center" }}>{item.icon}</span>
              <span style={{ flex: 1, fontSize: 14, fontWeight: 500, color: theme.textPrimary, transition: "color 0.35s" }}>{item.label}</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2.5">
                <polyline points="9 18 15 12 9 6"/>
              </svg>
            </button>
          ))}
        </div>

        <button
          style={{
            width: "100%",
            marginTop: 16,
            padding: "14px 0",
            borderRadius: 14,
            border: "1px solid rgba(239,68,68,0.25)",
            background: "rgba(239,68,68,0.07)",
            color: "#f87171",
            fontSize: 14,
            fontWeight: 700,
            cursor: "pointer",
          }}
        >
          Sign Out
        </button>

        <p style={{ textAlign: "center", fontSize: 11, color: theme.textMuted, marginTop: 16, transition: "color 0.35s" }}>
          SevaFind v1.0.0 · Made in Sri Lanka 🇱🇰
        </p>
      </div>
    </div>
  );
}
