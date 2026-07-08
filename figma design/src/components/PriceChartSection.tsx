import { useState } from "react";
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend,
} from "recharts";
import { useTheme } from "../theme";
import { DISTRICT_PRICES, WEEKLY_TREND, PEPPER_TYPES, type DistrictPrice } from "../data/gammiris";

interface Props {
  selectedDistrict: DistrictPrice | null;
  onSelectDistrict: (d: DistrictPrice | null) => void;
}

type ChartType = "trend" | "district";
type PepperFilter = "black" | "white" | "green" | "all";

const PEPPER_COLORS: Record<string, string> = {
  black: "#f59e0b",
  white: "#c9b89a",
  green: "#22c55e",
  mixed: "#a78bfa",
};

function CustomTooltipTrend({ active, payload, label, theme }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{
      background: theme.bgCard, border: `1px solid ${theme.border}`,
      borderRadius: 12, padding: "10px 14px",
      boxShadow: "0 8px 24px rgba(0,0,0,0.2)",
    }}>
      <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 6, fontWeight: 600 }}>{label}</div>
      {payload.map((p: any) => (
        <div key={p.dataKey} style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
          <div style={{ width: 8, height: 8, borderRadius: 4, background: p.color }} />
          <span style={{ fontSize: 12, color: theme.textPrimary, fontWeight: 600 }}>
            Rs.{p.value.toLocaleString()}
          </span>
          <span style={{ fontSize: 11, color: theme.textMuted }}>{p.name}</span>
        </div>
      ))}
    </div>
  );
}

function CustomTooltipDistrict({ active, payload, label, theme }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{
      background: theme.bgCard, border: `1px solid ${theme.border}`,
      borderRadius: 12, padding: "10px 14px",
      boxShadow: "0 8px 24px rgba(0,0,0,0.2)",
    }}>
      <div style={{ fontSize: 11, color: theme.textMuted, marginBottom: 6, fontWeight: 600 }}>{label}</div>
      {payload.map((p: any) => (
        <div key={p.dataKey} style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
          <div style={{ width: 8, height: 8, borderRadius: 4, background: p.fill }} />
          <span style={{ fontSize: 12, color: theme.textPrimary, fontWeight: 600 }}>
            Rs.{p.value.toLocaleString()}
          </span>
          <span style={{ fontSize: 11, color: theme.textMuted }}>{p.name}</span>
        </div>
      ))}
    </div>
  );
}

