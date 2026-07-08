export interface PepperType {
  id: string;
  name: string;
  nameSinhala: string;
  color: string;
}

export interface DistrictPrice {
  district: string;
  districtSinhala: string;
  black: number;
  white: number;
  green: number;
  mixed: number;
  trend: "up" | "down" | "stable";
  change: number;
}

export interface WeeklyPrice {
  week: string;
  black: number;
  white: number;
  green: number;
}

export interface HarvestRequest {
  id: string;
  farmerName: string;
  location: string;
  district: string;
  pepperType: string;
  quantityKg: number;
  pricePerKg: number;
  phone: string;
  submittedAt: string;
  status: "pending" | "contacted" | "sold";
  avatarColor: string;
}

export const PEPPER_TYPES: PepperType[] = [
  { id: "black",  name: "Black Pepper",  nameSinhala: "කළු ගම්මිරිස්", color: "#1f1f1f" },
  { id: "white",  name: "White Pepper",  nameSinhala: "සුදු ගම්මිරිස්", color: "#c9b89a" },
  { id: "green",  name: "Green Pepper",  nameSinhala: "කොළ ගම්මිරිස්", color: "#22c55e" },
  { id: "mixed",  name: "Mixed Grade",   nameSinhala: "මිශ්‍ර ගම්මිරිස්", color: "#a78bfa" },
];

export const DISTRICT_PRICES: DistrictPrice[] = [
  { district: "Matale",       districtSinhala: "මාතලේ",      black: 1850, white: 2400, green: 980,  mixed: 1450, trend: "up",     change: 4.2 },
  { district: "Kandy",        districtSinhala: "මහනුවර",     black: 1920, white: 2550, green: 1020, mixed: 1520, trend: "up",     change: 2.8 },
  { district: "Kurunegala",   districtSinhala: "කුරුණෑගල",   black: 1780, white: 2300, green: 940,  mixed: 1390, trend: "stable", change: 0.5 },
  { district: "Kegalle",      districtSinhala: "කෑගල්ල",     black: 1840, white: 2420, green: 970,  mixed: 1430, trend: "up",     change: 3.1 },
  { district: "Ratnapura",    districtSinhala: "රත්නපුර",    black: 1760, white: 2280, green: 920,  mixed: 1370, trend: "down",   change: -1.5 },
  { district: "Gampaha",      districtSinhala: "ගම්පහ",      black: 1900, white: 2500, green: 1000, mixed: 1490, trend: "up",     change: 1.9 },
  { district: "Colombo",      districtSinhala: "කොළඹ",       black: 1980, white: 2620, green: 1050, mixed: 1560, trend: "up",     change: 5.1 },
  { district: "Galle",        districtSinhala: "ගාල්ල",      black: 1820, white: 2360, green: 960,  mixed: 1410, trend: "down",   change: -0.8 },
  { district: "Hambantota",   districtSinhala: "හම්බන්තොට",  black: 1750, white: 2250, green: 910,  mixed: 1360, trend: "stable", change: 0.2 },
  { district: "Badulla",      districtSinhala: "බදුල්ල",     black: 1810, white: 2340, green: 950,  mixed: 1400, trend: "up",     change: 2.2 },
];

export const WEEKLY_TREND: WeeklyPrice[] = [
  { week: "May W1", black: 1620, white: 2100, green: 860 },
  { week: "May W2", black: 1680, white: 2180, green: 890 },
  { week: "May W3", black: 1720, white: 2240, green: 910 },
  { week: "May W4", black: 1690, white: 2200, green: 900 },
  { week: "Jun W1", black: 1750, white: 2280, green: 930 },
  { week: "Jun W2", black: 1800, white: 2350, green: 955 },
  { week: "Jun W3", black: 1830, white: 2390, green: 970 },
  { week: "Jun W4", black: 1870, white: 2450, green: 990 },
  { week: "Jul W1", black: 1920, white: 2550, green: 1020 },
];

export const SAMPLE_REQUESTS: HarvestRequest[] = [
  {
    id: "r1", farmerName: "Sunil Rajapaksha", location: "Ukuwela, Matale",
    district: "Matale", pepperType: "black", quantityKg: 450, pricePerKg: 1800,
    phone: "+94 77 234 5678", submittedAt: "2 hours ago", status: "pending", avatarColor: "#f97316",
  },
  {
    id: "r2", farmerName: "Kamala Devi", location: "Hettipola, Kurunegala",
    district: "Kurunegala", pepperType: "white", quantityKg: 120, pricePerKg: 2300,
    phone: "+94 71 456 7890", submittedAt: "5 hours ago", status: "contacted", avatarColor: "#a78bfa",
  },
  {
    id: "r3", farmerName: "Rohan Bandara", location: "Kegalle Town",
    district: "Kegalle", pepperType: "mixed", quantityKg: 280, pricePerKg: 1400,
    phone: "+94 76 789 0123", submittedAt: "1 day ago", status: "pending", avatarColor: "#34d399",
  },
];
