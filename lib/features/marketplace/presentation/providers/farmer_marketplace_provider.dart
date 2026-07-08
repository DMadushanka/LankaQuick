import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_link/features/auth/presentation/providers/auth_provider.dart';

class FarmerPost {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerAvatar;
  final String title;
  final String description;
  final double price;
  final String unit;
  final String image;
  final String category;
  final double quantity; // stock
  final String location;
  final String date;

  // New fields from Figma design:
  final String nameSinhala;
  final double minOrder;
  final double rating;
  final int reviews;
  final List<String> tags;
  final String freshness;
  final String harvest;
  final bool organic;
  final bool featured;
  // Farmer specific details:
  final int farmerTotalSales;
  final double farmerRating;
  final bool farmerVerified;
  final String farmerSince;
  final String farmerAvatarColor;

  const FarmerPost({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerAvatar,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.image,
    required this.category,
    required this.quantity,
    required this.location,
    required this.date,
    this.nameSinhala = "",
    this.minOrder = 1.0,
    this.rating = 4.8,
    this.reviews = 10,
    this.tags = const [],
    this.freshness = "Harvested recently",
    this.harvest = "Seasonal",
    this.organic = false,
    this.featured = false,
    this.farmerTotalSales = 100,
    this.farmerRating = 4.8,
    this.farmerVerified = true,
    this.farmerSince = "2022",
    this.farmerAvatarColor = "#34d399",
  });
}

