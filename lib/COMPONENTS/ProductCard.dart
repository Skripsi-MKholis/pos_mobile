import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'Components.dart';

class MyProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isGridView;
  final bool isSelected;
  final bool isSelectionMode;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int? quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final NumberFormat? currencyFormat;

  const MyProductCard({
    super.key,
    required this.product,
    this.isGridView = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.showActions = false,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = currencyFormat ??
        NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

    if (isGridView) {
      return _buildGridCard(context, fmt);
    } else {
      return _buildListCard(context, fmt);
    }
  }

  Widget _buildListCard(BuildContext context, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? Warna.Primary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: Warna.Primary.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BounceTapper(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Row(
                children: [
                  if (isSelectionMode) ...[
                    Icon(
                      isSelected ? TablerIcons.checkbox : TablerIcons.square,
                      color: isSelected ? Warna.Primary : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  MyNetworkImage(
                    imageUrl: product['image'],
                    width: 60,
                    height: 60,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              product['category'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (product['stock'] ?? 0) > 0 ||
                                        product['isInfiniteStock'] == true
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product['isInfiniteStock'] == true
                                    ? 'Stok: ∞'
                                    : 'Stok: ${product['stock'] ?? 0}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: (product['stock'] ?? 0) > 0 ||
                                          product['isInfiniteStock'] == true
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                            if (product['variants'] != null &&
                                product['variants'].isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Warna.Primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Varian',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Warna.Primary,
                                  ),
                                ),
                              ),
                            if (product['isBestSeller'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      TablerIcons.crown,
                                      color: Colors.orange,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Terlaris',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (product['appliedDiscount'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product['appliedDiscount']['type'] ==
                                          'Persentase (%)'
                                      ? 'Diskon ${product['appliedDiscount']['value']}%'
                                      : 'DISKON',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildPriceInfo(fmt),
                      ],
                    ),
                  ),
                  if (quantity != null && quantity! > 0) ...[
                    const SizedBox(width: 12),
                    _buildQuantityControls(isGrid: false),
                  ],
                ],
              ),
            ),
          ),
          if (showActions && !isSelectionMode)
            Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    TablerIcons.edit,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    TablerIcons.trash,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, NumberFormat fmt) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Warna.Primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: Warna.Primary.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BounceTapper(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: MyNetworkImage(
                      imageUrl: product['image'],
                      width: double.infinity,
                      // We'll use a custom property for top-only rounding if needed, 
                      // but for now borderRadius 20 is handled by ClipRRect in MyNetworkImage.
                      // To match vertical top only, I might need to update MyNetworkImage.
                      borderRadius: 20, 
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product['category'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: (product['stock'] ?? 0) > 0 ||
                                      product['isInfiniteStock'] == true
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product['isInfiniteStock'] == true
                                  ? '∞'
                                  : '${product['stock'] ?? 0}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: (product['stock'] ?? 0) > 0 ||
                                        product['isInfiniteStock'] == true
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                          if (product['variants'] != null &&
                              product['variants'].isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              TablerIcons.layers_intersect,
                              size: 14,
                              color: Warna.Primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPriceInfo(fmt),
                          if (quantity != null && quantity! > 0)
                            _buildQuantityControls(isGrid: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected
                        ? TablerIcons.circle_check_filled
                        : TablerIcons.circle,
                    color: isSelected ? Warna.Primary : Colors.grey[300],
                    size: 24,
                  ),
                ),
              ),
            if (showActions && !isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _buildGridAction(TablerIcons.edit, Colors.blue, onEdit),
                    const SizedBox(width: 4),
                    _buildGridAction(TablerIcons.trash, Colors.red, onDelete),
                  ],
                ),
              ),
            // Badges
            Positioned(
              top: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['isBestSeller'] == true)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            TablerIcons.crown,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Terlaris',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (product['appliedDiscount'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        product['appliedDiscount']['type'] == 'Persentase (%)'
                            ? '-${product['appliedDiscount']['value']}%'
                            : 'HEMAT',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridAction(IconData icon, Color color, VoidCallback? action) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        onPressed: action,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildPriceInfo(NumberFormat fmt) {
    if (product['appliedDiscount'] != null) {
      final disc = product['appliedDiscount'];
      final originalPrice = product['price'];
      final discountedPrice = disc['type'] == 'Persentase (%)'
          ? originalPrice * (1 - disc['value'] / 100)
          : originalPrice - disc['value'];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fmt.format(originalPrice),
            style: GoogleFonts.plusJakartaSans(
              fontSize: isGridView ? 10 : 12,
              color: Colors.grey[400],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            fmt.format(discountedPrice),
            style: GoogleFonts.plusJakartaSans(
              fontSize: isGridView ? 13 : 14,
              fontWeight: FontWeight.bold,
              color: Warna.Primary,
            ),
          ),
        ],
      );
    } else {
      return Text(
        fmt.format(product['price']),
        style: GoogleFonts.plusJakartaSans(
          fontSize: isGridView ? 13 : 14,
          fontWeight: FontWeight.bold,
          color: Warna.Primary,
        ),
      );
    }
  }

  Widget _buildQuantityControls({required bool isGrid}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              TablerIcons.minus,
              color: Colors.red,
              size: 14,
            ),
          ),
        ),
        SizedBox(width: isGrid ? 8 : 12),
        Text(
          '$quantity',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(width: isGrid ? 8 : 12),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Warna.Primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              TablerIcons.plus,
              color: Warna.Primary,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}
