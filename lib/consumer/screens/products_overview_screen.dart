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
                title: Text(appLocalizations.logout),
                content: Text(appLocalizations.logoutConfirmation),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(appLocalizations.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(appLocalizations.logout),
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
                      _selectedCategory = appLocalizations.vegetables;
                      break;
                    case FilterOptions.fruits:
                      _selectedCategory = appLocalizations.fruits;
                      break;
                    case FilterOptions.crops:
                      _selectedCategory = appLocalizations.crops;
                      break;
                    case FilterOptions.poultry:
                      _selectedCategory = appLocalizations.poultry;
                      break;
                  }
                });
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: FilterOptions.all,
                  child: Text(appLocalizations.allProducts),
                ),
                PopupMenuItem(
                  value: FilterOptions.vegetables,
                  child: Text(appLocalizations.vegetables),
                ),
                PopupMenuItem(
                  value: FilterOptions.fruits,
                  child: Text(appLocalizations.fruits),
                ),
                PopupMenuItem(
                  value: FilterOptions.crops,
                  child: Text(appLocalizations.crops),
                ),
                PopupMenuItem(
                  value: FilterOptions.poultry,
                  child: Text(appLocalizations.poultry),
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
                    appLocalizations.freshFromFarm,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLocalizations.supportLocalFarmers,
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
                        ? appLocalizations.allProducts
                        : _selectedCategory!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  PopupMenuButton(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(appLocalizations.sort),
                        const SizedBox(width: 4),
                        const Icon(Icons.sort),
                      ],
                    ),
                    onSelected: (SortOption value) {
                      productsData.setSortOption(value);
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: SortOption.nameAsc,
                        child: Text(appLocalizations.nameAZ),
                      ),
                      PopupMenuItem(
                        value: SortOption.nameDesc,
                        child: Text(appLocalizations.nameZA),
                      ),
                      PopupMenuItem(
                        value: SortOption.priceAsc,
                        child: Text(appLocalizations.priceLowHigh),
                      ),
                      PopupMenuItem(
                        value: SortOption.priceDesc,
                        child: Text(appLocalizations.priceHighLow),
                      ),
                      PopupMenuItem(
                        value: SortOption.organic,
                        child: Text(appLocalizations.organic),
                      ),
                      PopupMenuItem(
                        value: SortOption.newest,
                        child: Text(appLocalizations.newest),
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
                                appLocalizations.errorLoadingProducts,
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
                                child: Text(appLocalizations.retry),
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
                                    appLocalizations.noProductsAvailable,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appLocalizations.checkBackLater,
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