class FarmerPostsNotifier extends StateNotifier<List<FarmerPost>> {
  FarmerPostsNotifier() : super([
    const FarmerPost(
      id: "p1",
      farmerId: "f1",
      farmerName: "Sunil Rajapaksha",
      farmerAvatar: "S",
      title: "Organic Red Tomatoes",
      nameSinhala: "තක්කාලි",
      description: "Sun-ripened tomatoes harvested fresh from our fields in Polonnaruwa. Grown without chemical pesticides using traditional Sri Lankan farming methods passed down through generations.",
      price: 180.0,
      unit: "kg",
      image: "https://images.unsplash.com/photo-1535821471350-14a8dc72a66c?w=400&h=400&fit=crop&auto=format",
      category: "Vegetables",
      quantity: 120.0,
      location: "Polonnaruwa",
      date: "2 days ago",
      minOrder: 1.0,
      rating: 4.8,
      reviews: 94,
      tags: ["Organic", "No Pesticides"],
      freshness: "Harvested 2 days ago",
      harvest: "Daily",
      organic: true,
      featured: true,
      farmerTotalSales: 1248,
      farmerRating: 4.9,
      farmerVerified: true,
      farmerSince: "2021",
      farmerAvatarColor: "#34d399",
    ),
    const FarmerPost(
      id: "p2",
      farmerId: "f2",
      farmerName: "Priyantha Bandara",
      farmerAvatar: "P",
      title: "King Coconuts",
      nameSinhala: "තඹිලි",
      description: "Sweet king coconuts straight from our Anuradhapura coconut estate. Rich in electrolytes and natural sugars — nature's best energy drink. Order minimum 5 for delivery.",
      price: 75.0,
      unit: "piece",
      image: "https://images.unsplash.com/photo-1743947063884-6a69a9b86896?w=400&h=400&fit=crop&auto=format",
      category: "Fruits",
      quantity: 300.0,
      location: "Anuradhapura",
      date: "Today",
      minOrder: 5.0,
      rating: 5.0,
      reviews: 218,
      tags: ["Fresh", "Natural"],
      freshness: "Picked this morning",
      harvest: "Every 2 days",
      organic: true,
      featured: true,
      farmerTotalSales: 876,
      farmerRating: 4.8,
      farmerVerified: true,
      farmerSince: "2022",
      farmerAvatarColor: "#f97316",
    ),
    const FarmerPost(
      id: "p3",
      farmerId: "f3",
      farmerName: "Kamala Devi",
      farmerAvatar: "K",
      title: "Ceylon Tea Leaves",
      nameSinhala: "තේ",
      description: "Hand-plucked single-estate Ceylon tea from Nuwara Eliya highlands at 1,800m elevation. Light golden brew with a delicate floral aroma unique to high-grown Sri Lankan tea.",
      price: 950.0,
      unit: "250g",
      image: "https://images.unsplash.com/photo-1651981350249-6173caeeb660?w=400&h=400&fit=crop&auto=format",
      category: "Spices",
      quantity: 85.0,
      location: "Nuwara Eliya",
      date: "Last week",
      minOrder: 1.0,
      rating: 5.0,
      reviews: 341,
      tags: ["Premium", "Nuwara Eliya"],
      freshness: "Processed last week",
      harvest: "Twice monthly",
      organic: false,
      featured: true,
      farmerTotalSales: 2103,
      farmerRating: 5.0,
      farmerVerified: true,
      farmerSince: "2020",
      farmerAvatarColor: "#a78bfa",
    ),
    const FarmerPost(
      id: "p4",
      farmerId: "f4",
      farmerName: "Roshan Perera",
      farmerAvatar: "R",
      title: "Mixed Vegetables Basket",
      nameSinhala: "එළවළු",
      description: "Seasonal mixed vegetable basket from Kurunegala farms — includes beans, capsicum, carrot, leeks, and gotukola. Perfect for a family of 4 for one week. Contents vary by season.",
      price: 650.0,
      unit: "basket",
      image: "https://images.unsplash.com/photo-1657288089316-c0350003ca49?w=400&h=400&fit=crop&auto=format",
      category: "Vegetables",
      quantity: 45.0,
      location: "Kurunegala",
      date: "Today",
      minOrder: 1.0,
      rating: 4.7,
      reviews: 67,
      tags: ["Mixed", "Seasonal"],
      freshness: "Packed this morning",
      harvest: "Weekly",
      organic: false,
      featured: false,
      farmerTotalSales: 534,
      farmerRating: 4.7,
      farmerVerified: true,
      farmerSince: "2023",
      farmerAvatarColor: "#3b82f6",
    ),
    const FarmerPost(
      id: "p5",
      farmerId: "f1",
      farmerName: "Sunil Rajapaksha",
      farmerAvatar: "S",
      title: "Fresh Carrots",
      nameSinhala: "කැරට්",
      description: "Sweet, crunchy carrots grown in the cool highlands. Rich in beta-carotene and naturally sweet. Harvested at peak ripeness for maximum nutrition and flavour.",
      price: 220.0,
      unit: "kg",
      image: "https://images.unsplash.com/photo-1687199129802-3e4cc27baac0?w=400&h=400&fit=crop&auto=format",
      category: "Vegetables",
      quantity: 90.0,
      location: "Polonnaruwa",
      date: "Yesterday",
      minOrder: 1.0,
      rating: 4.9,
      reviews: 52,
      tags: ["Organic", "Farm Fresh"],
      freshness: "Harvested yesterday",
      harvest: "Twice weekly",
      organic: true,
      featured: false,
      farmerTotalSales: 1248,
      farmerRating: 4.9,
      farmerVerified: true,
      farmerSince: "2021",
      farmerAvatarColor: "#34d399",
    ),
    const FarmerPost(
      id: "p6",
      farmerId: "f5",
      farmerName: "Nimal Sirisena",
      farmerAvatar: "N",
      title: "Young Coconuts",
      nameSinhala: "පොල්",
      description: "Young green coconuts with thin husk and lots of sweet water. Extremely refreshing for hot summer days, sourced directly from Hambantota farms.",
      price: 55.0,
      unit: "piece",
      image: "https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop&auto=format",
      category: "Fruits",
      quantity: 450.0,
      location: "Hambantota",
      date: "Yesterday",
      minOrder: 6.0,
      rating: 4.6,
      reviews: 29,
      tags: ["Local", "Hydration"],
      freshness: "Picked yesterday",
      harvest: "Weekly",
      organic: true,
      featured: false,
      farmerTotalSales: 712,
      farmerRating: 4.8,
      farmerVerified: true,
      farmerSince: "2021",
      farmerAvatarColor: "#f59e0b",
    ),
  ]);

