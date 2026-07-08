import { useState } from "react";
import { useTheme } from "../theme";
import { CATEGORIES } from "../data/providers";

interface Props {
  onSelect: (cat: string) => void;
}

export default function CategoryGrid({ onSelect }: Props) {
  const [active, setActive] = useState<string | null>(null);
  const { theme } = useTheme();

  return (
    <div
      style={{
        display: "flex",
        gap: 10,
        padding: "0 20px",
        overflowX: "auto",
        scrollbarWidth: "none",
      }}
    >
      {CATEGORIES.map((cat) => {
        const isActive = active === cat.id;
        return (
          <button
            key={cat.id}
            onClick={() => {
              setActive(cat.id);
              onSelect(cat.id);
            }}
            style={{
              flexShrink: 0,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 6,
              background: isActive ? cat.color + "18" : theme.bgCard,
              border: `1px solid ${isActive ? cat.color + "66" : theme.border}`,
              borderRadius: 16,
              padding: "14px 12px 10px",
              cursor: "pointer",
              transition: "all 0.18s ease",
              minWidth: 72,
              boxShadow: theme.mode === "light" && !isActive ? "0 1px 6px rgba(0,0,0,0.05)" : "none",
            }}
          >
            <div
              style={{
                width: 42,
                height: 42,
                borderRadius: 13,
                background: cat.color + "18",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 20,
                transition: "transform 0.18s",
                transform: isActive ? "scale(1.1)" : "scale(1)",
              }}
            >
              {cat.emoji}
            </div>
            <span
              style={{
                fontSize: 10.5,
                fontWeight: 600,
                color: isActive ? cat.color : theme.textSecondary,
                letterSpacing: "0.01em",
                whiteSpace: "nowrap",
                transition: "color 0.18s",
              }}
            >
              {cat.label}
            </span>
            <span
              style={{
                fontSize: 9,
                color: theme.textMuted,
                letterSpacing: "0.01em",
                whiteSpace: "nowrap",
                transition: "color 0.35s",
              }}
            >
              {cat.sinhala}
            </span>
          </button>
        );
      })}
    </div>
  );
}
