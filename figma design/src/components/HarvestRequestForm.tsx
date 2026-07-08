import { useState } from "react";
import { useTheme } from "../theme";
import { DISTRICT_PRICES, PEPPER_TYPES } from "../data/gammiris";

interface Props {
  onSubmitted: () => void;
}

export default function HarvestRequestForm({ onSubmitted }: Props) {
  const { theme } = useTheme();
  const [form, setForm] = useState({
    farmerName: "",
    phone: "",
    location: "",
    district: "",
    pepperType: "",
    quantity: "",
    price: "",
    notes: "",
  });
  const [submitted, setSubmitted] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const set = (k: string, v: string) => setForm((f) => ({ ...f, [k]: v }));

  const validate = () => {
    const e: Record<string, string> = {};
    if (!form.farmerName.trim()) e.farmerName = "Name is required";
    if (!form.phone.trim()) e.phone = "Phone number is required";
    if (!form.location.trim()) e.location = "Location is required";
    if (!form.district) e.district = "Select a district";
    if (!form.pepperType) e.pepperType = "Select pepper type";
    if (!form.quantity || isNaN(Number(form.quantity)) || Number(form.quantity) <= 0)
      e.quantity = "Enter valid quantity";
    if (!form.price || isNaN(Number(form.price)) || Number(form.price) <= 0)
      e.price = "Enter your asking price";
    return e;
  };

  const handleSubmit = () => {
    const e = validate();
    if (Object.keys(e).length > 0) { setErrors(e); return; }
    setErrors({});
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <div style={{ padding: "40px 24px", textAlign: "center" }} className="animate-fade-up">
        <div style={{ fontSize: 56, marginBottom: 16 }}>🌿</div>
        <div style={{ fontSize: 20, fontWeight: 800, color: theme.textPrimary, marginBottom: 8, transition: "color 0.35s" }}>
          Request Submitted!
        </div>
        <div style={{ fontSize: 14, color: theme.textMuted, lineHeight: 1.6, marginBottom: 24, transition: "color 0.35s" }}>
          Your harvest listing has been submitted. Buyers will contact you at {form.phone} within 24 hours.
        </div>
        <div style={{
          background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.2)",
          borderRadius: 16, padding: "14px 18px", marginBottom: 24, textAlign: "left",
        }}>
          {[
            { label: "Farmer", value: form.farmerName },
            { label: "District", value: form.district },
            { label: "Type", value: PEPPER_TYPES.find(p => p.id === form.pepperType)?.name ?? form.pepperType },
            { label: "Quantity", value: `${form.quantity} kg` },
            { label: "Asking Price", value: `Rs.${form.price}/kg` },
          ].map((r) => (
            <div key={r.label} style={{ display: "flex", justifyContent: "space-between", padding: "5px 0", borderBottom: `1px solid ${theme.border}` }}>
              <span style={{ fontSize: 12, color: theme.textMuted, transition: "color 0.35s" }}>{r.label}</span>
              <span style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{r.value}</span>
            </div>
          ))}
        </div>
        <button
          onClick={() => { setSubmitted(false); setForm({ farmerName: "", phone: "", location: "", district: "", pepperType: "", quantity: "", price: "", notes: "" }); onSubmitted(); }}
          style={{
            width: "100%", padding: "14px 0", borderRadius: 14, border: "none",
            background: "linear-gradient(135deg, #f59e0b, #d97706)",
            color: "white", fontSize: 14, fontWeight: 700, cursor: "pointer",
            boxShadow: "0 6px 20px rgba(245,158,11,0.35)",
          }}
        >
          View All Listings
        </button>
      </div>
    );
  }

  const Field = ({ label, sinhala, children, error }: { label: string; sinhala?: string; children: React.ReactNode; error?: string }) => (
    <div style={{ marginBottom: 14 }}>
      <div style={{ display: "flex", gap: 6, alignItems: "baseline", marginBottom: 6 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>{label}</span>
        {sinhala && <span style={{ fontSize: 10, color: theme.textMuted, transition: "color 0.35s" }}>{sinhala}</span>}
      </div>
      {children}
      {error && <div style={{ fontSize: 11, color: "#f87171", marginTop: 4 }}>{error}</div>}
    </div>
  );

  const inputStyle = (hasError?: boolean): React.CSSProperties => ({
    width: "100%", padding: "11px 14px", borderRadius: 12,
    background: theme.bgInput,
    border: `1px solid ${hasError ? "#f87171" : theme.border}`,
    color: theme.textPrimary, fontSize: 13, fontFamily: "inherit",
    outline: "none", boxSizing: "border-box",
    transition: "background 0.35s, border-color 0.2s",
  });

  const selectStyle = (hasError?: boolean): React.CSSProperties => ({
    ...inputStyle(hasError),
    appearance: "none",
    backgroundImage: `url("data:image/svg+xml,%3Csvg width='10' height='6' viewBox='0 0 10 6' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%23888' stroke-width='1.5' stroke-linecap='round'/%3E%3C/svg%3E")`,
    backgroundRepeat: "no-repeat",
    backgroundPosition: "right 14px center",
  });

  return (
    <div style={{ padding: "20px 20px 0" }}>
      {/* Header */}
      <div style={{
        background: "linear-gradient(135deg, rgba(245,158,11,0.12), rgba(245,158,11,0.04))",
        border: "1px solid rgba(245,158,11,0.2)",
        borderRadius: 16, padding: "14px 16px", marginBottom: 20,
        display: "flex", gap: 12, alignItems: "flex-start",
      }}>
        <span style={{ fontSize: 28 }}>🌿</span>
        <div>
          <div style={{ fontSize: 14, fontWeight: 700, color: theme.textPrimary, transition: "color 0.35s" }}>
            List Your Harvest
          </div>
          <div style={{ fontSize: 12, color: theme.textMuted, lineHeight: 1.5, marginTop: 2, transition: "color 0.35s" }}>
            Submit your ගම්මිරිස් harvest details. Direct buyers will contact you — no middlemen, full price to you.
          </div>
        </div>
      </div>

      {/* Form */}
      <Field label="Farmer Name" sinhala="ගොවියාගේ නම" error={errors.farmerName}>
        <input value={form.farmerName} onChange={(e) => set("farmerName", e.target.value)}
          placeholder="Your full name" style={inputStyle(!!errors.farmerName)} />
      </Field>

      <Field label="Phone Number" sinhala="දුරකථන" error={errors.phone}>
        <input value={form.phone} onChange={(e) => set("phone", e.target.value)}
          placeholder="+94 77 123 4567" style={inputStyle(!!errors.phone)} />
      </Field>

      <Field label="Village / Town" sinhala="ගම / නගරය" error={errors.location}>
        <input value={form.location} onChange={(e) => set("location", e.target.value)}
          placeholder="e.g. Ukuwela, Matale" style={inputStyle(!!errors.location)} />
      </Field>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <Field label="District" sinhala="දිස්ත්‍රික්කය" error={errors.district}>
          <select value={form.district} onChange={(e) => set("district", e.target.value)}
            style={selectStyle(!!errors.district)}>
            <option value="">Select...</option>
            {DISTRICT_PRICES.map((d) => (
              <option key={d.district} value={d.district}>{d.district}</option>
            ))}
          </select>
        </Field>

        <Field label="Pepper Type" sinhala="ගම්මිරිස් වර්ගය" error={errors.pepperType}>
          <select value={form.pepperType} onChange={(e) => set("pepperType", e.target.value)}
            style={selectStyle(!!errors.pepperType)}>
            <option value="">Select...</option>
            {PEPPER_TYPES.map((pt) => (
              <option key={pt.id} value={pt.id}>{pt.name}</option>
            ))}
          </select>
        </Field>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <Field label="Quantity (kg)" sinhala="ප්‍රමාණය" error={errors.quantity}>
          <div style={{ position: "relative" }}>
            <input value={form.quantity} onChange={(e) => set("quantity", e.target.value)}
              type="number" min="1" placeholder="e.g. 250"
              style={{ ...inputStyle(!!errors.quantity), paddingRight: 36 }} />
            <span style={{
              position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)",
              fontSize: 11, color: theme.textMuted, fontWeight: 600, transition: "color 0.35s",
            }}>kg</span>
          </div>
        </Field>

        <Field label="Asking Price" sinhala="ඉල්ලූ මිල" error={errors.price}>
          <div style={{ position: "relative" }}>
            <span style={{
              position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)",
              fontSize: 11, color: theme.textMuted, fontWeight: 600, transition: "color 0.35s",
            }}>Rs.</span>
            <input value={form.price} onChange={(e) => set("price", e.target.value)}
              type="number" min="1" placeholder="1800"
              style={{ ...inputStyle(!!errors.price), paddingLeft: 34 }} />
          </div>
        </Field>
      </div>

      {/* Market rate hint */}
      {form.district && form.pepperType && (() => {
        const d = DISTRICT_PRICES.find(x => x.district === form.district);
        const marketRate = d ? (d as any)[form.pepperType] : null;
        if (!marketRate) return null;
        return (
          <div style={{
            background: "rgba(34,197,94,0.08)", border: "1px solid rgba(34,197,94,0.2)",
            borderRadius: 10, padding: "8px 12px", marginBottom: 14, marginTop: -4,
            display: "flex", alignItems: "center", gap: 6,
          }}>
            <span style={{ fontSize: 13 }}>💡</span>
            <span style={{ fontSize: 11, color: "#22c55e", fontWeight: 600 }}>
              Market rate in {form.district}: <strong>Rs.{marketRate.toLocaleString()}/kg</strong>
            </span>
          </div>
        );
      })()}

      <Field label="Additional Notes" sinhala="අමතර විස්තර (අත්‍යවශ්‍ය නොවේ)">
        <textarea value={form.notes} onChange={(e) => set("notes", e.target.value)}
          placeholder="Harvest date, quality grade, preferred payment method..."
          rows={3} style={{ ...inputStyle(), resize: "none" }} />
      </Field>

      <button
        onClick={handleSubmit}
        style={{
          width: "100%", padding: "15px 0", borderRadius: 14, border: "none",
          background: "linear-gradient(135deg, #f59e0b, #d97706)",
          color: "white", fontSize: 15, fontWeight: 800, cursor: "pointer",
          boxShadow: "0 6px 24px rgba(245,158,11,0.4)",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          letterSpacing: "0.01em",
        }}
      >
        🌿 Submit Harvest Listing
      </button>
      <div style={{ textAlign: "center", fontSize: 11, color: theme.textMuted, marginTop: 10, marginBottom: 4, transition: "color 0.35s" }}>
        Free to list · No commission on your sale
      </div>
    </div>
  );
}
