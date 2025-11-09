import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_background.dart';
import '../../../core/components/bottom_navigation_bar.dart';
import '../../../core/components/primary-button.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/Common.dart';
import '../../../core/components/image_widgets.dart';
import '../model/cart_item_model.dart';
import '../view_model/cart_view_model.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  int _currentBottomNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<CartViewModel>(
      create: (_) => CartViewModel(),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(localizations),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Expanded(
                  child: Consumer<CartViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isEmpty) {
                        return _buildEmptyState(localizations);
                      }

                      return ListView.separated(
                        itemBuilder: (context, index) {
                          final item = viewModel.items[index];
                          return _buildCartItem(
                            context: context,
                            viewModel: viewModel,
                            localizations: localizations,
                            item: item,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: viewModel.items.length,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<CartViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildOrderSummary(
                          context: context,
                          localizations: localizations,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label:
                              localizations.translate('proceed_to_checkout'),
                          onClick: () {
                            // TODO: Hook up checkout navigation
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentBottomNavIndex,
            onTap: _handleBottomNavTap,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
          onPressed: () => NavigationService.goBack(),
        ),
      ),
      title: Text(
        localizations.translate('cart_title'),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: ColorPalette.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Common.profileIcon(
            context: context,
            radius: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 64, color: ColorPalette.textSecondary),
          const SizedBox(height: 16),
          Text(
            localizations.translate('cart_empty_title'),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('cart_empty_subtitle'),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: ColorPalette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required BuildContext context,
    required CartViewModel viewModel,
    required AppLocalizations localizations,
    required CartItemModel item,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BaseImage(
              source: ImageSource.network,
              networkUrl: item.imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: ColorPalette.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => viewModel.removeItem(item.id),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.vendor,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: ColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorPalette.primary,
                      ),
                    ),
                    const Spacer(),
                    _buildQuantityControl(
                      context: context,
                      localizations: localizations,
                      item: item,
                      viewModel: viewModel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl({
    required BuildContext context,
    required AppLocalizations localizations,
    required CartItemModel item,
    required CartViewModel viewModel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECF2FF),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: ColorPalette.primary,
            onPressed: () => viewModel.decrementQuantity(item.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.quantity.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: ColorPalette.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: ColorPalette.primary,
            onPressed: () => viewModel.incrementQuantity(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary({
    required BuildContext context,
    required AppLocalizations localizations,
    required CartViewModel viewModel,
  }) {
    final textStyleLabel = const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: ColorPalette.textSecondary,
    );

    final textStyleValue = const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: ColorPalette.textPrimary,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('order_summary'),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: localizations.translate('items_label'),
            value: viewModel.totalItems.toString(),
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: localizations.translate('subtotal'),
            value: '\$${viewModel.subtotal.toStringAsFixed(2)}',
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: localizations.translate('discount'),
            value: '-\$${viewModel.discount.toStringAsFixed(2)}',
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: localizations.translate('delivery_charges'),
            value: '\$${viewModel.deliveryCharges.toStringAsFixed(2)}',
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue,
          ),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            label: localizations.translate('total'),
            value: '\$${viewModel.total.toStringAsFixed(2)}',
            labelStyle: textStyleLabel.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            valueStyle: textStyleValue.copyWith(
              fontSize: 16,
              color: ColorPalette.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle,
          ),
        ),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    if (_currentBottomNavIndex == index) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        NavigationService.navigateAndReplace(AppRoutes.home);
        break;
      case 1:
        // TODO: Navigate to services screen when available
        break;
      case 2:
        NavigationService.navigateAndReplace(AppRoutes.products);
        break;
      case 3:
        // Already on cart
        break;
      case 4:
        NavigationService.navigateAndReplace(AppRoutes.profile);
        break;
    }
  }
}