  void addPost(FarmerPost post) {
    state = [post, ...state];
  }

  void updateQuantity(String id, double boughtQty) {
    state = state.map((post) {
      if (post.id == id) {
        final newQty = (post.quantity - boughtQty).clamp(0.0, double.infinity);
        return FarmerPost(
          id: post.id,
          farmerId: post.farmerId,
          farmerName: post.farmerName,
          farmerAvatar: post.farmerAvatar,
          title: post.title,
          description: post.description,
          price: post.price,
          unit: post.unit,
          image: post.image,
          category: post.category,
          quantity: newQty,
          location: post.location,
          date: post.date,
          nameSinhala: post.nameSinhala,
          minOrder: post.minOrder,
          rating: post.rating,
          reviews: post.reviews,
          tags: post.tags,
          freshness: post.freshness,
          harvest: post.harvest,
          organic: post.organic,
          featured: post.featured,
          farmerTotalSales: post.farmerTotalSales,
          farmerRating: post.farmerRating,
          farmerVerified: post.farmerVerified,
          farmerSince: post.farmerSince,
          farmerAvatarColor: post.farmerAvatarColor,
        );
      }
      return post;
    }).toList();
  }
}

final farmerPostsProvider = StateNotifierProvider<FarmerPostsNotifier, List<FarmerPost>>((ref) {
  return FarmerPostsNotifier();
});

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

class ChatRoom {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final List<ChatMessage> messages;

  const ChatRoom({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messages,
  });
}

