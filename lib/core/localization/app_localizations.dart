import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_localizations.g.dart';

class AppCategory {
  final String key;
  final String englishName;
  final String sinhalaName;
  final String tamilName;
  final List<AppSubcategory> subcategories;

  const AppCategory({
    required this.key,
    required this.englishName,
    required this.sinhalaName,
    required this.tamilName,
    required this.subcategories,
  });

  String getName(String locale) {
    if (locale == 'si') return sinhalaName;
    if (locale == 'ta') return tamilName;
    return englishName;
  }
}

class AppSubcategory {
  final String key;
  final String englishName;
  final String sinhalaName;
  final String tamilName;

  const AppSubcategory({
    required this.key,
    required this.englishName,
    required this.sinhalaName,
    required this.tamilName,
  });

  String getName(String locale) {
    if (locale == 'si') return sinhalaName;
    if (locale == 'ta') return tamilName;
    return englishName;
  }
}

class AppLocalizations {
  static const List<AppCategory> categories = [
    AppCategory(
      key: 'home_maintenance',
      englishName: 'Home Maintenance & Repair',
      sinhalaName: 'ගෘහ ආශ්‍රිත නඩත්තු සහ අලුත්වැඩියා සේවා',
      tamilName: 'வீட்டு பராமரிப்பு மற்றும் பழுது',
      subcategories: [
        AppSubcategory(key: 'plumbing', englishName: 'Plumbing services', sinhalaName: 'ජලනල කාර්මික සේවා', tamilName: 'குழாய் பழுதுபார்க்கும் சேவைகள்'),
        AppSubcategory(key: 'electrical', englishName: 'Electrical repairs', sinhalaName: 'විදුලි කාර්මික සේවා', tamilName: 'மின்சார பழுதுபார்ப்பு'),
        AppSubcategory(key: 'carpentry', englishName: 'Carpentry', sinhalaName: 'වඩු වැඩ', tamilName: 'தச்சு வேலை'),
        AppSubcategory(key: 'masonry', englishName: 'Masonry', sinhalaName: 'මේසන් වැඩ / පෙදරේරු වැඩ', tamilName: 'கட்டிட வேலை'),
        AppSubcategory(key: 'painting', englishName: 'Painting services', sinhalaName: 'තීන්ත ගෑමේ සේවා', tamilName: 'வண்ணப்பூச்சு சேவைகள்'),
        AppSubcategory(key: 'welding', englishName: 'Welding', sinhalaName: 'වෙල්දින් වැඩ', tamilName: 'வெல்டிங் வேலை'),
        AppSubcategory(key: 'ac_maintenance', englishName: 'AC maintenance', sinhalaName: 'වායු සමීකරණ නඩත්තුව', tamilName: 'ஏசி பராமரிப்பு'),
        AppSubcategory(key: 'appliance_repair', englishName: 'Home appliance maintenance', sinhalaName: 'ගෘහ විදුලි උපකරණ නඩත්තුව', tamilName: 'வீட்டு உபயோக பொருட்கள் பழுதுபார்ப்பு'),
      ],
    ),
    AppCategory(
      key: 'household_cleaning',
      englishName: 'Household & Cleaning Services',
      sinhalaName: 'ගෘහස්ථ පිරිසිදු කිරීම් සහ නඩත්තුව',
      tamilName: 'வீட்டுப் பராமரிப்பு மற்றும் சுத்தம் செய்தல்',
      subcategories: [
        AppSubcategory(key: 'home_cleaning', englishName: 'Home cleaning', sinhalaName: 'නිවාස පිරිසිදු කිරීම', tamilName: 'வீடு சுத்தம் செய்தல்'),
        AppSubcategory(key: 'laundry_ironing', englishName: 'Laundry & Ironing', sinhalaName: 'රෙදි සේදීම සහ මැදීම', tamilName: 'சலவை மற்றும் இஸ்திரி செய்தல்'),
      ],
    ),
    AppCategory(
      key: 'gardening_outdoor',
      englishName: 'Gardening & Outdoor Services',
      sinhalaName: 'ගෙවතු සහ එළිමහන් සේවා',
      tamilName: 'தோட்டம் மற்றும் வெளிப்புற சேவைகள்',
      subcategories: [
        AppSubcategory(key: 'gardening', englishName: 'Gardening', sinhalaName: 'ගෙවතු නඩත්තුව', tamilName: 'தோட்டப் பராமரிப்பு'),
        AppSubcategory(key: 'tree_cutting', englishName: 'Tree cutting', sinhalaName: 'ගස් කැපීම', tamilName: 'மரம் வெட்டுதல்'),
        AppSubcategory(key: 'well_cleaning', englishName: 'Well digging & cleaning', sinhalaName: 'ළිං කැපීම සහ පිරිසිදු කිරීම', tamilName: 'கிணறு வெட்டுதல் மற்றும் சுத்தம் செய்தல்'),
      ],
    ),
    AppCategory(
      key: 'tech_it',
      englishName: 'Tech & IT Services',
      sinhalaName: 'තාක්‍ෂණික සහ තොරතුරු තාක්‍ෂණ සේවා',
      tamilName: 'தொழில்நுட்ப மற்றும் தகவல் தொழில்நுட்ப சேவைகள்',
      subcategories: [
        AppSubcategory(key: 'computer_repair', englishName: 'Computer repair', sinhalaName: 'පරිගණක අලුත්වැඩියාව', tamilName: 'கணினி பழுதுபார்ப்பு'),
        AppSubcategory(key: 'cctv_networking', englishName: 'CCTV & Networking services', sinhalaName: 'CCTV සහ ජාලකරණ සේවා', tamilName: 'சிசிடிவி மற்றும் நெட்வொர்க்கிங் சேவைகள்'),
      ],
    ),
    AppCategory(
      key: 'automotive_mechanical',
      englishName: 'Automotive & Mechanical',
      sinhalaName: 'මෝටර් රථ සහ කාර්මික සේවා',
      tamilName: 'தானியங்கி மற்றும் இயந்திரவியல்',
      subcategories: [
        AppSubcategory(key: 'auto_repair', englishName: 'Automotive repair & maintenance', sinhalaName: 'මෝටර් රථ අලුත්වැඩියාව සහ නඩත්තුව', tamilName: 'வாகன பழுதுபார்ப்பு மற்றும் பராமரிப்பு'),
      ],
    ),
    AppCategory(
      key: 'personal_care',
      englishName: 'Personal Care & Wellness',
      sinhalaName: 'පුද්ගලික සත්කාර සහ සෞඛ්‍ය සේවා',
      tamilName: 'தனிப்பட்ட பராமரிப்பு மற்றும் ஆரோக்கியம்',
      subcategories: [
        AppSubcategory(key: 'beauty_salon', englishName: 'Beauty and salon services', sinhalaName: 'රූපලාවන්‍ය සහ සැලෝන් සේවා', tamilName: 'அழகு மற்றும் வரவேற்புரை சேவைகள்'),
        AppSubcategory(key: 'yoga_instruction', englishName: 'Yoga instruction', sinhalaName: 'යෝගා උපදේශන', tamilName: 'யோகா ஆலோசனை'),
        AppSubcategory(key: 'tailoring', englishName: 'Tailoring & dressmaking', sinhalaName: 'ඇඳුම් මැසීම / ටේලර් සේවා', tamilName: 'தையல் சேவைகள்'),
      ],
    ),
    AppCategory(
      key: 'education_professional',
      englishName: 'Education & Professional Services',
      sinhalaName: 'අධ්‍යාපනික සහ වෘත්තීය සේවා',
      tamilName: 'கல்வி மற்றும் தொழில்முறை சேவைகள்',
      subcategories: [
        AppSubcategory(key: 'individual_tutoring', englishName: 'Individual tutoring', sinhalaName: 'තනි උපකාරක පන්ති', tamilName: 'தனிப்பட்ட பயிற்சி வகுப்புகள்'),
      ],
    ),
    AppCategory(
      key: 'events_creative',
      englishName: 'Events & Creative Services',
      sinhalaName: 'උත්සව සහ නිර්මාණාත්මක සේවා',
      tamilName: 'நிகழ்வுகள் மற்றும் ஆக்கப்பூர்வமான சேவைகள்',
      subcategories: [
        AppSubcategory(key: 'event_organizing', englishName: 'Event organizing & decoration', sinhalaName: 'උත්සව සංවිධානය සහ අලංකරණය', tamilName: 'நிகழ்வு ஏற்பாடு மற்றும் அலங்காரம்'),
        AppSubcategory(key: 'photography', englishName: 'Photography', sinhalaName: 'ඡායාරූපකරණය', tamilName: 'புகைப்படக்கலை'),
        AppSubcategory(key: 'event_catering', englishName: 'Home event cooking / catering services', sinhalaName: 'උත්සව සඳහා ඉවුම් පිහුම් සහ කේටරින් සේවා', tamilName: 'சமையல் மற்றும் கேட்டரிங் சேவைகள்'),
      ],
    ),
    AppCategory(
      key: 'agricultural_labor',
      englishName: 'Agricultural Labor',
      sinhalaName: 'කෘෂිකාර්මික කුලී වැඩ',
      tamilName: 'விவசாய உழைப்பு',
      subcategories: [
        AppSubcategory(key: 'coconut_plucking', englishName: 'Coconut plucking', sinhalaName: 'පොල් කැඩීම', tamilName: 'தேங்காய் பறித்தல்'),
        AppSubcategory(key: 'pepper_harvesting', englishName: 'Pepper harvesting', sinhalaName: 'ගම්මිරිස් කැඩීම', tamilName: 'மிளகு அறுவடை'),
        AppSubcategory(key: 'tea_plucking', englishName: 'Tea leaves plucking', sinhalaName: 'තේ දළු නෙළීම', tamilName: 'தேயிலை பறித்தல்'),
      ],
    ),
    AppCategory(
      key: 'delivery_general_labor',
      englishName: 'Delivery & General Labor',
      sinhalaName: 'බෙදාහැරීම් සහ දෛනික කුලී වැඩ',
      tamilName: 'விநியோகம் மற்றும் பொது கூலி வேலை',
      subcategories: [
        AppSubcategory(key: 'general_labor', englishName: 'General labor / daily wage', sinhalaName: 'සාමාන්‍ය කුලී වැඩ', tamilName: 'பொது கூலி வேலை'),
        AppSubcategory(key: 'delivery_services', englishName: 'Delivery services', sinhalaName: 'බෙදාහැරීමේ සේවා', tamilName: 'விநியோக சேவைகள்'),
        AppSubcategory(key: 'part_time_services', englishName: 'Part-time services', sinhalaName: 'අර්ධ කාලීන සේවා', tamilName: 'பகுதி நேர சேவைகள்'),
      ],
    ),
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'LankaQuick',
      'nav_marketplace': 'Marketplace',
      'nav_bookings': 'Bookings',
      'nav_profile': 'Profile',
      'search_hint': 'Search services by category...',
      'no_services_found': 'No services found in this category.',
      'no_services_yet': 'No services listed yet.',
      'btn_book_now': 'Book Now',
      'btn_add_service': 'Add Service',
      'sheet_add_title': 'Add New Service Listing',
      'input_title': 'Service Title',
      'input_price': 'Hourly / Service Price (\$)',
      'input_desc': 'Description',
      'btn_publish': 'Publish Service',
      'select_category': 'Select Main Category',
      'select_subcategory': 'Select Subcategory',
      'confirm_booking_title': 'Confirm Booking',
      'confirm_booking_prompt': 'Are you sure you want to book this service? This will send a request to the provider.',
      'btn_cancel': 'Cancel',
      'btn_confirm': 'Confirm',
      'toast_request_sent': 'Booking request sent successfully!',
      'profile_title': 'Profile',
      'profile_edit': 'Edit Details',
      'profile_name': 'Full Name',
      'profile_email': 'Email (Cannot be modified)',
      'profile_uid': 'User ID (UID)',
      'profile_role': 'Account Role',
      'btn_save': 'Save Changes',
      'btn_sign_out': 'Sign Out & Reset PIN',
      'toast_profile_updated': 'Profile updated successfully!',
      'lang_select': 'App Language',
      'dialog_signout_title': 'Sign Out & Reset?',
      'dialog_signout_body': 'Are you sure you want to sign out and clear your quick-login PIN? You will need to sign in again.',
      'role_seeker': 'Seeker',
      'role_provider': 'Provider',
      'pin_create': 'Create your 4-Digit PIN',
      'pin_confirm': 'Confirm your 4-Digit PIN',
      'pin_enter': 'Enter your quick-login PIN',
      'pin_mismatch': 'PINs do not match. Create your PIN',
      'pin_incorrect': 'Incorrect PIN. Try again',
      'btn_back_to_create': 'Back to Create PIN',
      'auth_welcome': 'Welcome to LankaQuick',
      'auth_subtitle': 'Connect with local providers instantly',
      'auth_login': 'Login',
      'auth_signup': 'Sign Up',
      'auth_no_account': 'Don\'t have an account? Sign Up',
      'auth_has_account': 'Already have an account? Login',
      'auth_btn_submit': 'Submit',
      'auth_validation_name': 'Please enter your name',
      'auth_validation_email': 'Please enter a valid email',
      'auth_validation_pass': 'Password must be at least 6 characters',
      'demo_mode_banner': 'Supabase is running in Demo Mode (Local Config missing).',
      'bookings_title': 'My Bookings',
      'bookings_empty': 'No bookings found.',
      'bookings_signin': 'Please sign in to view bookings.',
      'bookings_id': 'Booking ID',
      'btn_accept': 'Accept',
      'btn_decline': 'Decline',
      'btn_cancel_request': 'Cancel Request',
      'btn_complete_work': 'Complete Work',
      'nav_nearby': 'Explore Map',
      'map_search_hint': 'Search nearby services...',
      'btn_track': 'Track Live',
      'btn_start_journey': 'Start Journey',
      'btn_arrived': 'Arrived',
      'share_location': 'Active Location Sharing',
      'location_updated': 'Location updated successfully',
      'distance_away': 'km away',
      'eta_mins': 'mins',
      'status_en_route': 'EN ROUTE',
      'status_arrived': 'ARRIVED',
      'tracking_title': 'Live Tracking',
      'simulate_gps': 'Simulate GPS Move',
      'btn_set_location': 'Set Location',
      'set_location_prompt': 'Drag standard pin to set your service location',
    },
    'si': {
      'app_title': 'ලංකා ක්වික් (LankaQuick)',
      'nav_marketplace': 'වෙළඳපොළ',
      'nav_bookings': 'වෙන් කිරීම්',
      'nav_profile': 'ප්‍රෝෆයිල්',
      'search_hint': 'කාණ්ඩය අනුව සේවාවන් සොයන්න...',
      'no_services_found': 'මෙම කාණ්ඩය යටතේ සේවාවන් කිසිවක් නැත.',
      'no_services_yet': 'තවමත් සේවාවන් ඇතුළත් කර නොමැත.',
      'btn_book_now': 'දැන් වෙන්කරන්න',
      'btn_add_service': 'සේවාවක් එක්කරන්න',
      'sheet_add_title': 'නව සේවාවක් ඇතුළත් කරන්න',
      'input_title': 'සේවාවේ නම',
      'input_price': 'සේවා ගාස්තුව / පැයක මිල (\$)',
      'input_desc': 'විස්තරය',
      'btn_publish': 'සේවාව ඇතුළත් කරන්න',
      'select_category': 'ප්‍රධාන කාණ්ඩය තෝරන්න',
      'select_subcategory': 'උප කාණ්ඩය තෝරන්න',
      'confirm_booking_title': 'වෙන්කිරීම තහවුරු කරන්න',
      'confirm_booking_prompt': 'ඔබ මෙම සේවාව වෙන්කරවා ගැනීමට කැමතිද? මෙමගින් සේවා සපයන්නා වෙත ඉල්ලීමක් යවනු ලැබේ.',
      'btn_cancel': 'අවලංගු කරන්න',
      'btn_confirm': 'තහවුරු කරන්න',
      'toast_request_sent': 'වෙන්කිරීමේ ඉල්ලීම සාර්ථකව යවන ලදී!',
      'profile_title': 'ප්‍රෝෆයිල්',
      'profile_edit': 'තොරතුරු සංස්කරණය',
      'profile_name': 'සම්පූර්ණ නම',
      'profile_email': 'විද්‍යුත් තැපෑල (වෙනස් කළ නොහැක)',
      'profile_uid': 'පරිශීලක හැඳුනුම්පත (UID)',
      'profile_role': 'ගිණුම් වර්ගය',
      'btn_save': 'තොරතුරු සුරකින්න',
      'btn_sign_out': 'ගිණුමෙන් ඉවත් වී PIN කේතය මකන්න',
      'toast_profile_updated': 'ප්‍රෝෆයිල් තොරතුරු සාර්ථකව යාවත්කාලීන කරන ලදී!',
      'lang_select': 'භාෂාව තෝරන්න',
      'dialog_signout_title': 'ගිණුමෙන් ඉවත් වෙන්නද?',
      'dialog_signout_body': 'ඔබට ස්ථිරවම ගිණුමෙන් ඉවත් වී ඔබගේ රහස් PIN අංකය මකා දැමීමට අවශ්‍යද? මීළඟ වතාවේ ඔබට නැවත පුරනය වීමට සිදුවේ.',
      'role_seeker': 'සේවා සොයන්නා',
      'role_provider': 'සේවා සපයන්නා',
      'pin_create': 'අංක 4ක රහස් PIN කේතයක් සාදන්න',
      'pin_confirm': 'රහස් PIN කේතය තහවුරු කරන්න',
      'pin_enter': 'ඔබගේ රහස් PIN කේතය ඇතුළත් කරන්න',
      'pin_mismatch': 'PIN කේතයන් නොගැලපේ. නැවත සාදන්න',
      'pin_incorrect': 'PIN කේතය වැරදියි. නැවත උත්සාහ කරන්න',
      'btn_back_to_create': 'නැවත PIN එකක් සෑදීමට',
      'auth_welcome': 'ලංකා ක්වික් වෙත සාදරයෙන් පිළිගනිමු',
      'auth_subtitle': 'දේශීය සේවා සපයන්නන් සමඟ ක්ෂණිකව සම්බන්ධ වන්න',
      'auth_login': 'පුරනය වන්න',
      'auth_signup': 'ලියාපදිංචි වන්න',
      'auth_no_account': 'ගිණුමක් නොමැතිද? ලියාපදිංචි වන්න',
      'auth_has_account': 'දැනටමත් ගිණුමක් තිබේද? පුරනය වන්න',
      'auth_btn_submit': 'ඉදිරිපත් කරන්න',
      'auth_validation_name': 'කරුණාකර ඔබගේ නම ඇතුත් කරන්න',
      'auth_validation_email': 'කරුණාකර වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න',
      'auth_validation_pass': 'මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය',
      'demo_mode_banner': 'Supabase ධාවනය වන්නේ ආදර්ශන ප්‍රකාරයෙනි (දේශීය සැකසුම් ගොනුව නොමැත).',
      'bookings_title': 'මගේ වෙන් කිරීම්',
      'bookings_empty': 'වෙන් කිරීම් කිසිවක් හමු නොවිය.',
      'bookings_signin': 'වෙන් කිරීම් බැලීමට කරුණාකර පුරනය වන්න.',
      'bookings_id': 'වෙන්කිරීමේ අංකය',
      'btn_accept': 'පිළිගන්න',
      'btn_decline': 'ප්‍රතික්ෂේප කරන්න',
      'btn_cancel_request': 'ඉල්ලීම අවලංගු කරන්න',
      'btn_complete_work': 'සේවාව අවසන් කරන්න',
      'nav_nearby': 'දේශීය සිතියම',
      'map_search_hint': 'අසල සේවාවන් සොයන්න...',
      'btn_track': 'සජීවීව බලන්න',
      'btn_start_journey': 'ගමන අරඹන්න',
      'btn_arrived': 'ළඟා වූ බව දන්වන්න',
      'share_location': 'සජීවී පිහිටීම බෙදාගන්න',
      'location_updated': 'පිහිටීම යාවත්කාලීන කරන ලදි',
      'distance_away': 'කි.මී. දුරින්',
      'eta_mins': 'මිනිත්තු',
      'status_en_route': 'පැමිණෙමින්',
      'status_arrived': 'ළඟා වී ඇත',
      'tracking_title': 'සජීවී සිතියම',
      'simulate_gps': 'GPS පිහිටීම පරීක්ෂා කරන්න',
      'btn_set_location': 'පිහිටීම තෝරන්න',
      'set_location_prompt': 'ඔබගේ සේවා ස්ථානය සැකසීමට පින් එක සකසන්න',
    },
    'ta': {
      'app_title': 'லங்கா குவிக் (LankaQuick)',
      'nav_marketplace': 'சந்தை',
      'nav_bookings': 'பதிவுகள்',
      'nav_profile': 'சுயவிவரம்',
      'search_hint': 'வகை வாரியாக சேவைகளைத் தேடுங்கள்...',
      'no_services_found': 'இந்த பிரிவில் எந்த சேவைகளும் காணப்படவில்லை.',
      'no_services_yet': 'சேவைகள் எதுவும் இன்னும் பட்டியலிடப்படவில்லை.',
      'btn_book_now': 'இப்போது புக் செய்யவும்',
      'btn_add_service': 'சேவையைச் சேர்க்கவும்',
      'sheet_add_title': 'புதிய சேவை பட்டியலைச் சேர்க்கவும்',
      'input_title': 'சேவையின் பெயர்',
      'input_price': 'மணிநேர / சேவை கட்டணம் (\$)',
      'input_desc': 'விளக்கம்',
      'btn_publish': 'சேவையை வெளியிடவும்',
      'select_category': 'முதன்மை வகையைத் தேர்ந்தெடுக்கவும்',
      'select_subcategory': 'துணை வகையைத் தேர்ந்தெடுக்கவும்',
      'confirm_booking_title': 'பதிவை உறுதிப்படுத்தவும்',
      'confirm_booking_prompt': 'இந்த சேவையை புக் செய்ய விரும்புகிறீர்களா? இது வழங்குநருக்கு கோரிக்கையை அனுப்பும்.',
      'btn_cancel': 'ரத்துசெய்',
      'btn_confirm': 'உறுதிப்படுத்து',
      'toast_request_sent': 'புக் செய்வதற்கான கோரிக்கை வெற்றிகரமாக அனுப்பப்பட்டது!',
      'profile_title': 'சுயவிவரம்',
      'profile_edit': 'விவரங்களை திருத்தவும்',
      'profile_name': 'முழு பெயர்',
      'profile_email': 'மின்னஞ்சல் (மாற்ற முடியாது)',
      'profile_uid': 'பயனர் ஐடி (UID)',
      'profile_role': 'கணக்கு வகை',
      'btn_save': 'மாற்றங்களை சேமிக்கவும்',
      'btn_sign_out': 'வெளியேறி PIN ஐ மீட்டமைக்கவும்',
      'toast_profile_updated': 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!',
      'lang_select': 'பயன்பாட்டு மொழி',
      'dialog_signout_title': 'வெளியேற வேண்டுமா?',
      'dialog_signout_body': 'நிச்சயமாக வெளியேறி உங்கள் ரகசிய PIN குறியீட்டை அழிக்க வேண்டுமா? அடுத்த முறை நீங்கள் மீண்டும் உள்நுழைய வேண்டும்.',
      'role_seeker': 'சேவை தேடுபவர்',
      'role_provider': 'சேவை வழங்குநர்',
      'pin_create': 'உங்கள் 4 இலக்க PIN குறியீட்டை உருவாக்கவும்',
      'pin_confirm': 'உங்கள் 4 இலக்க PIN குறியீட்டை உறுதிப்படுத்தவும்',
      'pin_enter': 'உள்நுழைய PIN குறியீட்டை உள்ளிடவும்',
      'pin_mismatch': 'PIN குறியீடுகள் பொருந்தவில்லை. மீண்டும் உருவாக்கவும்',
      'pin_incorrect': 'தவறான PIN. மீண்டும் முயற்சிக்கவும்',
      'btn_back_to_create': 'மீண்டும் உருவாக்கச் செல்லவும்',
      'auth_welcome': 'லங்கா குவிக் இற்கு வரவேற்கிறோம்',
      'auth_subtitle': 'உள்ளூர் சேவை வழங்குநர்களுடன் உடனுக்குடன் இணையுங்கள்',
      'auth_login': 'உள்நுழைய',
      'auth_signup': 'பதிவு செய்ய',
      'auth_no_account': 'கணக்கு இல்லையா? பதிவு செய்ய',
      'auth_has_account': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைய',
      'auth_btn_submit': 'சமர்ப்பிக்கவும்',
      'auth_validation_name': 'தயவுசெய்து உங்கள் பெயரை உள்ளிடவும்',
      'auth_validation_email': 'தயவுசெய்து செல்லுபடியாகும் மின்னஞ்சலை உள்ளிடவும்',
      'auth_validation_pass': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகளாக இருக்க வேண்டும்',
      'demo_mode_banner': 'Supabase டெமோ பயன்முறையில் இயங்குகிறது (உள்ளூர் கட்டமைப்பு கோப்பு இல்லை).',
      'bookings_title': 'எனது பதிவுகள்',
      'bookings_empty': 'பதிவுகள் எதுவும் இல்லை.',
      'bookings_signin': 'பதிவுகளைப் பார்க்க உள்நுழையவும்.',
      'bookings_id': 'பதிவு எண்',
      'btn_accept': 'ஏற்றுக்கொள்',
      'btn_decline': 'நிராகரி',
      'btn_cancel_request': 'கோரிக்கையை ரத்துசெய்',
      'btn_complete_work': 'வேலையை முடி',
      'nav_nearby': 'வரைபடம்',
      'map_search_hint': 'அருகிலுள்ள சேவைகளைத் தேடு...',
      'btn_track': 'நேரடி கண்காணிப்பு',
      'btn_start_journey': 'பயணத்தைத் தொடங்கு',
      'btn_arrived': 'வந்துவிட்டேன்',
      'share_location': 'இருப்பிடத்தைப் பகிர்கிறது',
      'location_updated': 'இருப்பிடம் புதுப்பிக்கப்பட்டது',
      'distance_away': 'கிமீ தொலைவில்',
      'eta_mins': 'நிமிடங்கள்',
      'status_en_route': 'வழியில்',
      'status_arrived': 'வந்துவிட்டது',
      'tracking_title': 'நேரடி கண்காணிப்பு',
      'simulate_gps': 'ஜிபிஎஸ் உருவகப்படுத்துதல்',
      'btn_set_location': 'இருப்பிடத்தை அமை',
      'set_location_prompt': 'சேவை இருப்பிடத்தை அமைக்க பின்னை இழுக்கவும்',
    }
  };

  static String translate(String key, String locale) {
    return _localizedValues[locale]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  // Returns the localized name of a subcategory key
  static String translateSubcategory(String key, String locale) {
    for (var cat in categories) {
      for (var sub in cat.subcategories) {
        if (sub.key == key) {
          return sub.getName(locale);
        }
      }
    }
    return key;
  }

  // Returns the localized name of a category key
  static String translateCategory(String key, String locale) {
    for (var cat in categories) {
      if (cat.key == key) {
        return cat.getName(locale);
      }
    }
    return key;
  }
}

// Global localization helper
String tr(WidgetRef ref, String key) {
  final locale = ref.watch(localeStateProvider);
  return AppLocalizations.translate(key, locale);
}

@riverpod
class LocaleState extends _$LocaleState {
  static const String _localePrefsKey = 'app_user_locale';

  @override
  String build() {
    _loadLocale();
    return 'en';
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localePrefsKey);
    if (saved != null && (saved == 'en' || saved == 'si' || saved == 'ta')) {
      state = saved;
    }
  }

  Future<void> setLocale(String langCode) async {
    if (langCode == 'en' || langCode == 'si' || langCode == 'ta') {
      state = langCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefsKey, langCode);
    }
  }
}
