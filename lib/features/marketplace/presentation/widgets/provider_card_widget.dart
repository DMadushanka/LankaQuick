import 'package:flutter/material.dart';
import 'package:local_link/core/theme/app_theme.dart';
import 'package:local_link/features/marketplace/data/mock_providers_data.dart';

class ProviderCardWidget extends StatefulWidget {
  final MockProvider provider;

  const ProviderCardWidget({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderCardWidget> createState() => _ProviderCardWidgetState();
}

class _ProviderCardWidgetState extends State<ProviderCardWidget> {
  bool _hired = false;

  final List<Color> avatarColors = [
    const Color(0xFFF97316),
    const Color(0xFFA78BFA),
    const Color(0xFF34D399),
    const Color(0xFF3B82F6),
    const Color(0xFFF472B6),
    const Color(0xFF22D3EE),
    const Color(0xFFFB923C),
    const Color(0xFF4ADE80),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose color based on provider ID
    final int providerIdInt = int.tryParse(widget.provider.id) ?? 0;
    final Color color = avatarColors[providerIdInt % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.glassDecoration(
        isDark: isDark,
        borderRadius: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Available Badge
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.provider.avatar,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.provider.available)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.provider.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          fontFamily: 'Outfit',
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF3B82F6),
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.provider.category} · ${widget.provider.distance} away',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '★',
                      style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.provider.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '(${widget.provider.reviews})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '·',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.provider.jobs} jobs',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Action & Price Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.provider.price,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hired = !_hired;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: _hired 
                        ? null 
                        : AppTheme.primaryGradient,
                    color: _hired 
                        ? const Color(0x1F22C55E) // rgba(34,197,94,0.12)
                        : null,
                  ),
                  child: Text(
                    _hired ? '✓ Hired' : 'Hire',
                    style: TextStyle(
                      color: _hired ? const Color(0xFF22C55E) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
