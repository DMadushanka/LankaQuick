export interface Farmer {
  id: string;
  name: string;
  avatar: string;
  location: string;
  rating: number;
  totalSales: number;
  verified: boolean;
  since: string;
  avatarColor: string;
}

export interface Product {
  id: string;
  name: string;
  nameSinhala: string;
  farmerId: string;
  category: string;
  price: number;
  unit: string;
  minOrder: number;
  stock: number;
  rating: number;
  reviews: number;
  image: string;
  tags: string[];
  description: string;
  freshness: string;
  harvest: string;
  organic: boolean;
  featured?: boolean;
}

export const FARMERS: Farmer[] = [
  {
    id: "f1",
    name: "Sunil Rajapaksha",
    avatar: "S",
    location: "Polonnaruwa",
    rating: 4.9,
    totalSales: 1248,
    verified: true,
    since: "2021",
    avatarColor: "#34d399",
  },
  {
    id: "f2",
    name: "Priyantha Bandara",
    avatar: "P",
    location: "Anuradhapura",
    rating: 4.8,
    totalSales: 876,
    verified: true,
    since: "2022",
    avatarColor: "#f97316",
  },
  {
    id: "f3",
    name: "Kamala Devi",
    avatar: "K",
    location: "Nuwara Eliya",
    rating: 5.0,
    totalSales: 2103,
    verified: true,
    since: "2020",
    avatarColor: "#a78bfa",
  },
  {
    id: "f4",
    name: "Roshan Perera",
    avatar: "R",
    location: "Kurunegala",
    rating: 4.7,
    totalSales: 534,
    verified: true,
    since: "2023",
    avatarColor: "#3b82f6",
  },
  {
    id: "f5",
    name: "Nimal Sirisena",
    avatar: "N",
    location: "Hambantota",
    rating: 4.8,
    totalSales: 712,
    verified: true,
    since: "2021",
    avatarColor: "#f59e0b",
  },
];

