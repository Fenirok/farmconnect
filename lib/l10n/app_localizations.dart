import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
    Locale('ta'),
    Locale('te'),
    Locale('mr'),
    Locale('gu'),
    Locale('kn'),
    Locale('ml'),
    Locale('pa'),
    Locale('or'),
    Locale('as'),
    Locale('ne'),
    Locale('mai'),
    Locale('sa'),
    Locale('kok'),
    Locale('doi'),
    Locale('bho'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome to FarmConnect',
      'selectLanguage': 'Select your language',
      'continue': 'Continue',
      'english': 'English',
      'hindi': 'Hindi',
      'bengali': 'Bengali',
      'tamil': 'Tamil',
      'telugu': 'Telugu',
      'marathi': 'Marathi',
      'gujarati': 'Gujarati',
      'kannada': 'Kannada',
      'malayalam': 'Malayalam',
      'punjabi': 'Punjabi',
      'odia': 'Odia',
      'assamese': 'Assamese',
      'nepali': 'Nepali',
      'maithili': 'Maithili',
      'sanskrit': 'Sanskrit',
      'konkani': 'Konkani',
      'dogri': 'Dogri',
      'bhojpuri': 'Bhojpuri',
      'selectRole': 'Select your role',
      'farmer': 'Farmer',
      'consumer': 'Consumer',
      'selectState': 'Select State',
      'kisanId': 'Kisan ID',
      'aadharId': 'Aadhar ID',
      'phoneNumber': 'Phone Number',
      'generateOTP': 'Generate OTP',
      'verifyOTP': 'Enter OTP',
      'verify': 'Verify',
      'login': 'Login',
      'signup': 'Sign Up',
      'enterValidPhoneNumber': 'Please enter a valid 10-digit phone number',
      'enterValidOTP': 'Please enter the 6-digit OTP',
      'enterName': 'Enter your name',
      'enterValidAddress': 'Enter your address',
      'enterKisanId': 'Enter your Kisan ID',
      'enterPhoneNumber': 'Please enter your phone number',
      'resendOTP': 'Resend OTP',
      'enterAadharId': 'Enter your Aadhaar ID',
      'enterValidAadharId': 'Please enter a valid 12-digit Aadhaar ID',

      // Dashboard Screen
      'dashboard': 'Dashboard',
      'welcomeFarmer': 'Welcome, Farmer!',
      'totalProducts': 'Total Products',
      'activeOrders': 'Active Orders',
      'monthlySales': 'Monthly Sales',
      'salesGrowth': 'Sales Growth',

      // Products Screen
      'products': 'Products',
      'addProduct': 'Add Product',
      'searchProducts': 'Search products...',
      'edit': 'Edit',
      'delete': 'Delete',
      'stock': 'Stock',
      'addProductTitle': 'Add Product',
      'editProductTitle': 'Edit Product',
      'name': 'Name',
      'type': 'Type',
      'selectType': 'Select a type',
      'unit': 'Unit',
      'selectUnit': 'Select a unit',
      'price': 'Price',
      'enterValidPrice': 'Enter a valid price',
      'enterValidStock': 'Enter valid stock',
      'stockMustBeGreater': 'Stock must be greater than 50',
      'tags': 'Tags (comma separated)',
      'add': 'Add',
      'save': 'Save',
      'deleteProduct': 'Delete Product',
      'deleteConfirmation': 'Are you sure you want to delete',
      'cancel': 'Cancel',

      // Product Names
      'organicTomatoes': 'Organic Tomatoes',
      'freshCarrots': 'Fresh Carrots',
      'greenPeppers': 'Green Peppers',
      'vegetable': 'Vegetable',
      'organic': 'Organic',
      'fresh': 'Fresh',

      // Orders Screen
      'myOrders': 'My Orders',
      'searchOrders': 'Search orders...',
      'filterByStatus': 'Filter by status',
      'allOrders': 'All Orders',
      'processing': 'Processing',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'noOrdersFound': 'No orders found!',
      'order': 'Order',
      'date': 'Date',
      'items': 'Items',
      'total': 'Total',
      'transactionId': 'Transaction ID',
      'paymentMethod': 'Payment Method',
      'deliveryAddress': 'Delivery Address',
      'orderItems': 'Order Items',
      'contactSupport': 'Contact Support',

      // Profile Screen
      'myProfile': 'My Profile',
      'editProfile': 'Edit profile feature coming soon!',
      'orders': 'Orders',
      'negotiations': 'Negotiations',
      'favorites': 'Favorites',
      'myAddresses': 'My Addresses',
      'addressesFeature': 'Addresses feature coming soon!',
      'myFavorites': 'My Favorites',
      'favoritesFeature': 'Favorites feature coming soon!',
      'paymentMethods': 'Payment Methods',
      'paymentMethodsFeature': 'Payment methods feature coming soon!',
      'helpAndSupport': 'Help & Support',
      'helpFeature': 'Help & Support feature coming soon!',
      'settings': 'Settings',
      'settingsFeature': 'Settings feature coming soon!',
      'logout': 'Logout',
      'logoutConfirmation': 'Are you sure you want to logout?',

      // Product Overview Screen
      'sortBy': 'Sort by',
      'nameAZ': 'Name (A-Z)',
      'nameZA': 'Name (Z-A)',
      'priceLowHigh': 'Price (Low-High)',
      'priceHighLow': 'Price (High-Low)',
      'newest': 'Newest',
      'noProductsFound': 'No products found!',
      'retry': 'Retry',

      // Negotiation strings
      'originalPrice': 'Original Price',
      'offeredPrice': 'Offered Price',
      'counterOffer': 'Counter Offer',
      'accept': 'Accept',
      'reject': 'Reject',
      'accepted': 'Accepted',
      'rejected': 'Rejected',
      'submit': 'Submit',

      // Consumer specific messages
      'noConsumerProfileFound':
          'No consumer profile found with this phone number. Please sign up first.',
      'consumerProfileNotFound':
          'Consumer profile not found. Please sign up first.',
      'otpVerifiedSuccess': 'OTP verified successfully',

      // Error Messages
      'networkError':
          'Network error. Please check your internet connection and try again.',
      'connectionTimeout':
          'Connection timeout. Please check your internet connection and try again.',
      'anErrorOccurred': 'An error occurred. Please try again.',
      'profileNotFound': 'Profile Not Found',
      'noFarmerProfileFound':
          'No farmer profile found with this phone number. Please register first.',
      'farmerProfileNotFound':
          'Farmer profile not found. Please register first.',
      'otpSentSuccess': 'OTP sent successfully',
      'register': 'Register',

      // Product Overview Screen
      'freshFromFarm': 'Fresh from Farm',
      'supportLocalFarmers': 'Support Local Farmers',
      'allProducts': 'All Products',
      'vegetables': 'Vegetables',
      'fruits': 'Fruits',
      'crops': 'Crops',
      'poultry': 'Poultry',
      'sort': 'Sort',
      'errorLoadingProducts': 'Error loading products',
      'noProductsAvailable': 'No products available',
      'checkBackLater': 'Check back later',
    },
    'hi': {
      'welcome': 'फार्मकनेक्ट में आपका स्वागत है',
      'selectLanguage': 'अपनी भाषा चुनें',
      'continue': 'जारी रखें',
      'english': 'अंग्रे़ी',
      'hindi': 'हिंदी',
      'bengali': 'बंगाली',
      'tamil': 'तमिल',
      'telugu': 'तेलुगु',
      'marathi': 'मराठी',
      'gujarati': 'गुजराती',
      'kannada': 'कन्नड़',
      'malayalam': 'मलयालम',
      'punjabi': 'पंजाबी',
      'odia': 'उड़िया',
      'assamese': 'असमिया',
      'nepali': 'नेपाली',
      'maithili': 'मैथिली',
      'sanskrit': 'संस्कृत',
      'konkani': 'कोंकणी',
      'dogri': 'डोगरी',
      'bhojpuri': 'भोजपुरी',
      'selectRole': 'अपनी भूमिका चुनें',
      'farmer': 'किसान',
      'consumer': 'उपभोक्ता',
      'selectState': 'राज्य चुनें',
      'kisanId': 'किसान आईडी',
      'aadharId': 'आधार आईडी',
      'phoneNumber': 'फोन नंबर',
      'generateOTP': 'ओटीपी जनरेट करें',
      'verifyOTP': 'ओटीपी दर्ज करें',
      'verify': 'सत्यापित करें',
      'login': 'लॉगिन करें',
      'signup': 'साइन अप करें',
      'enterValidPhoneNumber': 'कृपया 10 अंकों का वैध फोन नंबर दर्ज करें',
      'enterValidOTP': 'कृपया 6 अंकों का ओटीपी दर्ज करें',
      'enterName': 'अपना नाम दर्ज करें',
      'enterValidAddress': 'अपना पता दर्ज करें',
      'enterKisanId': 'अपना किसान आईडी दर्ज करें',
      'enterPhoneNumber': 'कृपया अपना फोन नंबर दर्ज करें',
      'resendOTP': 'ओटीपी पुनः भेजें',
      'enterAadharId': 'आधार आईडी दर्ज करें',
      'enterValidAadharId': 'कृपया 12 अंकों का वैध आधार आईडी दर्ज करें',

      // Dashboard Screen
      'dashboard': 'डैशबोर्ड',
      'welcomeFarmer': 'स्वागत है, किसान!',
      'totalProducts': 'कुल उत्पाद',
      'activeOrders': 'सक्रिय ऑर्डर',
      'monthlySales': 'मासिक बिक्री',
      'salesGrowth': 'बिक्री वृद्धि',

      // Products Screen
      'products': 'उत्पाद',
      'addProduct': 'उत्पाद जोड़ें',
      'searchProducts': 'उत्पाद खोजें...',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'stock': 'स्टॉक',
      'addProductTitle': 'उत्पाद जोड़ें',
      'editProductTitle': 'उत्पाद संपादित करें',
      'name': 'नाम',
      'type': 'प्रकार',
      'selectType': 'प्रकार चुनें',
      'unit': 'इकाई',
      'selectUnit': 'इकाई चुनें',
      'price': 'मूल्य',
      'enterValidPrice': 'वैध मूल्य दर्ज करें',
      'enterValidStock': 'वैध स्टॉक दर्ज करें',
      'stockMustBeGreater': 'स्टॉक 50 से अधिक होना चाहिए',
      'tags': 'टैग (कॉमा से अलग)',
      'add': 'जोड़ें',
      'save': 'सहेजें',
      'deleteProduct': 'उत्पाद हटाएं',
      'deleteConfirmation': 'क्या आप निश्चित हैं कि आप हटाना चाहते हैं',
      'cancel': 'रद्द करें',

      // Product Names
      'organicTomatoes': 'जैविक टमाटर',
      'freshCarrots': 'ताजा गाजर',
      'greenPeppers': 'हरी मिर्च',
      'vegetable': 'सब्जी',
      'organic': 'जैविक',
      'fresh': 'ताजा',

      // Orders Screen
      'myOrders': 'मेरे ऑर्डर',
      'searchOrders': 'ऑर्डर खोजें...',
      'filterByStatus': 'स्थिति के अनुसार फ़िल्टर करें',
      'allOrders': 'सभी ऑर्डर',
      'processing': 'प्रोसेसिंग',
      'delivered': 'डिलीवर किया गया',
      'cancelled': 'रद्द किया गया',
      'noOrdersFound': 'कोई ऑर्डर नहीं मिला!',
      'order': 'ऑर्डर',
      'date': 'दिनांक',
      'items': 'आइटम',
      'total': 'कुल',
      'transactionId': 'लेनदेन आईडी',
      'paymentMethod': 'भुगतान विधि',
      'deliveryAddress': 'डिलीवरी पता',
      'orderItems': 'ऑर्डर आइटम',
      'contactSupport': 'सहायता से संपर्क करें',

      // Profile Screen
      'myProfile': 'मेरी प्रोफाइल',
      'editProfile': 'प्रोफाइल संपादित करने की सुविधा जल्द ही आ रही है!',
      'orders': 'ऑर्डर',
      'negotiations': 'बातचीत',
      'favorites': 'पसंदीदा',
      'myAddresses': 'मेरे पते',
      'addressesFeature': 'पते की सुविधा जल्द ही आ रही है!',
      'myFavorites': 'मेरे पसंदीदा',
      'favoritesFeature': 'पसंदीदा सुविधा जल्द ही आ रही है!',
      'paymentMethods': 'भुगतान विधियां',
      'paymentMethodsFeature': 'भुगतान विधियों की सुविधा जल्द ही आ रही है!',
      'helpAndSupport': 'सहायता और समर्थन',
      'helpFeature': 'सहायता और समर्थन सुविधा जल्द ही आ रही है!',
      'settings': 'सेटिंग्स',
      'settingsFeature': 'सेटिंग्स सुविधा जल्द ही आ रही है!',
      'logout': 'लॉगआउट',
      'logoutConfirmation': 'क्या आप लॉगआउट करना चाहते हैं?',

      // Product Overview Screen
      'sortBy': 'इसके अनुसार क्रमबद्ध करें',
      'nameAZ': 'नाम (A-Z)',
      'nameZA': 'नाम (Z-A)',
      'priceLowHigh': 'मूल्य (कम-अधिक)',
      'priceHighLow': 'मूल्य (अधिक-कम)',
      'newest': 'नवीनतम',
      'noProductsFound': 'कोई प्रोडक्ट नहीं मिला!',
      'retry': 'पुनः प्रयास करें',

      // Negotiation strings
      'originalPrice': 'मूल कीमत',
      'offeredPrice': 'प्रस्तावित कीमत',
      'counterOffer': 'काउंटर ऑफर',
      'accept': 'स्वीकार करें',
      'reject': 'अस्वीकार करें',
      'accepted': 'स्वीकृत',
      'rejected': 'अस्वीकृत',
      'submit': 'जमा करें',

      // Consumer specific messages
      'noConsumerProfileFound':
          'इस फोन नंबर से कोई उपभोक्ता प्रोफ़ाइल नहीं मिली। कृपया पहले साइन अप करें।',
      'consumerProfileNotFound':
          'उपभोक्ता प्रोफ़ाइल नहीं मिली। कृपया पहले साइन अप करें।',
      'otpVerifiedSuccess': 'ओटीपी सफलतापूर्वक सत्यापित किया गया',

      // Error Messages
      'networkError':
          'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।',
      'connectionTimeout':
          'कनेक्शन टाइमआउट। कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।',
      'anErrorOccurred': 'एक त्रुटि हुई। कृपया पुनः प्रयास करें।',
      'profileNotFound': 'प्रोफ़ाइल नहीं मिली',
      'noFarmerProfileFound':
          'इस फोन नंबर से कोई किसान प्रोफ़ाइल नहीं मिली। कृपया पहले पंजीकरण करें।',
      'farmerProfileNotFound':
          'किसान प्रोफ़ाइल नहीं मिली। कृपया पहले पंजीकरण करें।',
      'otpSentSuccess': 'ओटीपी सफलतापूर्वक भेजा गया',
      'register': 'पंजीकरण करें',

      // Product Overview Screen
      'freshFromFarm': 'ताजा से फार्म',
      'supportLocalFarmers': 'स्थानीय किसानों का समर्थन',
      'allProducts': 'सभी उत्पाद',
      'vegetables': 'सब्जियां',
      'fruits': 'फल',
      'crops': 'फसल',
      'poultry': 'मोटरी',
      'sort': 'क्रमबद्ध करें',
      'errorLoadingProducts': 'उत्पाद लोड करने में त्रुटि',
      'noProductsAvailable': 'उत्पाद उपलब्ध नहीं',
      'checkBackLater': 'बाद में फिर जाएं',
    },
    'bn': {
      'welcome': 'ফার্মকানেক্টে আপনাকে স্বাগতম',
      'selectLanguage': 'আপনার ভাষা নির্বাচন করুন',
      'continue': 'চালিয়ে যান',
      'english': 'ইংরেজি',
      'hindi': 'হিন্দি',
      'bengali': 'বাংলা',
      'tamil': 'তামিল',
      'telugu': 'তেলুগু',
      'marathi': 'মারাঠি',
      'gujarati': 'গুজরাটি',
      'kannada': 'কন্নড়',
      'malayalam': 'মালায়ালাম',
      'punjabi': 'পাঞ্জাবি',
      'odia': 'ওড়িয়া',
      'assamese': 'অসমীয়া',
      'nepali': 'নেপালি',
      'maithili': 'মৈথিলি',
      'sanskrit': 'সংস্কৃত',
      'konkani': 'কোঙ্কণি',
      'dogri': 'ডোগরি',
      'bhojpuri': 'ভোজপুরি',
      'selectRole': 'আপনার ভূমিকা নির্বাচন করুন',
      'farmer': 'কৃষক',
      'consumer': 'ভোক্তা',
      'selectState': 'রাজ্য নির্বাচন করুন',
      'kisanId': 'কিসান আইডি',
      'aadharId': 'আধার আইডি',
      'phoneNumber': 'ফোন নম্বর',
      'generateOTP': 'ওটিপি তৈরি করুন',
      'verifyOTP': 'ওটিপি দিন',
      'verify': 'যাচাই করুন',
      'login': 'লগইন করুন',
      'signup': 'সাইন আপ করুন',
      'enterValidPhoneNumber': 'দয়া করে 10 ডিজিটের একটি বৈধ ফোন নম্বর লিখুন',
      'enterValidOTP': 'দয়া করে 6 ডিজিটের ওটিপি লিখুন',
      'enterName': 'আপনার নাম লিখুন',
      'enterValidAddress': 'আপনার ঠিকানা লিখুন',
      'enterKisanId': 'আপনার কিসান আইডি লিখুন',
      'enterPhoneNumber': 'দয়া করে আপনার ফোন নম্বর লিখুন',
      'resendOTP': 'ওটিপি পুনঃ ভেজান',
      'enterAadharId': 'আধার আইডি দিন',
      'enterValidAadharId': 'দয়া করে 12 ডিজিটের একটি বৈধ আধার আইডি লিখুন',

      // Dashboard Screen
      'dashboard': 'ড্যাশবোর্ড',
      'welcomeFarmer': 'স্বাগতম, কৃষক!',
      'totalProducts': 'মোট পণ্য',
      'activeOrders': 'সক্রিয় অর্ডার',
      'monthlySales': 'মাসিক বিক্রয়',
      'salesGrowth': 'বিক্রয় বৃদ্ধি',

      // Products Screen
      'products': 'পণ্য',
      'addProduct': 'পণ্য যোগ করুন',
      'searchProducts': 'পণ্য খুঁজুন...',
      'edit': 'সম্পাদনা করুন',
      'delete': 'মুছুন',
      'stock': 'স্টক',
      'addProductTitle': 'পণ্য যোগ করুন',
      'editProductTitle': 'পণ্য সম্পাদনা করুন',
      'name': 'নাম',
      'type': 'ধরন',
      'selectType': 'একটি ধরন নির্বাচন করুন',
      'unit': 'একক',
      'selectUnit': 'একটি একক নির্বাচন করুন',
      'price': 'মূল্য',
      'enterValidPrice': 'একটি বৈধ মূল্য লিখুন',
      'enterValidStock': 'একটি বৈধ স্টক লিখুন',
      'stockMustBeGreater': 'স্টক 50 এর বেশি হতে হবে',
      'tags': 'ট্যাগ (কমা দিয়ে আলাদা)',
      'add': 'যোগ করুন',
      'save': 'সংরক্ষণ করুন',
      'deleteProduct': 'পণ্য মুছুন',
      'deleteConfirmation': 'আপনি কি নিশ্চিত যে আপনি মুছতে চান',
      'cancel': 'বাতিল করুন',

      // Product Names
      'organicTomatoes': 'জৈব টমেটো',
      'freshCarrots': 'তাজা গাজর',
      'greenPeppers': 'সবুজ মরিচ',
      'vegetable': 'শাকসবজি',
      'organic': 'জৈব',
      'fresh': 'তাজা',

      // Orders Screen
      'myOrders': 'আমার অর্ডার',
      'searchOrders': 'অর্ডার খুঁজুন...',
      'filterByStatus': 'স্ট্যাটাস অনুসারে ফিল্টার করুন',
      'allOrders': 'সব অর্ডার',
      'processing': 'প্রক্রিয়াধীন',
      'delivered': 'বিতরণ করা হয়েছে',
      'cancelled': 'বাতিল করা হয়েছে',
      'noOrdersFound': 'কোন অর্ডার পাওয়া যায়নি!',
      'order': 'অর্ডার',
      'date': 'তারিখ',
      'items': 'আইটেম',
      'total': 'মোট',
      'transactionId': 'লেনদেন আইডি',
      'paymentMethod': 'পেমেন্ট পদ্ধতি',
      'deliveryAddress': 'ডেলিভারি ঠিকানা',
      'orderItems': 'অর্ডার আইটেম',
      'contactSupport': 'সাপোর্টের সাথে যোগাযোগ করুন',

      // Profile Screen
      'myProfile': 'আমার প্রোফাইল',
      'editProfile': 'প্রোফাইল সম্পাদনার ফিচার শীঘ্রই আসছে!',
      'orders': 'অর্ডার',
      'negotiations': 'আলোচনা',
      'favorites': 'পছন্দসই',
      'myAddresses': 'আমার ঠিকানা',
      'addressesFeature': 'ঠিকানা ফিচার শীঘ্রই আসছে!',
      'myFavorites': 'আমার পছন্দসই',
      'favoritesFeature': 'পছন্দসই ফিচার শীঘ্রই আসছে!',
      'paymentMethods': 'পেমেন্ট পদ্ধতি',
      'paymentMethodsFeature': 'পেমেন্ট পদ্ধতি ফিচার শীঘ্রই আসছে!',
      'helpAndSupport': 'সাহায্য ও সমর্থন',
      'helpFeature': 'সাহায্য ও সমর্থন ফিচার শীঘ্রই আসছে!',
      'settings': 'সেটিংস',
      'settingsFeature': 'সেটিংস ফিচার শীঘ্রই আসছে!',
      'logout': 'লগআউট',
      'logoutConfirmation': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',

      // Product Overview Screen
      'sortBy': 'সাজানোর ধরন',
      'nameAZ': 'নাম (A-Z)',
      'nameZA': 'নাম (Z-A)',
      'priceLowHigh': 'মূল্য (কম-অধিক)',
      'priceHighLow': 'মূল্য (অধিক-কম)',
      'newest': 'সবচেয়ে নতুন',
      'noProductsFound': 'কোন পণ্য পাওয়া যায়নি!',
      'retry': 'আবার চেষ্টা করুন',

      // Negotiation strings
      'originalPrice': 'মূল মূল্য',
      'offeredPrice': 'প্রস্তাবিত মূল্য',
      'counterOffer': 'কাউন্টার অফার',
      'accept': 'গ্রহণ করুন',
      'reject': 'অগ্রাধিকার করুন',
      'accepted': 'গ্রহণযোগ্য',
      'rejected': 'অগ্রাধিকার',
      'submit': 'জমা দিন',

      // Consumer specific messages
      'noConsumerProfileFound':
          'এই ফোন নম্বরে কোনো ভোক্তা প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে প্রথমে সাইন আপ করুন।',
      'consumerProfileNotFound':
          'ভোক্তা প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে প্রথমে সাইন আপ করুন।',
      'otpVerifiedSuccess': 'ওটিপি সফলভাবে যাচাই করা হয়েছে',

      // Error Messages
      'networkError':
          'নেটওয়ার্ক ত্রুটি। অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।',
      'connectionTimeout':
          'সংযোগ সময়সীমা শেষ। অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।',
      'anErrorOccurred': 'একটি ত্রুটি ঘটেছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
      'profileNotFound': 'প্রোফাইল পাওয়া যায়নি',
      'noFarmerProfileFound':
          'এই ফোন নম্বরে কোনো কৃষক প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে প্রথমে নিবন্ধন করুন।',
      'farmerProfileNotFound':
          'কৃষক প্রোফাইল পাওয়া যায়নি। অনুগ্রহ করে প্রথমে নিবন্ধন করুন।',
      'otpSentSuccess': 'ওটিপি সফলভাবে পাঠানো হয়েছে',
      'register': 'নিবন্ধন করুন',

      // Product Overview Screen
      'freshFromFarm': 'ताजा से फार्म',
      'supportLocalFarmers': 'स्थानीय किसानों का समर्थन',
      'allProducts': 'सभी उत्पाद',
      'vegetables': 'सब्जियां',
      'fruits': 'फल',
      'crops': 'फसल',
      'poultry': 'मोटरी',
      'sort': 'क्रमबद्ध करें',
      'errorLoadingProducts': 'उत्पाद लोड करने में त्रुटि',
      'noProductsAvailable': 'उत्पाद उपलब्ध नहीं',
      'checkBackLater': 'बाद में फिर जाएं',
    },
  };

  String _getLocalizedValue(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String get welcome => _getLocalizedValue('welcome');
  String get selectLanguage => _getLocalizedValue('selectLanguage');
  String get continueButton => _getLocalizedValue('continue');
  String get english => _getLocalizedValue('english');
  String get hindi => _getLocalizedValue('hindi');
  String get bengali => _getLocalizedValue('bengali');
  String get selectRole => _getLocalizedValue('selectRole');
  String get farmer => _getLocalizedValue('farmer');
  String get consumer => _getLocalizedValue('consumer');
  String get selectState => _getLocalizedValue('selectState');
  String get kisanId => _getLocalizedValue('kisanId');
  String get aadharId => _getLocalizedValue('aadharId');
  String get phoneNumber => _getLocalizedValue('phoneNumber');
  String get generateOTP => _getLocalizedValue('generateOTP');
  String get verifyOTP => _getLocalizedValue('verifyOTP');
  String get verify => _getLocalizedValue('verify');
  String get login => _getLocalizedValue('login');
  String get signup => _getLocalizedValue('signup');

  // Dashboard Screen
  String get dashboard => _getLocalizedValue('dashboard');
  String get welcomeFarmer => _getLocalizedValue('welcomeFarmer');
  String get totalProducts => _getLocalizedValue('totalProducts');
  String get activeOrders => _getLocalizedValue('activeOrders');
  String get monthlySales => _getLocalizedValue('monthlySales');
  String get salesGrowth => _getLocalizedValue('salesGrowth');

  // Products Screen
  String get products => _getLocalizedValue('products');
  String get addProduct => _getLocalizedValue('addProduct');
  String get searchProducts => _getLocalizedValue('searchProducts');
  String get edit => _getLocalizedValue('edit');
  String get delete => _getLocalizedValue('delete');
  String get stock => _getLocalizedValue('stock');
  String get addProductTitle => _getLocalizedValue('addProductTitle');
  String get editProductTitle => _getLocalizedValue('editProductTitle');
  String get name => _getLocalizedValue('name');
  String get type => _getLocalizedValue('type');
  String get selectType => _getLocalizedValue('selectType');
  String get unit => _getLocalizedValue('unit');
  String get selectUnit => _getLocalizedValue('selectUnit');
  String get price => _getLocalizedValue('price');
  String get enterValidPrice => _getLocalizedValue('enterValidPrice');
  String get enterValidStock => _getLocalizedValue('enterValidStock');
  String get stockMustBeGreater => _getLocalizedValue('stockMustBeGreater');
  String get tags => _getLocalizedValue('tags');
  String get add => _getLocalizedValue('add');
  String get save => _getLocalizedValue('save');
  String get deleteProduct => _getLocalizedValue('deleteProduct');
  String get deleteConfirmation => _getLocalizedValue('deleteConfirmation');
  String get cancel => _getLocalizedValue('cancel');

  // Product Names
  String get organicTomatoes => _getLocalizedValue('organicTomatoes');
  String get freshCarrots => _getLocalizedValue('freshCarrots');
  String get greenPeppers => _getLocalizedValue('greenPeppers');
  String get vegetable => _getLocalizedValue('vegetable');
  String get organic => _getLocalizedValue('organic');
  String get fresh => _getLocalizedValue('fresh');

  // Orders Screen
  String get myOrders => _getLocalizedValue('myOrders');
  String get searchOrders => _getLocalizedValue('searchOrders');
  String get filterByStatus => _getLocalizedValue('filterByStatus');
  String get allOrders => _getLocalizedValue('allOrders');
  String get processing => _getLocalizedValue('processing');
  String get delivered => _getLocalizedValue('delivered');
  String get cancelled => _getLocalizedValue('cancelled');
  String get noOrdersFound => _getLocalizedValue('noOrdersFound');
  String get order => _getLocalizedValue('order');
  String get date => _getLocalizedValue('date');
  String get items => _getLocalizedValue('items');
  String get total => _getLocalizedValue('total');
  String get transactionId => _getLocalizedValue('transactionId');
  String get paymentMethod => _getLocalizedValue('paymentMethod');
  String get deliveryAddress => _getLocalizedValue('deliveryAddress');
  String get orderItems => _getLocalizedValue('orderItems');
  String get contactSupport => _getLocalizedValue('contactSupport');

  // Profile Screen
  String get myProfile => _getLocalizedValue('myProfile');
  String get editProfile => _getLocalizedValue('editProfile');
  String get orders => _getLocalizedValue('orders');
  String get negotiations => _getLocalizedValue('negotiations');
  String get favorites => _getLocalizedValue('favorites');
  String get myAddresses => _getLocalizedValue('myAddresses');
  String get addressesFeature => _getLocalizedValue('addressesFeature');
  String get myFavorites => _getLocalizedValue('myFavorites');
  String get favoritesFeature => _getLocalizedValue('favoritesFeature');
  String get paymentMethods => _getLocalizedValue('paymentMethods');
  String get paymentMethodsFeature =>
      _getLocalizedValue('paymentMethodsFeature');
  String get helpAndSupport => _getLocalizedValue('helpAndSupport');
  String get helpFeature => _getLocalizedValue('helpFeature');
  String get settings => _getLocalizedValue('settings');
  String get settingsFeature => _getLocalizedValue('settingsFeature');
  String get logout => _getLocalizedValue('logout');
  String get logoutConfirmation => _getLocalizedValue('logoutConfirmation');

  String get enterValidPhoneNumber =>
      _getLocalizedValue('enterValidPhoneNumber');
  String get enterValidOTP => _getLocalizedValue('enterValidOTP');
  String get enterName => _getLocalizedValue('enterName');
  String get enterValidAddress => _getLocalizedValue('enterValidAddress');
  String get enterKisanId => _getLocalizedValue('enterKisanId');
  String get enterPhoneNumber => _getLocalizedValue('enterPhoneNumber');
  String get enterAadharId => _getLocalizedValue('enterAadharId');
  String get enterValidAadharId => _getLocalizedValue('enterValidAadharId');

  String get sortBy => _getLocalizedValue('sortBy');
  String get nameAZ => _getLocalizedValue('nameAZ');
  String get nameZA => _getLocalizedValue('nameZA');
  String get priceLowHigh => _getLocalizedValue('priceLowHigh');
  String get priceHighLow => _getLocalizedValue('priceHighLow');
  String get newest => _getLocalizedValue('newest');
  String get noProductsFound => _getLocalizedValue('noProductsFound');
  String get retry => _getLocalizedValue('retry');

  String get resendOTP => _getLocalizedValue('resendOTP');

  // Negotiation getters
  String get originalPrice => _getLocalizedValue('originalPrice');
  String get offeredPrice => _getLocalizedValue('offeredPrice');
  String get counterOffer => _getLocalizedValue('counterOffer');
  String get accept => _getLocalizedValue('accept');
  String get reject => _getLocalizedValue('reject');
  String get accepted => _getLocalizedValue('accepted');
  String get rejected => _getLocalizedValue('rejected');
  String get submit => _getLocalizedValue('submit');

  String get noConsumerProfileFound =>
      _getLocalizedValue('noConsumerProfileFound');
  String get consumerProfileNotFound =>
      _getLocalizedValue('consumerProfileNotFound');
  String get otpVerifiedSuccess => _getLocalizedValue('otpVerifiedSuccess');

  // Error Messages
  String get networkError => _getLocalizedValue('networkError');
  String get connectionTimeout => _getLocalizedValue('connectionTimeout');
  String get anErrorOccurred => _getLocalizedValue('anErrorOccurred');
  String get profileNotFound => _getLocalizedValue('profileNotFound');
  String get noFarmerProfileFound => _getLocalizedValue('noFarmerProfileFound');
  String get farmerProfileNotFound =>
      _getLocalizedValue('farmerProfileNotFound');
  String get otpSentSuccess => _getLocalizedValue('otpSentSuccess');
  String get register => _getLocalizedValue('register');

  // Product Overview Screen
  String get freshFromFarm => _getLocalizedValue('freshFromFarm');
  String get supportLocalFarmers => _getLocalizedValue('supportLocalFarmers');
  String get allProducts => _getLocalizedValue('allProducts');
  String get vegetables => _getLocalizedValue('vegetables');
  String get fruits => _getLocalizedValue('fruits');
  String get crops => _getLocalizedValue('crops');
  String get poultry => _getLocalizedValue('poultry');
  String get sort => _getLocalizedValue('sort');
  String get errorLoadingProducts => _getLocalizedValue('errorLoadingProducts');
  String get noProductsAvailable => _getLocalizedValue('noProductsAvailable');
  String get checkBackLater => _getLocalizedValue('checkBackLater');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'hi',
      'bn',
      'ta',
      'te',
      'mr',
      'gu',
      'kn',
      'ml',
      'pa',
      'or',
      'as',
      'ne',
      'mai',
      'sa',
      'kok',
      'doi',
      'bho'
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