class MockChatsNotifier extends StateNotifier<List<ChatRoom>> {
  MockChatsNotifier() : super([
    ChatRoom(
      id: "chat_1",
      otherUserId: "f1",
      otherUserName: "Sunil Rajapaksha",
      otherUserAvatar: "S",
      lastMessage: "Sure, the organic tomatoes are ready. You can pick them up anytime.",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      messages: [
        ChatMessage(
          id: "m_1",
          senderId: "mock_seeker_123",
          content: "Hi Sunil Rajapaksha, are the organic tomatoes available for pickup today?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ChatMessage(
          id: "m_2",
          senderId: "f1",
          content: "Sure, the organic tomatoes are ready. You can pick them up anytime.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
  ]);

  void createOrOpenChat(String otherUserId, String otherUserName, String otherUserAvatar) {
    final exists = state.any((room) => room.otherUserId == otherUserId);
    if (!exists) {
      final newRoom = ChatRoom(
        id: "chat_${DateTime.now().millisecondsSinceEpoch}",
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
        lastMessage: "Started conversation",
        lastMessageTime: DateTime.now(),
        messages: const [],
      );
      state = [newRoom, ...state];
    }
  }

  void sendMessage(String roomId, String senderId, String content) {
    state = state.map((room) {
      if (room.id == roomId) {
        final newMsg = ChatMessage(
          id: "msg_${DateTime.now().millisecondsSinceEpoch}",
          senderId: senderId,
          content: content,
          timestamp: DateTime.now(),
        );
        final updatedMsgs = [...room.messages, newMsg];
        return ChatRoom(
          id: room.id,
          otherUserId: room.otherUserId,
          otherUserName: room.otherUserName,
          otherUserAvatar: room.otherUserAvatar,
          lastMessage: content,
          lastMessageTime: DateTime.now(),
          messages: updatedMsgs,
        );
      }
      return room;
    }).toList();
  }
}

final mockChatsProvider = StateNotifierProvider<MockChatsNotifier, List<ChatRoom>>((ref) {
  return MockChatsNotifier();
});

class GammirisPrice {
  final String grade;
  final String district;
  final double pricePerKg;
  final String trend; // "up", "down", "stable"

  const GammirisPrice({
    required this.grade,
    required this.district,
    required this.pricePerKg,
    required this.trend,
  });
}

// Global static mock pricing table
const List<GammirisPrice> gammirisPrices = [
  GammirisPrice(grade: "Grade 1 (Black Pepper)", district: "Matale", pricePerKg: 1350.0, trend: "up"),
  GammirisPrice(grade: "Grade 1 (Black Pepper)", district: "Kandy", pricePerKg: 1320.0, trend: "up"),
  GammirisPrice(grade: "Grade 1 (Black Pepper)", district: "Gampaha", pricePerKg: 1290.0, trend: "stable"),
  GammirisPrice(grade: "Grade 1 (Black Pepper)", district: "Kurunegala", pricePerKg: 1270.0, trend: "down"),
  GammirisPrice(grade: "Grade 1 (Black Pepper)", district: "Kegalle", pricePerKg: 1310.0, trend: "stable"),

  GammirisPrice(grade: "Grade 2 (Standard)", district: "Matale", pricePerKg: 1150.0, trend: "stable"),
  GammirisPrice(grade: "Grade 2 (Standard)", district: "Kandy", pricePerKg: 1120.0, trend: "up"),
  GammirisPrice(grade: "Grade 2 (Standard)", district: "Gampaha", pricePerKg: 1100.0, trend: "down"),
  GammirisPrice(grade: "Grade 2 (Standard)", district: "Kurunegala", pricePerKg: 1080.0, trend: "stable"),
  GammirisPrice(grade: "Grade 2 (Standard)", district: "Kegalle", pricePerKg: 1110.0, trend: "up"),

  GammirisPrice(grade: "Light Berries (Bora)", district: "Matale", pricePerKg: 850.0, trend: "down"),
  GammirisPrice(grade: "Light Berries (Bora)", district: "Kandy", pricePerKg: 830.0, trend: "stable"),
  GammirisPrice(grade: "Light Berries (Bora)", district: "Gampaha", pricePerKg: 810.0, trend: "down"),
  GammirisPrice(grade: "Light Berries (Bora)", district: "Kurunegala", pricePerKg: 790.0, trend: "down"),
  GammirisPrice(grade: "Light Berries (Bora)", district: "Kegalle", pricePerKg: 820.0, trend: "stable"),

  GammirisPrice(grade: "Organic Certified", district: "Matale", pricePerKg: 1550.0, trend: "up"),
  GammirisPrice(grade: "Organic Certified", district: "Kandy", pricePerKg: 1510.0, trend: "up"),
  GammirisPrice(grade: "Organic Certified", district: "Gampaha", pricePerKg: 1480.0, trend: "stable"),
  GammirisPrice(grade: "Organic Certified", district: "Kurunegala", pricePerKg: 1450.0, trend: "stable"),
  GammirisPrice(grade: "Organic Certified", district: "Kegalle", pricePerKg: 1490.0, trend: "up"),
];

class GammirisCollectionRequest {
  final String id;
  final String grade;
  final double weight;
  final String district;
  final String address;
  final String contactName;
  final String contactPhone;
  final double totalEstimatedValue;
  final String status; // "Pending", "Scheduled", "Collected", "Cancelled"
  final DateTime requestedAt;

  const GammirisCollectionRequest({
    required this.id,
    required this.grade,
    required this.weight,
    required this.district,
    required this.address,
    required this.contactName,
    required this.contactPhone,
    required this.totalEstimatedValue,
    required this.status,
    required this.requestedAt,
  });
}

class GammirisRequestsNotifier extends StateNotifier<List<GammirisCollectionRequest>> {
  GammirisRequestsNotifier() : super([
    GammirisCollectionRequest(
      id: "gr_1",
      grade: "Grade 1 (Black Pepper)",
      weight: 120.0,
      district: "Matale",
      address: "12/A, Matale Road, Aluvihare",
      contactName: "Sunil Wickrama",
      contactPhone: "+94 71 888 9999",
      totalEstimatedValue: 120.0 * 1350.0,
      status: "Scheduled (Pickup: Tomorrow)",
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GammirisCollectionRequest(
      id: "gr_2",
      grade: "Organic Certified",
      weight: 50.0,
      district: "Kandy",
      address: "Gampola Estate, Kandy",
      contactName: "Ranasinghe Banda",
      contactPhone: "+94 77 222 3333",
      totalEstimatedValue: 50.0 * 1510.0,
      status: "Pending Verification",
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ]);

  void addRequest(GammirisCollectionRequest req) {
    state = [req, ...state];
  }
}

final gammirisRequestsProvider = StateNotifierProvider<GammirisRequestsNotifier, List<GammirisCollectionRequest>>((ref) {
  return GammirisRequestsNotifier();
});

// --- NEW FIGMA DATASET MODELS AND DATA ---
class GammirisDistrictPrice {
  final String district;
  final String districtSinhala;
  final double black;
  final double white;
  final double green;
  final double mixed;
  final String trend; // "up", "down", "stable"
  final double change;

  const GammirisDistrictPrice({
    required this.district,
    required this.districtSinhala,
    required this.black,
    required this.white,
    required this.green,
    required this.mixed,
    required this.trend,
    required this.change,
  });
}

class GammirisWeeklyPrice {
  final String week;
  final double black;
  final double white;
  final double green;

  const GammirisWeeklyPrice({
    required this.week,
    required this.black,
    required this.white,
    required this.green,
  });
}

class GammirisHarvestRequest {
  final String id;
  final String farmerName;
  final String location;
  final String district;
  final String pepperType;
  final double quantityKg;
  final double pricePerKg;
  final String phone;
  final String submittedAt;
  final String status; // "pending", "contacted", "sold"
  final int avatarColor;

  const GammirisHarvestRequest({
    required this.id,
    required this.farmerName,
    required this.location,
    required this.district,
    required this.pepperType,
    required this.quantityKg,
    required this.pricePerKg,
    required this.phone,
    required this.submittedAt,
    required this.status,
    required this.avatarColor,
  });
}

const List<GammirisDistrictPrice> figmaDistrictPrices = [
  GammirisDistrictPrice(district: "Matale", districtSinhala: "මාතලේ", black: 1850, white: 2400, green: 980, mixed: 1450, trend: "up", change: 4.2),
  GammirisDistrictPrice(district: "Kandy", districtSinhala: "මහනුවර", black: 1920, white: 2550, green: 1020, mixed: 1520, trend: "up", change: 2.8),
  GammirisDistrictPrice(district: "Kurunegala", districtSinhala: "කුරුණෑගල", black: 1780, white: 2300, green: 940, mixed: 1390, trend: "stable", change: 0.5),
  GammirisDistrictPrice(district: "Kegalle", districtSinhala: "කෑගල්ල", black: 1840, white: 2420, green: 970, mixed: 1430, trend: "up", change: 3.1),
  GammirisDistrictPrice(district: "Ratnapura", districtSinhala: "රත්නපුර", black: 1760, white: 2280, green: 920, mixed: 1370, trend: "down", change: -1.5),
  GammirisDistrictPrice(district: "Gampaha", districtSinhala: "ගම්පහ", black: 1900, white: 2500, green: 1000, mixed: 1490, trend: "up", change: 1.9),
  GammirisDistrictPrice(district: "Colombo", districtSinhala: "කොළඹ", black: 1980, white: 2620, green: 1050, mixed: 1560, trend: "up", change: 5.1),
  GammirisDistrictPrice(district: "Galle", districtSinhala: "ගාල්ල", black: 1820, white: 2360, green: 960, mixed: 1410, trend: "down", change: -0.8),
  GammirisDistrictPrice(district: "Hambantota", districtSinhala: "හම්බන්තොට", black: 1750, white: 2250, green: 910, mixed: 1360, trend: "stable", change: 0.2),
  GammirisDistrictPrice(district: "Badulla", districtSinhala: "බදුල්ල", black: 1810, white: 2340, green: 950, mixed: 1400, trend: "up", change: 2.2),
];

const List<GammirisWeeklyPrice> figmaWeeklyTrends = [
  GammirisWeeklyPrice(week: "May W1", black: 1620, white: 2100, green: 860),
  GammirisWeeklyPrice(week: "May W2", black: 1680, white: 2180, green: 890),
  GammirisWeeklyPrice(week: "May W3", black: 1720, white: 2240, green: 910),
  GammirisWeeklyPrice(week: "May W4", black: 1690, white: 2200, green: 900),
  GammirisWeeklyPrice(week: "Jun W1", black: 1750, white: 2280, green: 930),
  GammirisWeeklyPrice(week: "Jun W2", black: 1800, white: 2350, green: 955),
  GammirisWeeklyPrice(week: "Jun W3", black: 1830, white: 2390, green: 970),
  GammirisWeeklyPrice(week: "Jun W4", black: 1870, white: 2450, green: 990),
  GammirisWeeklyPrice(week: "Jul W1", black: 1920, white: 2550, green: 1020),
];

class GammirisListingsNotifier extends StateNotifier<List<GammirisHarvestRequest>> {
  GammirisListingsNotifier() : super([
    const GammirisHarvestRequest(
      id: "r1",
      farmerName: "Sunil Rajapaksha",
      location: "Ukuwela, Matale",
      district: "Matale",
      pepperType: "black",
      quantityKg: 450.0,
      pricePerKg: 1800.0,
      phone: "+94 77 234 5678",
      submittedAt: "2 hours ago",
      status: "pending",
      avatarColor: 0xFFF97316,
    ),
    const GammirisHarvestRequest(
      id: "r2",
      farmerName: "Kamala Devi",
      location: "Hettipola, Kurunegala",
      district: "Kurunegala",
      pepperType: "white",
      quantityKg: 120.0,
      pricePerKg: 2300.0,
      phone: "+94 71 456 7890",
      submittedAt: "5 hours ago",
      status: "contacted",
      avatarColor: 0xFFA78BFA,
    ),
    const GammirisHarvestRequest(
      id: "r3",
      farmerName: "Rohan Bandara",
      location: "Kegalle Town",
      district: "Kegalle",
      pepperType: "mixed",
      quantityKg: 280.0,
      pricePerKg: 1400.0,
      phone: "+94 76 789 0123",
      submittedAt: "1 day ago",
      status: "pending",
      avatarColor: 0xFF34D399,
    ),
  ]);

  void addRequest(GammirisHarvestRequest req) {
    state = [req, ...state];
  }
}

final gammirisListingsProvider = StateNotifierProvider<GammirisListingsNotifier, List<GammirisHarvestRequest>>((ref) {
  return GammirisListingsNotifier();
});

final gammirisDistrictPricesProvider = FutureProvider<List<GammirisDistrictPrice>>((ref) async {
  final isSupabase = ref.watch(supabaseConfiguredProvider);
  if (isSupabase) {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('gammiris_district_prices').select().order('district');
      return response.map((data) => GammirisDistrictPrice(
        district: data['district'] as String,
        districtSinhala: data['district_sinhala'] as String,
        black: (data['black'] as num).toDouble(),
        white: (data['white'] as num).toDouble(),
        green: (data['green'] as num).toDouble(),
        mixed: (data['mixed'] as num).toDouble(),
        trend: data['trend'] as String,
        change: (data['change'] as num).toDouble(),
      )).toList();
    } catch (e) {
      debugPrint("Error fetching district prices: $e");
    }
  }
  return figmaDistrictPrices;
});

final gammirisWeeklyTrendsProvider = FutureProvider<List<GammirisWeeklyPrice>>((ref) async {
  final isSupabase = ref.watch(supabaseConfiguredProvider);
  if (isSupabase) {
    try {
      final supabase = Supabase.instance.client;
      // Fetch and sort by updated_at or week
      final response = await supabase.from('gammiris_weekly_trends').select().order('updated_at');
      return response.map((data) => GammirisWeeklyPrice(
        week: data['week'] as String,
        black: (data['black'] as num).toDouble(),
        white: (data['white'] as num).toDouble(),
        green: (data['green'] as num).toDouble(),
      )).toList();
    } catch (e) {
      debugPrint("Error fetching weekly trends: $e");
    }
  }
  return figmaWeeklyTrends;
});

