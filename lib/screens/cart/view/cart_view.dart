import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
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
      create: (_) {
        final viewModel = CartViewModel();
        viewModel.loadCart();
        return viewModel;
      },
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
                      if (viewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorPalette.primary,
                          ),
                        );
                      }

                      if (viewModel.errorMessage.isNotEmpty) {
                        return _buildErrorState(
                          localizations,
                          viewModel.errorMessage,
                          onRetry: () =>
                              context.read<CartViewModel>().loadCart(),
                        );
                      }

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
                    if (viewModel.isLoading || viewModel.isEmpty) {
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
      // leading: Container(
      //   margin: const EdgeInsets.all(8),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(10),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.05),
      //         blurRadius: 8,
      //         offset: const Offset(0, 2),
      //       ),
      //     ],
      //   ),
      //   child: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
      //     onPressed: () => NavigationService.goBack(),
      //   ),
      // ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BaseImage(
              source: ImageSource.network,
              networkUrl: item.imageUrl,
              width: 110,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => viewModel.removeItem(item.id),
                      child: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icDelete,),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorPalette.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (item.vendor.isNotEmpty)
                  Text(
                    item.vendor,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorPalette.textSecondary,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _formatPrice(item.unitPrice),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
        //color: ColorPalette.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: ColorPalette.primary,
                shape: BoxShape.circle),
            child: _buildQuantityButton(
              icon: Icons.remove,
              onTap: () => viewModel.decrementQuantity(item.id),
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              item.quantity.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: ColorPalette.primary,
                shape: BoxShape.circle),
            child: _buildQuantityButton(
              icon: Icons.add,
              onTap: () => viewModel.incrementQuantity(item.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
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
            value: _formatPrice(viewModel.subtotal),
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: localizations.translate('discount'),
            value: '-${_formatPrice(viewModel.discount)}',
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: localizations.translate('delivery_charges'),
            value: _formatPrice(viewModel.deliveryCharges),
            labelStyle: textStyleLabel,
            valueStyle: textStyleValue,
          ),
          const Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            label: localizations.translate('total'),
            value: _formatPrice(viewModel.total),
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

  Widget _buildErrorState(
    AppLocalizations localizations,
    String message, {
    required VoidCallback onRetry,
  }) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: ColorPalette.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
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

  String _formatPrice(double value) {
    final formatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(value);
  }

  void _handleBottomNavTap(int index) {
    if (_currentBottomNavIndex == index) return;

    NavigationService.handleBottomNavigation(
      currentIndex: _currentBottomNavIndex,
      targetIndex: index,
      onServicesTap: () {
        // TODO: Navigate to services screen when available
      },
    );

    setState(() {
      _currentBottomNavIndex = index;
    });
  }
}

