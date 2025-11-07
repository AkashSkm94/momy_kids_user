import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/bottom_navigation_bar.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/components/image_widgets.dart';
import '../../../core/constants/images_utils.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/local_storage_manager.dart';
import '../../../core/utils/Common.dart';
import '../../../core/network/url_manager.dart';
import '../model/product_model.dart';
import '../view_model/products_view_model.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ProductsViewModel _viewModel;
  int _currentBottomNavIndex = 2; // Products tab
  String _userName = '';
  String? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductsViewModel();
    _loadUserName();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProducts(reset: true);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls to 80% of the list
      _viewModel.loadMore();
    }
  }

  Future<void> _loadUserName() async {
    final storage = await LocalStorageManager.getInstance();
    final name = storage.getString(LocalStorageManager.keyUserName) ?? '';
    if (mounted) {
      setState(() {
        _userName = name.isNotEmpty ? name : 'User';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<ProductsViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: _buildAppBar(appLanguage, localizations),
        body: _buildBody(localizations),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
            _handleNavigation(index);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLanguage appLanguage,
    AppLocalizations localizations,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F9FF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
        onPressed: () => NavigationService.goBack(),
      ),
      title: Text(
        'Hello $_userName!',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorPalette.textPrimary,
        ),
      ),
      actions: [
        // Language Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Common.languageIcons(
            context: context,
            appLanguage: appLanguage,
            onLanguageChange: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ),
        // Profile Picture
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildBody(AppLocalizations localizations) {
    return Consumer<ProductsViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          color: ColorPalette.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSearchBar(localizations),
                    const SizedBox(height: 16),
                    // Category Filters
                    _buildCategoryFilters(localizations, viewModel),
                    const SizedBox(height: 16),
                    // Special Offer Banner
                    _buildSpecialOfferBanner(localizations),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // Products Section
              if (viewModel.isLoading && viewModel.products.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: ColorPalette.primary),
                  ),
                )
              else if (viewModel.errorMessage.isNotEmpty && viewModel.products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: ColorPalette.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.refresh(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            localizations.translate('retry') ?? 'Retry',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('popular_products') ?? 'Popular Products',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              
              // Products Grid
              if (viewModel.products.isEmpty && !viewModel.isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      localizations.translate('no_products_found') ?? 'No products found',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: ColorPalette.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < viewModel.products.length) {
                          return _buildProductCard(
                            viewModel.products[index],
                            localizations,
                          );
                        } else if (viewModel.hasMore) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: ColorPalette.primary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      childCount: viewModel.products.length + 
                          (viewModel.isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            _viewModel.setSearchQuery(value);
            // Debounce search - search after user stops typing for 800ms
            _searchDebounceTimer?.toString(); // Cancel previous timer
            _searchDebounceTimer = value;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (_searchController.text == value && 
                  _searchDebounceTimer == value && 
                  mounted) {
                _viewModel.searchProducts(value);
              }
            });
          },
          onSubmitted: (value) => _viewModel.searchProducts(value),
          decoration: InputDecoration(
            hintText: localizations.translate('search_for_awesome_stuff') ?? 'Search for awesome stuff',
            hintStyle: TextStyle(
              fontFamily: 'Montserrat',
              color: ColorPalette.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: ColorPalette.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
    AppLocalizations localizations,
    ProductsViewModel viewModel,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = category == viewModel.selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => viewModel.setSelectedCategory(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? ColorPalette.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? ColorPalette.primary 
                        : ColorPalette.textSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Colors.white 
                          : ColorPalette.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialOfferBanner(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorPalette.primary.withOpacity(0.8),
              ColorPalette.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('special_offer') ?? 'Special Offer!',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        localizations.translate('get_20_off_toys') ?? 'Get 20% off on all toys',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all toys
              },
              child: Text(
                localizations.translate('view_all') ?? 'View all →',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    AppLocalizations localizations,
  ) {
    // Get image URL
    final imageUrl = product.primaryImageUrl != null
        ? '${UrlManager.imageBaseUrl}${product.primaryImageUrl}'
        : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: BaseImage(
                            networkUrl: imageUrl,
                            source: ImageSource.network,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: const Center(
                              child: Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                            placeholder: const Center(
                              child: CircularProgressIndicator(
                                color: ColorPalette.primary,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Category Tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorPalette.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.categoryName,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Product Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    product.description,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: ColorPalette.textSecondary.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Stock info
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: product.stock > 0 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Home
        NavigationService.navigateAndReplace(AppRoutes.home);
        break;
      case 1: // Services
        // TODO: Navigate to services
        break;
      case 2: // Products
        // Already on products page
        break;
      case 3: // Cart
        // TODO: Navigate to cart
        break;
      case 4: // Menu/Profile
        NavigationService.navigateAndReplace(AppRoutes.profile);
        break;
    }
  }
}

