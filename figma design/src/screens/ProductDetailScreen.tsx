import { useState } from "react";
import { useTheme } from "../theme";
import type { Product, Farmer } from "../data/products";
import FarmerChatScreen from "./FarmerChatScreen";

interface Props {
  product: Product;
  farmer: Farmer;
  inCart: boolean;
  onAddCart: () => void;
  onBack: () => void;
}

export default function ProductDetailScreen({ product, farmer, inCart, onAddCart, onBack }: Props) {
  const { theme } = useTheme();
  const [qty, setQty] = useState(product.minOrder);
  const [chatOpen, setChatOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<"details" | "farmer">("details");

  if (chatOpen) {
    return <FarmerChatScreen farmer={farmer} product={product} onBack={() => setChatOpen(false)} />;
  }

  const total = qty * product.price;

  return (
    <div style={{ background: theme.bg, minHeight: "100%", display: "flex", flexDirection: "column", transition: "background 0.35s" }}>
      {/* Hero image */}
      <div style={{ position: "relative", height: 260, background: theme.mode === "dark" ? "#1a2a1a" : "#e8f5e9", flexShrink: 0 }}>
        <img
          src={product.image}
          alt={product.name}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
        {/* Gradient overlay */}
        <div style={{
          position: "absolute", inset: 0,
          background: "linear-gradient(to bottom, rgba(0,0,0,0.35) 0%, transparent 40%, rgba(0,0,0,0.2) 100%)",
        }} />

        {/* Back button */}
        <button
          onClick={onBack}
          style={{
            position: "absolute", top: 16, left: 16,
            width: 36, height: 36, borderRadius: 12,
            background: "rgba(0,0,0,0.4)",
            backdropFilter: "blur(8px)",
            border: "1px solid rgba(255,255,255,0.2)",
            display: "flex", alignItems: "center", justifyContent: "center",
            cursor: "pointer", color: "white",
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>

        {/* Share */}
        <button style={{
          position: "absolute", top: 16, right: 16,
          width: 36, height: 36, borderRadius: 12,
          background: "rgba(0,0,0,0.4)", backdropFilter: "blur(8px)",
          border: "1px solid rgba(255,255,255,0.2)",
          display: "flex", alignItems: "center", justifyContent: "center",
          cursor: "pointer", color: "white",
        }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
            <circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/>
            <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
            <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
          </svg>
        </button>

        {/* Tags at bottom of image */}
        <div style={{ position: "absolute", bottom: 12, left: 16, display: "flex", gap: 6 }}>
          {product.organic && (
            <div style={{
              background: "#22c55e", borderRadius: 6, padding: "3px 9px",
              fontSize: 10, fontWeight: 800, color: "white", letterSpacing: "0.05em",
            }}>ORGANIC</div>
          )}
          {product.tags.map((tag) => (
            <div key={tag} style={{
              background: "rgba(0,0,0,0.5)", backdropFilter: "blur(4px)",
              borderRadius: 6, padding: "3px 9px",
              fontSize: 10, fontWeight: 600, color: "white",
            }}>{tag}</div>
          ))}
        </div>
      </div>

      {/* Scrollable content */}
      <div style={{ flex: 1, overflowY: "auto", scrollbarWidth: "none" }}>
        <div style={{ padding: "18px 20px 0" }}>
          {/* Name & price */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 8 }}>
            <div style={{ flex: 1, paddingRight: 12 }}>
              <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 3, fontWeight: 600, transition: "color 0.35s" }}>
                {product.nameSinhala} · {product.category}
              </div>
              <h1 style={{ margin: 0, fontSize: 20, fontWeight: 800, letterSpacing: "-0.03em", color: theme.textPrimary, lineHeight: 1.2, transition: "color 0.35s" }}>
                {product.name}
              </h1>
            </div>
            <div style={{ textAlign: "right", flexShrink: 0 }}>
              <div style={{ fontSize: 22, fontWeight: 800, color: "#22c55e", letterSpacing: "-0.03em" }}>
                Rs.{product.price}
              </div>
              <div style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>per {product.unit}</div>
            </div>
          </div>

          {/* Rating + freshness row */}
          <div style={{ display: "flex", gap: 12, marginBottom: 18, flexWrap: "wrap" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
              <span style={{ color: "#fbbf24" }}>★</span>
              <span style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{product.rating}</span>
              <span style={{ fontSize: 12, color: theme.textMuted, transition: "color 0.35s" }}>({product.reviews} reviews)</span>
            </div>
            <div style={{
              display: "flex", alignItems: "center", gap: 4,
              background: "rgba(34,197,94,0.1)", borderRadius: 20, padding: "3px 10px",
            }}>
              <div style={{ width: 6, height: 6, borderRadius: 3, background: "#22c55e" }} />
              <span style={{ fontSize: 11, fontWeight: 600, color: "#22c55e" }}>{product.freshness}</span>
            </div>
          </div>

          {/* Tabs */}
          <div style={{
            display: "flex", background: theme.bgTab, borderRadius: 12, padding: 4, marginBottom: 16,
            transition: "background 0.35s",
          }}>
            {(["details", "farmer"] as const).map((t) => (
              <button key={t} onClick={() => setActiveTab(t)} style={{
                flex: 1, padding: "8px 0", borderRadius: 9, border: "none",
                background: activeTab === t ? "#22c55e" : "transparent",
                color: activeTab === t ? "white" : theme.textMuted,
                fontSize: 13, fontWeight: 700, cursor: "pointer",
                transition: "all 0.2s", textTransform: "capitalize",
              }}>
                {t === "details" ? "Product" : "Farmer"}
              </button>
            ))}
          </div>

          {activeTab === "details" ? (
            <div>
              {/* Description */}
              <p style={{ fontSize: 13, lineHeight: 1.65, color: theme.textSecondary, marginBottom: 18, transition: "color 0.35s" }}>
                {product.description}
              </p>

              {/* Info grid */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 18 }}>
                {[
                  { label: "Harvest Cycle", value: product.harvest, icon: "🔄" },
                  { label: "Stock", value: `${product.stock} ${product.unit}s`, icon: "📦" },
                  { label: "Min. Order", value: `${product.minOrder} ${product.unit}`, icon: "🛒" },
                  { label: "Certified", value: product.organic ? "Organic" : "Conventional", icon: "🌿" },
                ].map((item) => (
                  <div key={item.label} style={{
                    background: theme.bgCard, border: `1px solid ${theme.border}`,
                    borderRadius: 12, padding: "12px 14px",
                    boxShadow: theme.mode === "light" ? "0 1px 6px rgba(0,0,0,0.05)" : "none",
                    transition: "background 0.35s, border-color 0.35s",
                  }}>
                    <div style={{ fontSize: 16, marginBottom: 4 }}>{item.icon}</div>
                    <div style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, marginBottom: 1, transition: "color 0.35s" }}>
                      {item.value}
                    </div>
                    <div style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>{item.label}</div>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <div>
              {/* Farmer card */}
              <div style={{
                background: theme.bgCard, border: `1px solid ${theme.border}`,
                borderRadius: 16, padding: "16px", marginBottom: 16,
                boxShadow: theme.mode === "light" ? "0 2px 10px rgba(0,0,0,0.06)" : "none",
                transition: "background 0.35s, border-color 0.35s",
              }}>
                <div style={{ display: "flex", gap: 12, alignItems: "flex-start", marginBottom: 14 }}>
                  <div style={{
                    width: 56, height: 56, borderRadius: 18,
                    background: `linear-gradient(135deg, ${farmer.avatarColor}, ${farmer.avatarColor}99)`,
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 22, fontWeight: 800, color: "white", flexShrink: 0,
                  }}>
                    {farmer.avatar}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
                      <span style={{ fontSize: 16, fontWeight: 800, color: theme.textPrimary, transition: "color 0.35s" }}>
                        {farmer.name}
                      </span>
                      {farmer.verified && (
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="#22c55e">
                          <path d="M9 12l2 2 4-4M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/>
                        </svg>
                      )}
                    </div>
                    <div style={{ fontSize: 12, color: theme.textMuted, marginBottom: 6, transition: "color 0.35s" }}>
                      📍 {farmer.location} · Farming since {farmer.since}
                    </div>
                    <div style={{ display: "flex", gap: 12 }}>
                      <div style={{ fontSize: 12 }}>
                        <span style={{ fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{farmer.rating}</span>
                        <span style={{ color: "#fbbf24" }}> ★</span>
                        <span style={{ color: theme.textMuted, transition: "color 0.35s" }}> rating</span>
                      </div>
                      <div style={{ fontSize: 12 }}>
                        <span style={{ fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{farmer.totalSales.toLocaleString()}</span>
                        <span style={{ color: theme.textMuted, transition: "color 0.35s" }}> sales</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Stats */}
                <div style={{ display: "flex", gap: 1, marginBottom: 14 }}>
                  {[
                    { label: "Response", value: "< 2 hrs" },
                    { label: "On-time", value: "98%" },
                    { label: "Repeat buyers", value: "76%" },
                  ].map((s, i) => (
                    <div key={s.label} style={{
                      flex: 1, padding: "10px 6px", textAlign: "center",
                      background: theme.bgInput, transition: "background 0.35s",
                      borderRadius: i === 0 ? "10px 0 0 10px" : i === 2 ? "0 10px 10px 0" : 0,
                    }}>
                      <div style={{ fontSize: 13, fontWeight: 800, color: "#22c55e" }}>{s.value}</div>
                      <div style={{ fontSize: 9, color: theme.textMuted, marginTop: 1, transition: "color 0.35s" }}>{s.label}</div>
                    </div>
                  ))}
                </div>

                {/* Chat CTA */}
                <button
                  onClick={() => setChatOpen(true)}
                  style={{
                    width: "100%",
                    padding: "12px 0",
                    borderRadius: 12,
                    border: "1.5px solid #22c55e",
                    background: "rgba(34,197,94,0.08)",
                    color: "#22c55e",
                    fontSize: 14, fontWeight: 700, cursor: "pointer",
                    display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                  }}
                >
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                  </svg>
                  Chat with {farmer.name.split(" ")[0]}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Bottom CTA */}
      <div style={{
        padding: "12px 20px 16px",
        background: theme.navBg, backdropFilter: "blur(20px)",
        borderTop: `1px solid ${theme.navBorder}`,
        flexShrink: 0, transition: "background 0.35s, border-color 0.35s",
      }}>
        {/* Quantity selector */}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
          <span style={{ fontSize: 13, color: theme.textMuted, transition: "color 0.35s" }}>Quantity ({product.unit})</span>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <button
              onClick={() => setQty(Math.max(product.minOrder, qty - 1))}
              style={{
                width: 32, height: 32, borderRadius: 10, border: `1px solid ${theme.border}`,
                background: theme.bgCard, color: theme.textPrimary, fontSize: 16, fontWeight: 600,
                cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center",
                transition: "background 0.35s",
              }}
            >−</button>
            <span style={{ fontSize: 16, fontWeight: 800, color: theme.textPrimary, minWidth: 20, textAlign: "center", transition: "color 0.35s" }}>
              {qty}
            </span>
            <button
              onClick={() => setQty(qty + 1)}
              style={{
                width: 32, height: 32, borderRadius: 10, border: "none",
                background: "#22c55e", color: "white", fontSize: 16, fontWeight: 600,
                cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center",
                boxShadow: "0 2px 8px rgba(34,197,94,0.35)",
              }}
            >+</button>
          </div>
        </div>

        <div style={{ display: "flex", gap: 10 }}>
          {/* Chat shortcut */}
          <button
            onClick={() => setChatOpen(true)}
            style={{
              width: 48, height: 48, borderRadius: 14, flexShrink: 0,
              border: `1.5px solid #22c55e`,
              background: "rgba(34,197,94,0.08)",
              display: "flex", alignItems: "center", justifyContent: "center",
              cursor: "pointer", color: "#22c55e",
            }}
          >
            <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            </svg>
          </button>

          {/* Add to cart */}
          <button
            onClick={onAddCart}
            style={{
              flex: 1, padding: "14px 0", borderRadius: 14, border: "none",
              background: inCart ? "rgba(34,197,94,0.15)" : "linear-gradient(135deg, #22c55e, #16a34a)",
              color: inCart ? "#22c55e" : "white",
              fontSize: 15, fontWeight: 800, cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
              boxShadow: inCart ? "none" : "0 6px 20px rgba(34,197,94,0.35)",
              transition: "all 0.2s",
            }}
          >
            {inCart ? (
              <>✓ Added to Cart</>
            ) : (
              <>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                  <line x1="3" y1="6" x2="21" y2="6"/>
                  <path d="M16 10a4 4 0 0 1-8 0"/>
                </svg>
                Add · Rs.{total.toLocaleString()}
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
