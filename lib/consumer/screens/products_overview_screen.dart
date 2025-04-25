import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/products_grid.dart';
import '../../widgets/cart_badge.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/wallet_provider.dart';
import 'cart_screen.dart';
import 'wallet_screen.dart';
import '../../models/product.dart';
import '../../l10n/app_localizations.dart';

enum FilterOptions {
  all,
  vegetables,
  fruits,
  crops,
  poultry,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  String? _selectedCategory;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Future.microtask(() {
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Do you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldLogout) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('AgroKart'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.filter_list),
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  switch (selectedValue) {
                    case FilterOptions.all:
                      _selectedCategory = null;
                      break;
                    case FilterOptions.vegetables:
                      _selectedCategory = 'Vegetables';
                      break;
                    case FilterOptions.fruits:
                      _selectedCategory = 'Fruits';
                      break;
                    case FilterOptions.crops:
                      _selectedCategory = 'Crops';
                      break;
                    case FilterOptions.poultry:
                      _selectedCategory = 'Poultry';
                      break;
                  }
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: FilterOptions.all,
                  child: Text('All Products'),
                ),
                const PopupMenuItem(
                  value: FilterOptions.vegetables,
                  child: Text('Vegetables'),
                ),
                const PopupMenuItem(
                  value: FilterOptions.fruits,
                  child: Text('Fruits'),
                ),
                const PopupMenuItem(
                  value: FilterOptions.crops,
                  child: Text('Crops'),
                ),
                const PopupMenuItem(
                  value: FilterOptions.poultry,
                  child: Text('Poultry'),
                ),
              ],
            ),
            // Wallet Button with loyalty points indicator
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WalletScreen(),
                      ),
                    );
                  },
                ),
                if (walletProvider.totalPoints > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        walletProvider.totalPoints.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Consumer<CartProvider>(
              builder: (_, cart, child) => CartBadge(
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresh from the Farm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Support local farmers and get fresh, high-quality produce delivered to your doorstep.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == null
                        ? 'All Products'
                        : _selectedCategory!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  PopupMenuButton(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Sort'),
                        SizedBox(width: 4),
                        Icon(Icons.sort),
                      ],
                    ),
                    onSelected: (SortOption value) {
                      productsData.setSortOption(value);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: SortOption.nameAsc,
                        child: Text('Name (A to Z)'),
                      ),
                      const PopupMenuItem(
                        value: SortOption.nameDesc,
                        child: Text('Name (Z to A)'),
                      ),
                      const PopupMenuItem(
                        value: SortOption.priceAsc,
                        child: Text('Price (Low to High)'),
                      ),
                      const PopupMenuItem(
                        value: SortOption.priceDesc,
                        child: Text('Price (High to Low)'),
                      ),
                      const PopupMenuItem(
                        value: SortOption.organic,
                        child: Text('Organic First'),
                      ),
                      const PopupMenuItem(
                        value: SortOption.newest,
                        child: Text('Newest First'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: productsData.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : productsData.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading products',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                productsData.error!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Provider.of<ProductsProvider>(context,
                                          listen: false)
                                      .fetchProducts();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : productsData.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_basket_outlined,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products available',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check back later for fresh products',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                await Provider.of<ProductsProvider>(context,
                                        listen: false)
                                    .fetchProducts();
                              },
                              child: ProductsGrid(
                                selectedCategory: _selectedCategory,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
