import { useState } from "react";
import { useTheme } from "../theme";
import { PRODUCTS, CATEGORIES_MARKET, FARMERS } from "../data/products";
import ProductDetailScreen from "./ProductDetailScreen";
import type { Product } from "../data/products";

export default function MarketScreen() {
  const { theme } = useTheme();
  const [activeCategory, setActiveCategory] = useState("all");
  const [search, setSearch] = useState("");
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [cart, setCart] = useState<string[]>([]);

  const filtered = PRODUCTS.filter((p) => {
    const matchCat = activeCategory === "all" || p.category === activeCategory;
    const matchSearch = p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.nameSinhala.includes(search);
    return matchCat && matchSearch;
  });

  const featured = PRODUCTS.filter((p) => p.featured);

  if (selectedProduct) {
    return (
      <ProductDetailScreen
        product={selectedProduct}
        farmer={FARMERS.find((f) => f.id === selectedProduct.farmerId)!}
        inCart={cart.includes(selectedProduct.id)}
        onAddCart={() => setCart((c) => c.includes(selectedProduct.id) ? c : [...c, selectedProduct.id])}
        onBack={() => setSelectedProduct(null)}
      />
    );
  }

  return (
    <div style={{ background: theme.bg, minHeight: "100%", transition: "background 0.35s" }}>
      {/* Header */}
      <div style={{ padding: "4px 20px 16px", background: theme.bgHeader, transition: "background 0.35s" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 16 }}>
          <div>
            <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 3, fontWeight: 500, transition: "color 0.35s" }}>
              Farm-to-Table Direct
            </div>
            <h1 style={{ margin: 0, fontSize: 22, fontWeight: 800, letterSpacing: "-0.03em", color: theme.textPrimary, transition: "color 0.35s" }}>
              Fresh <span style={{ color: "#22c55e" }}>Market</span>
            </h1>
          </div>
          <div style={{ position: "relative" }}>
            <button style={{
              width: 40, height: 40, borderRadius: 13,
              background: theme.bgCard,
              border: `1px solid ${theme.border}`,
              display: "flex", alignItems: "center", justifyContent: "center",
              cursor: "pointer",
              boxShadow: theme.mode === "light" ? "0 2px 8px rgba(0,0,0,0.07)" : "none",
              transition: "background 0.35s",
            }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={theme.textPrimary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
              </svg>
            </button>
            {cart.length > 0 && (
              <div style={{
                position: "absolute", top: -4, right: -4,
                width: 18, height: 18, borderRadius: 9,
                background: "#22c55e",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 10, fontWeight: 800, color: "white",
              }}>
                {cart.length}
              </div>
            )}
          </div>
        </div>

        {/* Search */}
        <div style={{
          display: "flex", alignItems: "center", gap: 10,
          background: theme.bgInput, border: `1px solid ${theme.border}`,
          borderRadius: 14, padding: "11px 14px",
          transition: "background 0.35s, border-color 0.35s",
        }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke={theme.textMuted} strokeWidth="2.5">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search products or farmers..."
            style={{ flex: 1, background: "none", border: "none", outline: "none", color: theme.textPrimary, fontSize: 14, fontFamily: "inherit" }}
          />
        </div>
      </div>

      <div style={{ paddingBottom: 16 }}>
        {/* Category filter */}
        <div style={{ display: "flex", gap: 8, padding: "14px 20px 0", overflowX: "auto", scrollbarWidth: "none" }}>
          {CATEGORIES_MARKET.map((cat) => {
            const active = cat.id === activeCategory;
            return (
              <button
                key={cat.id}
                onClick={() => setActiveCategory(cat.id)}
                style={{
                  flexShrink: 0,
                  padding: "7px 14px",
                  borderRadius: 20,
                  border: `1px solid ${active ? "#22c55e" : theme.border}`,
                  background: active ? "#22c55e" : theme.bgCard,
                  color: active ? "white" : theme.textSecondary,
                  fontSize: 12, fontWeight: 600, cursor: "pointer",
                  display: "flex", alignItems: "center", gap: 5,
                  transition: "all 0.18s",
                  boxShadow: active ? "0 4px 12px rgba(34,197,94,0.3)" : "none",
                }}
              >
                <span>{cat.emoji}</span> {cat.label}
              </button>
            );
          })}
        </div>

        {/* Featured banner — only when viewing all */}
        {activeCategory === "all" && !search && (
          <div style={{ padding: "16px 20px 0" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
              <h2 style={{ margin: 0, fontSize: 15, fontWeight: 700, letterSpacing: "-0.02em", color: theme.textPrimary, transition: "color 0.35s" }}>
                ✨ Featured Today
              </h2>
              <span style={{ fontSize: 11, color: theme.textMuted }}>Freshest picks</span>
            </div>
            <div style={{ display: "flex", gap: 12, overflowX: "auto", scrollbarWidth: "none" }}>
              {featured.map((p) => {
                const farmer = FARMERS.find((f) => f.id === p.farmerId)!;
                return (
                  <button
                    key={p.id}
                    onClick={() => setSelectedProduct(p)}
                    style={{
                      flexShrink: 0,
                      width: 180,
                      background: "none",
                      border: "none",
                      padding: 0,
                      cursor: "pointer",
                      textAlign: "left",
                      borderRadius: 18,
                      overflow: "hidden",
                    }}
                  >
                    <div style={{
                      width: 180, height: 130,
                      borderRadius: 16,
                      overflow: "hidden",
                      position: "relative",
                      background: "#1a2a1a",
                    }}>
                      <img
                        src={p.image}
                        alt={p.name}
                        style={{ width: "100%", height: "100%", objectFit: "cover" }}
                      />
                      <div style={{
                        position: "absolute", inset: 0,
                        background: "linear-gradient(to top, rgba(0,0,0,0.6) 0%, transparent 60%)",
                      }} />
                      {p.organic && (
                        <div style={{
                          position: "absolute", top: 8, left: 8,
                          background: "#22c55e",
                          borderRadius: 6, padding: "2px 7px",
                          fontSize: 9, fontWeight: 800, color: "white", letterSpacing: "0.06em",
                        }}>
                          ORGANIC
                        </div>
                      )}
                      <div style={{
                        position: "absolute", bottom: 8, left: 10, right: 10,
                        display: "flex", justifyContent: "space-between", alignItems: "flex-end",
                      }}>
                        <div>
                          <div style={{ fontSize: 13, fontWeight: 700, color: "white", lineHeight: 1.2 }}>{p.name}</div>
                          <div style={{ fontSize: 10, color: "rgba(255,255,255,0.7)" }}>{farmer.location}</div>
                        </div>
                        <div style={{ fontSize: 13, fontWeight: 800, color: "#86efac" }}>
                          Rs.{p.price}
                        </div>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* Products grid */}
        <div style={{ padding: "16px 20px 0" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <h2 style={{ margin: 0, fontSize: 15, fontWeight: 700, letterSpacing: "-0.02em", color: theme.textPrimary, transition: "color 0.35s" }}>
              {activeCategory === "all" ? "All Products" : activeCategory}
              <span style={{ fontSize: 12, fontWeight: 500, color: theme.textMuted, marginLeft: 6 }}>
                ({filtered.length})
              </span>
            </h2>
            <button style={{ background: "none", border: "none", color: "#22c55e", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
              Sort ↕
            </button>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
            {filtered.map((p) => {
              const farmer = FARMERS.find((f) => f.id === p.farmerId)!;
              const inCart = cart.includes(p.id);
              return (
                <button
                  key={p.id}
                  onClick={() => setSelectedProduct(p)}
                  className="animate-fade-up"
                  style={{
                    background: theme.bgCard,
                    border: `1px solid ${theme.borderCard}`,
                    borderRadius: 16,
                    padding: 0,
                    cursor: "pointer",
                    textAlign: "left",
                    overflow: "hidden",
                    boxShadow: theme.mode === "light" ? "0 2px 10px rgba(0,0,0,0.07)" : "none",
                    transition: "background 0.35s, border-color 0.35s",
                  }}
                >
                  {/* Product image */}
                  <div style={{
                    width: "100%",
                    height: 130,
                    position: "relative",
                    background: theme.mode === "dark" ? "#1a2a1a" : "#e8f5e9",
                    overflow: "hidden",
                  }}>
                    <img
                      src={p.image}
                      alt={p.name}
                      style={{ width: "100%", height: "100%", objectFit: "cover" }}
                    />
                    {p.organic && (
                      <div style={{
                        position: "absolute", top: 7, left: 7,
                        background: "#22c55e",
                        borderRadius: 5, padding: "2px 6px",
                        fontSize: 8, fontWeight: 800, color: "white", letterSpacing: "0.05em",
                      }}>
                        ORGANIC
                      </div>
                    )}
                    {inCart && (
                      <div style={{
                        position: "absolute", top: 7, right: 7,
                        background: "rgba(34,197,94,0.9)",
                        borderRadius: 12, width: 22, height: 22,
                        display: "flex", alignItems: "center", justifyContent: "center",
                        fontSize: 11, color: "white",
                      }}>✓</div>
                    )}
                  </div>

                  {/* Product info */}
                  <div style={{ padding: "10px 12px 12px" }}>
                    <div style={{ fontSize: 8, color: theme.textMuted, fontWeight: 600, letterSpacing: "0.05em", marginBottom: 3, transition: "color 0.35s" }}>
                      {p.nameSinhala} · {farmer.location}
                    </div>
                    <div style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, lineHeight: 1.3, marginBottom: 6, transition: "color 0.35s" }}>
                      {p.name}
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 3, marginBottom: 8 }}>
                      <span style={{ color: "#fbbf24", fontSize: 10 }}>★</span>
                      <span style={{ fontSize: 11, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{p.rating}</span>
                      <span style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>({p.reviews})</span>
                    </div>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <div>
                        <span style={{ fontSize: 15, fontWeight: 800, color: "#22c55e" }}>
                          Rs.{p.price}
                        </span>
                        <span style={{ fontSize: 10, color: theme.textMuted, marginLeft: 2, transition: "color 0.35s" }}>/{p.unit}</span>
                      </div>
                      <div
                        onClick={(e) => {
                          e.stopPropagation();
                          setCart((c) => c.includes(p.id) ? c : [...c, p.id]);
                        }}
                        style={{
                          width: 28, height: 28, borderRadius: 9,
                          background: inCart ? "rgba(34,197,94,0.15)" : "#22c55e",
                          display: "flex", alignItems: "center", justifyContent: "center",
                          cursor: "pointer",
                          transition: "background 0.2s",
                        }}
                      >
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round">
                          {inCart ? <polyline points="20 6 9 17 4 12"/> : <><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></>}
                        </svg>
                      </div>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          {filtered.length === 0 && (
            <div style={{ textAlign: "center", padding: "40px 0", color: theme.textMuted }}>
              <div style={{ fontSize: 32, marginBottom: 8 }}>🌱</div>
              <div style={{ fontSize: 14, fontWeight: 600 }}>No products found</div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