export default function PriceChartSection({ selectedDistrict, onSelectDistrict }: Props) {
  const { theme } = useTheme();
  const [chartType, setChartType] = useState<ChartType>("trend");
  const [pepperFilter, setPepperFilter] = useState<PepperFilter>("black");
  const isDark = theme.mode === "dark";

  const gridColor = isDark ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.07)";
  const axisColor = theme.textMuted;

  const districtBarData = DISTRICT_PRICES.map((d) => ({
    name: d.district.slice(0, 6),
    fullName: d.district,
    sinhala: d.districtSinhala,
    Black: d.black,
    White: d.white,
    Green: d.green,
  }));

  return (
    <div>
      {/* Chart type toggle */}
      <div style={{ padding: "16px 20px 0" }}>
        <div style={{
          display: "flex", background: theme.bgTab, borderRadius: 12, padding: 4, marginBottom: 16,
          transition: "background 0.35s",
        }}>
          {([
            { id: "trend",    label: "📈 Price Trend" },
            { id: "district", label: "🗺️ By District" },
          ] as { id: ChartType; label: string }[]).map((ct) => (
            <button key={ct.id} onClick={() => setChartType(ct.id)} style={{
              flex: 1, padding: "9px 0", borderRadius: 9, border: "none",
              background: chartType === ct.id ? "#f59e0b" : "transparent",
              color: chartType === ct.id ? "white" : theme.textMuted,
              fontSize: 12, fontWeight: 700, cursor: "pointer", transition: "all 0.2s",
            }}>
              {ct.label}
            </button>
          ))}
        </div>

        {/* Pepper type pills */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", scrollbarWidth: "none", marginBottom: 16 }}>
          <button
            onClick={() => setPepperFilter("all")}
            style={{
              flexShrink: 0, padding: "5px 14px", borderRadius: 20, fontSize: 11, fontWeight: 700,
              cursor: "pointer",
              border: `1px solid ${pepperFilter === "all" ? "#f59e0b" : theme.border}`,
              background: pepperFilter === "all" ? "rgba(245,158,11,0.15)" : theme.bgCard,
              color: pepperFilter === "all" ? "#f59e0b" : theme.textMuted,
              transition: "all 0.18s",
            }}
          >
            All Types
          </button>
          {PEPPER_TYPES.map((pt) => (
            <button
              key={pt.id}
              onClick={() => setPepperFilter(pt.id as PepperFilter)}
              style={{
                flexShrink: 0, padding: "5px 12px", borderRadius: 20, fontSize: 11, fontWeight: 700,
                cursor: "pointer", display: "flex", alignItems: "center", gap: 5,
                border: `1px solid ${pepperFilter === pt.id ? PEPPER_COLORS[pt.id] : theme.border}`,
                background: pepperFilter === pt.id ? PEPPER_COLORS[pt.id] + "20" : theme.bgCard,
                color: pepperFilter === pt.id ? PEPPER_COLORS[pt.id] : theme.textMuted,
                transition: "all 0.18s",
              }}
            >
              <div style={{ width: 7, height: 7, borderRadius: 4, background: PEPPER_COLORS[pt.id] }} />
              {pt.name.split(" ")[0]}
            </button>
          ))}
        </div>
      </div>

      {/* Chart */}
      {chartType === "trend" ? (
        <div style={{ padding: "0 4px" }}>
          <div style={{ paddingLeft: 20, marginBottom: 8 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
              Weekly Price Trend
            </div>
            <div style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>
              May – Jul 2026 · Rs. per kg
            </div>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={WEEKLY_TREND} margin={{ top: 4, right: 16, left: -10, bottom: 0 }}>
              <defs>
                <linearGradient id="gBlack" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#f59e0b" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#f59e0b" stopOpacity={0}/>
                </linearGradient>
                <linearGradient id="gWhite" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#c9b89a" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#c9b89a" stopOpacity={0}/>
                </linearGradient>
                <linearGradient id="gGreen" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#22c55e" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#22c55e" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke={gridColor} vertical={false}/>
              <XAxis dataKey="week" tick={{ fontSize: 9, fill: axisColor }} tickLine={false} axisLine={false}/>
              <YAxis tick={{ fontSize: 9, fill: axisColor }} tickLine={false} axisLine={false}
                tickFormatter={(v) => `${(v/1000).toFixed(1)}k`}/>
              <Tooltip content={<CustomTooltipTrend theme={theme} />}/>
              {(pepperFilter === "black" || pepperFilter === "all") && (
                <Area type="monotone" dataKey="black" name="Black" stroke="#f59e0b" strokeWidth={2.5}
                  fill="url(#gBlack)" dot={false} activeDot={{ r: 4, fill: "#f59e0b" }}/>
              )}
              {(pepperFilter === "white" || pepperFilter === "all") && (
                <Area type="monotone" dataKey="white" name="White" stroke="#c9b89a" strokeWidth={2.5}
                  fill="url(#gWhite)" dot={false} activeDot={{ r: 4, fill: "#c9b89a" }}/>
              )}
              {(pepperFilter === "green" || pepperFilter === "all") && (
                <Area type="monotone" dataKey="green" name="Green" stroke="#22c55e" strokeWidth={2.5}
                  fill="url(#gGreen)" dot={false} activeDot={{ r: 4, fill: "#22c55e" }}/>
              )}
            </AreaChart>
          </ResponsiveContainer>
        </div>
      ) : (
        <div style={{ padding: "0 4px" }}>
          <div style={{ paddingLeft: 20, marginBottom: 8 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
              Price by District
            </div>
            <div style={{ fontSize: 11, color: theme.textMuted, transition: "color 0.35s" }}>
              Current rates · Rs. per kg
            </div>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={districtBarData} margin={{ top: 4, right: 16, left: -10, bottom: 0 }} barSize={6}>
              <CartesianGrid strokeDasharray="3 3" stroke={gridColor} vertical={false}/>
              <XAxis dataKey="name" tick={{ fontSize: 9, fill: axisColor }} tickLine={false} axisLine={false}/>
              <YAxis tick={{ fontSize: 9, fill: axisColor }} tickLine={false} axisLine={false}
                tickFormatter={(v) => `${(v/1000).toFixed(1)}k`} domain={[1500, 2700]}/>
              <Tooltip content={<CustomTooltipDistrict theme={theme} />}/>
              {(pepperFilter === "black" || pepperFilter === "all") && (
                <Bar dataKey="Black" name="Black" fill="#f59e0b" radius={[3,3,0,0]}/>
              )}
              {(pepperFilter === "white" || pepperFilter === "all") && (
                <Bar dataKey="White" name="White" fill="#c9b89a" radius={[3,3,0,0]}/>
              )}
              {(pepperFilter === "green" || pepperFilter === "all") && (
                <Bar dataKey="Green" name="Green" fill="#22c55e" radius={[3,3,0,0]}/>
              )}
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* District price table */}
      <div style={{ padding: "20px 20px 0" }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: theme.textPrimary, marginBottom: 12, transition: "color 0.35s" }}>
          District Price Table
        </div>

        {/* Table header */}
        <div style={{
          display: "grid", gridTemplateColumns: "1fr 60px 60px 60px 60px",
          padding: "8px 14px", borderRadius: "10px 10px 0 0",
          background: isDark ? "rgba(245,158,11,0.1)" : "rgba(245,158,11,0.08)",
          border: `1px solid ${theme.border}`,
          borderBottom: "none",
        }}>
          {["District", "Black", "White", "Green", "Trend"].map((h) => (
            <div key={h} style={{ fontSize: 9.5, fontWeight: 800, color: "#f59e0b", letterSpacing: "0.06em" }}>{h}</div>
          ))}
        </div>

        {/* Rows */}
        <div style={{
          border: `1px solid ${theme.border}`, borderRadius: "0 0 14px 14px", overflow: "hidden",
          transition: "border-color 0.35s",
        }}>
          {DISTRICT_PRICES.map((d, i) => {
            const isSelected = selectedDistrict?.district === d.district;
            return (
              <button
                key={d.district}
                onClick={() => onSelectDistrict(isSelected ? null : d)}
                style={{
                  width: "100%", display: "grid", gridTemplateColumns: "1fr 60px 60px 60px 60px",
                  padding: "11px 14px", background: "none", border: "none",
                  borderBottom: i < DISTRICT_PRICES.length - 1 ? `1px solid ${theme.border}` : "none",
                  cursor: "pointer", textAlign: "left",
                  background: isSelected
                    ? (isDark ? "rgba(245,158,11,0.08)" : "rgba(245,158,11,0.06)")
                    : i % 2 === 0 ? "transparent" : (isDark ? "rgba(255,255,255,0.015)" : "rgba(0,0,0,0.015)"),
                  transition: "background 0.2s",
                }}
              >
                <div>
                  <div style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
                    {d.district}
                  </div>
                  <div style={{ fontSize: 9, color: theme.textMuted, transition: "color 0.35s" }}>{d.districtSinhala}</div>
                </div>
                <div style={{ fontSize: 11, fontWeight: 700, color: "#f59e0b" }}>
                  {(d.black/1000).toFixed(2)}k
                </div>
                <div style={{ fontSize: 11, fontWeight: 700, color: "#c9b89a" }}>
                  {(d.white/1000).toFixed(2)}k
                </div>
                <div style={{ fontSize: 11, fontWeight: 700, color: "#22c55e" }}>
                  {(d.green/1000).toFixed(2)}k
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 3 }}>
                  <span style={{ fontSize: 13 }}>
                    {d.trend === "up" ? "↑" : d.trend === "down" ? "↓" : "→"}
                  </span>
                  <span style={{
                    fontSize: 10, fontWeight: 700,
                    color: d.trend === "up" ? "#22c55e" : d.trend === "down" ? "#f87171" : theme.textMuted,
                    transition: "color 0.35s",
                  }}>
                    {d.change > 0 ? "+" : ""}{d.change}%
                  </span>
                </div>
              </button>
            );
          })}
        </div>

        {/* Selected district detail */}
        {selectedDistrict && (
          <div
            className="animate-fade-up"
            style={{
              marginTop: 12,
              background: theme.bgCard, border: `1.5px solid rgba(245,158,11,0.35)`,
              borderRadius: 16, padding: "14px 16px",
              boxShadow: "0 4px 20px rgba(245,158,11,0.12)",
              transition: "background 0.35s",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
              <div>
                <div style={{ fontSize: 16, fontWeight: 800, color: theme.textPrimary, transition: "color 0.35s" }}>
                  {selectedDistrict.district}
                </div>
                <div style={{ fontSize: 12, color: theme.textMuted, transition: "color 0.35s" }}>
                  {selectedDistrict.districtSinhala} · Detailed Rates
                </div>
              </div>
              <div style={{
                display: "flex", alignItems: "center", gap: 4,
                background: selectedDistrict.trend === "up" ? "rgba(34,197,94,0.12)" : "rgba(248,113,113,0.12)",
                borderRadius: 20, padding: "4px 10px",
              }}>
                <span style={{ fontSize: 14 }}>{selectedDistrict.trend === "up" ? "↑" : selectedDistrict.trend === "down" ? "↓" : "→"}</span>
                <span style={{
                  fontSize: 12, fontWeight: 700,
                  color: selectedDistrict.trend === "up" ? "#22c55e" : selectedDistrict.trend === "down" ? "#f87171" : theme.textMuted,
                }}>
                  {selectedDistrict.change > 0 ? "+" : ""}{selectedDistrict.change}% this week
                </span>
              </div>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
              {[
                { label: "Black Pepper", key: "black",  color: "#f59e0b", sinhala: "කළු" },
                { label: "White Pepper", key: "white",  color: "#c9b89a", sinhala: "සුදු" },
                { label: "Green Pepper", key: "green",  color: "#22c55e", sinhala: "කොළ" },
                { label: "Mixed Grade",  key: "mixed",  color: "#a78bfa", sinhala: "මිශ්‍ර" },
              ].map((item) => (
                <div key={item.key} style={{
                  background: item.color + "12", border: `1px solid ${item.color}30`,
                  borderRadius: 12, padding: "10px 12px",
                }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 5, marginBottom: 4 }}>
                    <div style={{ width: 8, height: 8, borderRadius: 4, background: item.color }} />
                    <span style={{ fontSize: 10, color: theme.textMuted, fontWeight: 600, transition: "color 0.35s" }}>
                      {item.sinhala}
                    </span>
                  </div>
                  <div style={{ fontSize: 17, fontWeight: 800, color: item.color, letterSpacing: "-0.03em" }}>
                    Rs.{(selectedDistrict as any)[item.key].toLocaleString()}
                  </div>
                  <div style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>per kg</div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
