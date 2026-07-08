import { createContext, useContext } from "react";

export type ThemeMode = "dark" | "light";

export interface Theme {
  mode: ThemeMode;
  // Backgrounds
  bg: string;
  bgHeader: string;
  bgCard: string;
  bgInput: string;
  bgChipActive: string;
  bgTab: string;
  bgAvatar: string;
  bgMap: string;
  // Borders
  border: string;
  borderCard: string;
  // Text
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
  // Accents (unchanged across themes)
  accent: string;
  accentDark: string;
  // Nav
  navBg: string;
  navBorder: string;
  navInactive: string;
  // Status bar
  statusBar: string;
}

export const dark: Theme = {
  mode: "dark",
  bg: "#12121a",
  bgHeader: "linear-gradient(160deg, #1e1230 0%, #12121a 100%)",
  bgCard: "rgba(255,255,255,0.04)",
  bgInput: "rgba(255,255,255,0.07)",
  bgChipActive: "rgba(255,255,255,0.05)",
  bgTab: "rgba(255,255,255,0.05)",
  bgAvatar: "rgba(249,115,22,0.15)",
  bgMap: "#1a2332",
  border: "rgba(255,255,255,0.07)",
  borderCard: "rgba(255,255,255,0.07)",
  textPrimary: "#ffffff",
  textSecondary: "rgba(255,255,255,0.65)",
  textMuted: "rgba(255,255,255,0.35)",
  accent: "#f97316",
  accentDark: "#ea580c",
  navBg: "rgba(18,18,26,0.97)",
  navBorder: "rgba(255,255,255,0.06)",
  navInactive: "rgba(255,255,255,0.35)",
  statusBar: "#ffffff",
};

export const light: Theme = {
  mode: "light",
  bg: "#f5f5f7",
  bgHeader: "linear-gradient(160deg, #fff7f0 0%, #f5f5f7 100%)",
  bgCard: "#ffffff",
  bgInput: "rgba(0,0,0,0.05)",
  bgChipActive: "rgba(249,115,22,0.06)",
  bgTab: "rgba(0,0,0,0.05)",
  bgAvatar: "rgba(249,115,22,0.1)",
  bgMap: "#e8edf2",
  border: "rgba(0,0,0,0.07)",
  borderCard: "rgba(0,0,0,0.08)",
  textPrimary: "#111118",
  textSecondary: "#444450",
  textMuted: "#8888a0",
  accent: "#f97316",
  accentDark: "#ea580c",
  navBg: "rgba(250,250,252,0.97)",
  navBorder: "rgba(0,0,0,0.07)",
  navInactive: "rgba(0,0,0,0.3)",
  statusBar: "#111118",
};

export const ThemeContext = createContext<{
  theme: Theme;
  toggle: () => void;
}>({ theme: dark, toggle: () => {} });

export const useTheme = () => useContext(ThemeContext);
