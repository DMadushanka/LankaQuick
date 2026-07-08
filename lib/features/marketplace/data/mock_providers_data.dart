import 'package:flutter/material.dart';

class MockCategory {
  final String id;
  final String label;
  final String sinhala;
  final String emoji;
  final Color color;

  const MockCategory({
    required this.id,
    required this.label,
    required this.sinhala,
    required this.emoji,
    required this.color,
  });
}

class MockProvider {
  final String id;
  final String name;
  final String category;
  final String categoryKey;
  final double rating;
  final int reviews;
  final String distance;
  final String price;
  final bool available;
  final String avatar;
  final int jobs;
  final double lat;
  final double lng;

  const MockProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryKey,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.price,
    required this.available,
    required this.avatar,
    required this.jobs,
    required this.lat,
    required this.lng,
  });
}

const List<MockCategory> figmaCategories = [
  MockCategory(id: "plumbing",    label: "Plumbing",    sinhala: "ජලනල",     emoji: "🔧", color: Color(0xFF3B82F6)),
  MockCategory(id: "electrical",  label: "Electrical",  sinhala: "විදුලි",    emoji: "⚡", color: Color(0xFFF59E0B)),
  MockCategory(id: "carpentry",   label: "Carpentry",   sinhala: "වඩු",       emoji: "🪚", color: Color(0xFFA78BFA)),
  MockCategory(id: "cleaning",    label: "Cleaning",    sinhala: "පිරිසිදු",  emoji: "🧹", color: Color(0xFF34D399)),
  MockCategory(id: "gardening",   label: "Gardening",   sinhala: "ගෙවතු",    emoji: "🌱", color: Color(0xFF4ADE80)),
  MockCategory(id: "ac",          label: "AC Repair",   sinhala: "AC",        emoji: "❄️", color: Color(0xFF22D3EE)),
  MockCategory(id: "salon",       label: "Salon",       sinhala: "සෑලෝන්",   emoji: "💇", color: Color(0xFFF472B6)),
  MockCategory(id: "tech",        label: "Tech & IT",   sinhala: "තාක්ෂණ",   emoji: "💻", color: Color(0xFF818CF8)),
  MockCategory(id: "automotive",  label: "Auto",        sinhala: "රථ",        emoji: "🔩", color: Color(0xFFFB923C)),
  MockCategory(id: "painting",    label: "Painting",    sinhala: "තීන්ත",     emoji: "🎨", color: Color(0xFFF87171)),
  MockCategory(id: "tuition",     label: "Tuitions",    sinhala: "අධ්‍යාපන",  emoji: "📚", color: Color(0xFFC084FC)),
  MockCategory(id: "events",      label: "Events",      sinhala: "උත්සව",    emoji: "🎉", color: Color(0xFFFB7185)),
  MockCategory(id: "delivery",    label: "Delivery",    sinhala: "බෙදා",     emoji: "📦", color: Color(0xFFF97316)),
  MockCategory(id: "agriculture", label: "Agriculture", sinhala: "කෘෂි",     emoji: "🌾", color: Color(0xFFA3E635)),
  MockCategory(id: "farmers_market", label: "Farmers Market", sinhala: "ගොවිපොළ", emoji: "🚜", color: Color(0xFF10B981)),
];

const List<MockProvider> figmaProviders = [
  MockProvider(
    id: "1",
    name: "Kamal Perera",
    category: "Plumber",
    categoryKey: "plumbing",
    rating: 4.9,
    reviews: 128,
    distance: "0.4 km",
    price: "Rs. 1,500/hr",
    available: true,
    avatar: "K",
    jobs: 312,
    lat: 7.0917,
    lng: 79.9950,
  ),
  MockProvider(
    id: "2",
    name: "Nuwan Jayasinghe",
    category: "Electrician",
    categoryKey: "electrical",
    rating: 4.8,
    reviews: 95,
    distance: "0.7 km",
    price: "Rs. 2,000/hr",
    available: true,
    avatar: "N",
    jobs: 204,
    lat: 7.0930,
    lng: 79.9980,
  ),
  MockProvider(
    id: "3",
    name: "Saman Kumara",
    category: "Carpenter",
    categoryKey: "carpentry",
    rating: 4.7,
    reviews: 74,
    distance: "1.1 km",
    price: "Rs. 1,800/hr",
    available: false,
    avatar: "S",
    jobs: 167,
    lat: 7.0890,
    lng: 79.9920,
  ),
  MockProvider(
    id: "4",
    name: "Chamari Silva",
    category: "House Cleaner",
    categoryKey: "cleaning",
    rating: 5.0,
    reviews: 210,
    distance: "0.3 km",
    price: "Rs. 1,200/visit",
    available: true,
    avatar: "C",
    jobs: 415,
    lat: 7.0945,
    lng: 79.9935,
  ),
  MockProvider(
    id: "5",
    name: "Roshan Bandara",
    category: "AC Technician",
    categoryKey: "ac",
    rating: 4.6,
    reviews: 58,
    distance: "1.5 km",
    price: "Rs. 2,500/visit",
    available: true,
    avatar: "R",
    jobs: 89,
    lat: 7.0870,
    lng: 79.9960,
  ),
  MockProvider(
    id: "6",
    name: "Dilini Fernando",
    category: "Salon & Beauty",
    categoryKey: "salon",
    rating: 4.9,
    reviews: 163,
    distance: "0.6 km",
    price: "Rs. 800/visit",
    available: true,
    avatar: "D",
    jobs: 278,
    lat: 7.0910,
    lng: 79.9975,
  ),
  MockProvider(
    id: "7",
    name: "Suresh Rathnayake",
    category: "Computer Repair",
    categoryKey: "tech",
    rating: 4.7,
    reviews: 42,
    distance: "0.9 km",
    price: "Rs. 1,000/hr",
    available: false,
    avatar: "S",
    jobs: 93,
    lat: 7.0925,
    lng: 79.9910,
  ),
  MockProvider(
    id: "8",
    name: "Pradeep Wijesinghe",
    category: "Gardener",
    categoryKey: "gardening",
    rating: 4.8,
    reviews: 87,
    distance: "1.2 km",
    price: "Rs. 1,000/hr",
    available: true,
    avatar: "P",
    jobs: 134,
    lat: 7.0880,
    lng: 79.9945,
  ),
];
