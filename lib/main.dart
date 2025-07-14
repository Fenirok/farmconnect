import 'package:farmconnect/farmer/screens/products_screen.dart';
import 'package:farmconnect/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:farmconnect/providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/negotiations_provider.dart';
import 'providers/language_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/welcome_screen.dart';
import 'consumer/screens/products_overview_screen.dart';
import 'consumer/screens/product_detail_screen.dart';
import 'consumer/screens/cart_screen.dart';
import 'consumer/screens/checkout_screen.dart';
import 'consumer/screens/payment_screen.dart';
import 'consumer/screens/order_confirmation_screen.dart';
import 'consumer/screens/chat_screen.dart';
import 'consumer/screens/chat_detail_screen.dart';
import 'consumer/screens/orders_screen.dart';
import 'consumer/screens/wallet_screen.dart';
import 'consumer/screens/negotiations_screen.dart';
import 'widgets/main_layout.dart';
import 'package:farmconnect/farmer/widgets/farmer_layout.dart';
import 'screens/farmer_login_screen.dart';
import 'screens/farmer_registration_screen.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'consumer/screens/consumer_login_screen.dart';
import 'consumer/screens/consumer_signup_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Spring Boot + PostgreSQL backend connection

  // Add error handling for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

// Create a key for the Navigator state to allow forced rebuilds if needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NegotiationsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WalletProvider(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (ctx, languageProvider, _) => MaterialApp(
          title: 'FarmConnect',
          navigatorKey: navigatorKey, // Use the global navigator key
          locale: languageProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              primary: Colors.green,
              secondary: Colors.orange,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green, width: 2.0),
              ),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            useMaterial3: true,
          ),
          home: const WelcomeScreen(),
          routes: {
            '/farmer-login': (ctx) => const FarmerLoginScreen(),
            ConsumerLoginScreen.routeName: (ctx) => const ConsumerLoginScreen(),
            ConsumerSignupScreen.routeName: (ctx) =>
                const ConsumerSignupScreen(),
            FarmerRegistrationScreen.routeName: (ctx) =>
                const FarmerRegistrationScreen(),
            ProductsOverviewScreen.routeName: (ctx) =>
                const ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            CheckoutScreen.routeName: (ctx) => const CheckoutScreen(),
            ChatScreen.routeName: (ctx) => const ChatScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            WalletScreen.routeName: (ctx) => const WalletScreen(),
            // For routes with required parameters, better to use onGenerateRoute
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case PaymentScreen.routeName:
                try {
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    settings: settings, // Keep the original settings
                    builder: (ctx) => PaymentScreen(
                      totalAmount: args?['totalAmount'] ?? 0.0,
                      customerEmail: args?['customerEmail'] ?? '',
                      deliveryMethod: args?['deliveryMethod'] ?? 'Standard',
                      deliveryCharge: args?['deliveryCharge'] ?? 5.0,
                    ),
                  );
                } catch (e) {
                  print('Error in onGenerateRoute for PaymentScreen: $e');
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (ctx) => const PaymentScreen(
                      totalAmount: 0,
                      customerEmail: '',
                      deliveryMethod: 'Standard',
                      deliveryCharge: 5.0,
                    ),
                  );
                }

              case OrderConfirmationScreen.routeName:
                try {
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (ctx) => OrderConfirmationScreen(
                      transactionId: args?['transactionId'] ?? '',
                      amount: args?['amount'] ?? 0.0,
                      customerEmail: args?['customerEmail'] ?? '',
                      deliveryMethod:
                          args?['deliveryMethod'] ?? 'Standard Delivery',
                      estimatedDelivery: args?['estimatedDelivery'] ?? '',
                    ),
                  );
                } catch (e) {
                  print(
                      'Error in onGenerateRoute for OrderConfirmationScreen: $e');
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (ctx) => const OrderConfirmationScreen(
                      transactionId: '',
                      amount: 0,
                      customerEmail: '',
                      deliveryMethod: 'Standard Delivery',
                      estimatedDelivery: '',
                    ),
                  );
                }

              case ChatDetailScreen.routeName:
                try {
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (ctx) => ChatDetailScreen(
                      farmerName: args?['farmerName'] ?? '',
                      productName: args?['productName'] ?? '',
                    ),
                  );
                } catch (e) {
                  print('Error in onGenerateRoute for ChatDetailScreen: $e');
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (ctx) => const ChatDetailScreen(
                      farmerName: 'Farmer',
                      productName: 'Product',
                    ),
                  );
                }

              default:
                return null;
            }
          },
          // Handle unknown routes
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (ctx) => const MainLayout(),
            );
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
