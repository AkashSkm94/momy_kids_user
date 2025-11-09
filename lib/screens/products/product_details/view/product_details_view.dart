import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/app_background.dart';
import '../../../../core/components/bottom_navigation_bar.dart';
import '../../../../core/components/image_widgets.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/localization/appLanguage.dart';
import '../../../../core/localization/appLocalization.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/Common.dart';
import '../view_model/product_details_view_model.dart';

class ProductDetailsView extends StatefulWidget {
  final String productId;

  const ProductDetailsView({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late ProductDetailsViewModel _viewModel;
  int _currentBottomNavIndex = 2; // Products tab

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailsViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProductDetails(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<ProductDetailsViewModel>(
      create: (context) => _viewModel,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLanguage appLanguage,
    AppLocalizations localizations,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
          onPressed: () => NavigationService.goBack(),
        ),
      ),
      title: Text(
        localizations.translate('product_details') ?? 'Product Details',
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
        Common.profileIcon(
          context: context,
          radius: 18,
          padding: const EdgeInsets.only(right: 16.0),
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations localizations) {
    return Consumer<ProductDetailsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorPalette.primary),
          );
        }

        if (viewModel.errorMessage.isNotEmpty) {
          return Center(
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
                  onPressed: () => viewModel.loadProductDetails(widget.productId),
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
          );
        }

        if (viewModel.product == null) {
          return Center(
            child: Text(
              localizations.translate('product_not_found') ?? 'Product not found',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: ColorPalette.textSecondary,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image Section
              _buildProductImageSection(viewModel),
              
              // Product Details Card
              _buildProductDetailsCard(viewModel, localizations),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImageSection(ProductDetailsViewModel viewModel) {
    final imageUrls = viewModel.getAllImageUrls();
    final currentImageUrl = viewModel.getCurrentImageUrl();
    
    return Stack(
      children: [
        // Main Product Image
        Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[200],
          child: currentImageUrl != null && currentImageUrl.isNotEmpty
              ? BaseImage(
                  networkUrl: '${UrlManager.imageBaseUrl}$currentImageUrl',
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
                )
              : const Center(
                  child: Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
        ),
        
        // Image Indicators (dots)
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewModel.selectedImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetailsCard(
    ProductDetailsViewModel viewModel,
    AppLocalizations localizations,
  ) {
    final product = viewModel.product!;
    final imageUrls = viewModel.getAllImageUrls();
    
    return Container(
      width: double.infinity,
      //margin: const EdgeInsets.only(top: -20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Name and Category Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorPalette.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.categoryName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price and Rating
            Row(
              children: [
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primary,
                  ),
                ),
                const SizedBox(width: 16),
                _buildRatingBar(product.rating),
              ],
            ),

            const SizedBox(height: 16),

            // // Sold By (placeholder)
            Row(
              children: [
                Text(
                  '${localizations.translate('sold_by') ?? 'Sold by'}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: ColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${product.soldBy}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: ColorPalette.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Image Carousel (if multiple images)
            if (imageUrls.length > 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        final isSelected = viewModel.selectedImageIndex == index;
                        return GestureDetector(
                          onTap: () => viewModel.setSelectedImageIndex(index),
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? ColorPalette.primary
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: BaseImage(
                                networkUrl: '${UrlManager.imageBaseUrl}${imageUrls[index]}',
                                source: ImageSource.network,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorWidget: const Icon(Icons.image, size: 30),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Description Section
            Text(
              localizations.translate('description') ?? 'Description',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: ColorPalette.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Features Section
            // Text(
            //   localizations.translate('features') ?? 'Features',
            //   style: const TextStyle(
            //     fontFamily: 'Montserrat',
            //     fontSize: 18,
            //     fontWeight: FontWeight.w600,
            //     color: ColorPalette.textPrimary,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // _buildFeatureItem(localizations.translate('high_quality_material') ?? 'High Quality Material'),
            // _buildFeatureItem(localizations.translate('safe_for_kids') ?? 'Safe for Kids'),
            // _buildFeatureItem(localizations.translate('fast_delivery') ?? 'Fast Delivery'),
            // _buildFeatureItem(localizations.translate('30_days_return_policy') ?? '30 Days Return Policy'),

            //const SizedBox(height: 32),

            // Stock Info
            Text(
              '${localizations.translate('stock') ?? 'Stock'}: ${product.stock}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: product.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement add to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.translate('added_to_cart') ?? 'Added to cart',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations.translate('add_to_cart') ?? 'Add to Cart',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(double rating) {
    final clampedRating = rating.clamp(0, 5).toDouble();
    final fullStars = clampedRating.floor();
    final hasHalfStar = (clampedRating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        Row(
          children: [
            for (int i = 0; i < fullStars; i++)
              const Icon(Icons.star, size: 20, color: Colors.amber),
            if (hasHalfStar)
              const Icon(Icons.star_half, size: 20, color: Colors.amber),
            for (int i = 0; i < emptyStars; i++)
              const Icon(Icons.star_border, size: 20, color: Colors.amber),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          clampedRating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ColorPalette.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(price);
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: ColorPalette.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: ColorPalette.textSecondary,
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
        NavigationService.navigateAndReplace(AppRoutes.products);
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