export const PRODUCTS: Product[] = [
  {
    id: "p1",
    name: "Organic Red Tomatoes",
    nameSinhala: "තක්කාලි",
    farmerId: "f1",
    category: "Vegetables",
    price: 180,
    unit: "kg",
    minOrder: 1,
    stock: 120,
    rating: 4.8,
    reviews: 94,
    image: "https://images.unsplash.com/photo-1535821471350-14a8dc72a66c?w=400&h=400&fit=crop&auto=format",
    tags: ["Organic", "No Pesticides"],
    description: "Sun-ripened tomatoes harvested fresh from our fields in Polonnaruwa. Grown without chemical pesticides using traditional Sri Lankan farming methods passed down through generations.",
    freshness: "Harvested 2 days ago",
    harvest: "Daily",
    organic: true,
    featured: true,
  },
  {
    id: "p2",
    name: "King Coconuts",
    nameSinhala: "තඹිලි",
    farmerId: "f2",
    category: "Fruits",
    price: 75,
    unit: "piece",
    minOrder: 5,
    stock: 300,
    rating: 5.0,
    reviews: 218,
    image: "https://images.unsplash.com/photo-1743947063884-6a69a9b86896?w=400&h=400&fit=crop&auto=format",
    tags: ["Fresh", "Natural"],
    description: "Sweet king coconuts straight from our Anuradhapura coconut estate. Rich in electrolytes and natural sugars — nature's best energy drink. Order minimum 5 for delivery.",
    freshness: "Picked this morning",
    harvest: "Every 2 days",
    organic: true,
    featured: true,
  },
  {
    id: "p3",
    name: "Ceylon Tea Leaves",
    nameSinhala: "තේ",
    farmerId: "f3",
    category: "Tea & Spices",
    price: 950,
    unit: "250g",
    minOrder: 1,
    stock: 85,
    rating: 5.0,
    reviews: 341,
    image: "https://images.unsplash.com/photo-1651981350249-6173caeeb660?w=400&h=400&fit=crop&auto=format",
    tags: ["Premium", "Nuwara Eliya"],
    description: "Hand-plucked single-estate Ceylon tea from Nuwara Eliya highlands at 1,800m elevation. Light golden brew with a delicate floral aroma unique to high-grown Sri Lankan tea.",
    freshness: "Processed last week",
    harvest: "Twice monthly",
    organic: false,
    featured: true,
  },
  {
    id: "p4",
    name: "Mixed Vegetables Basket",
    nameSinhala: "එළවළු",
    farmerId: "f4",
    category: "Vegetables",
    price: 650,
    unit: "basket",
    minOrder: 1,
    stock: 45,
    rating: 4.7,
    reviews: 67,
    image: "https://images.unsplash.com/photo-1657288089316-c0350003ca49?w=400&h=400&fit=crop&auto=format",
    tags: ["Mixed", "Seasonal"],
    description: "Seasonal mixed vegetable basket from Kurunegala farms — includes beans, capsicum, carrot, leeks, and gotukola. Perfect for a family of 4 for one week. Contents vary by season.",
    freshness: "Packed this morning",
    harvest: "Weekly",
    organic: false,
  },
  {
    id: "p5",
    name: "Fresh Carrots",
    nameSinhala: "කැරට්",
    farmerId: "f1",
    category: "Vegetables",
    price: 220,
    unit: "kg",
    minOrder: 1,
    stock: 90,
    rating: 4.9,
    reviews: 52,
    image: "https://images.unsplash.com/photo-1687199129802-3e4cc27baac0?w=400&h=400&fit=crop&auto=format",
    tags: ["Organic", "Farm Fresh"],
    description: "Sweet, crunchy carrots grown in the cool highlands. Rich in beta-carotene and naturally sweet. Harvested at peak ripeness for maximum nutrition and flavour.",
    freshness: "Harvested yesterday",
    harvest: "Twice weekly",
    organic: true,
  },
  {
    id: "p6",
    name: "Young Coconuts",
    nameSinhala: "පොල්",
    farmerId: "f5",
    category: "Fruits",
    price: 55,
    unit: "piece",
    minOrder: 6,
    stock: 450,
    rating: 4.8,
    reviews: 183,
    image: "https://images.unsplash.com/photo-1743947063482-3a7f53a6e0d9?w=400&h=400&fit=crop&auto=format",
    tags: ["Fresh", "Bulk available"],
    description: "Tender young coconuts from Hambantota coastal plantations. Soft flesh and abundant sweet water. Perfect for cooking, drinking, and making coconut milk. Bulk orders welcome.",
    freshness: "Harvested 3 days ago",
    harvest: "Weekly",
    organic: true,
  },
  {
    id: "p7",
    name: "Herb & Greens Bundle",
    nameSinhala: "කොළ",
    farmerId: "f3",
    category: "Herbs",
    price: 320,
    unit: "bundle",
    minOrder: 1,
    stock: 60,
    rating: 4.9,
    reviews: 88,
    image: "https://images.unsplash.com/photo-1762920738955-38d51d7a7645?w=400&h=400&fit=crop&auto=format",
    tags: ["Organic", "Medicinal"],
    description: "Fresh herb bundle with gotukola, mukunuwenna, moringa, and curry leaves. Grown naturally without chemicals. Gotukola and mukunuwenna are traditional Sri Lankan superfoods.",
    freshness: "Cut this morning",
    harvest: "3x weekly",
    organic: true,
  },
  {
    id: "p8",
    name: "Red Potatoes",
    nameSinhala: "අල",
    farmerId: "f4",
    category: "Vegetables",
    price: 195,
    unit: "kg",
    minOrder: 2,
    stock: 200,
    rating: 4.6,
    reviews: 41,
    image: "https://images.unsplash.com/photo-1741517628528-718bd73c8ad5?w=400&h=400&fit=crop&auto=format",
    tags: ["Local Variety"],
    description: "Local red-skinned potatoes with dense, waxy flesh — ideal for curries and roasting. Grown in Nuwara Eliya highlands, stored fresh in cool conditions.",
    freshness: "Harvested 5 days ago",
    harvest: "Monthly",
    organic: false,
  },
];

export const CATEGORIES_MARKET = [
  { id: "all",        label: "All",        emoji: "🛒" },
  { id: "Vegetables", label: "Vegetables", emoji: "🥦" },
  { id: "Fruits",     label: "Fruits",     emoji: "🥥" },
  { id: "Tea & Spices", label: "Tea & Spices", emoji: "🍃" },
  { id: "Herbs",      label: "Herbs",      emoji: "🌿" },
  { id: "Rice & Grains", label: "Grains",  emoji: "🌾" },
];
