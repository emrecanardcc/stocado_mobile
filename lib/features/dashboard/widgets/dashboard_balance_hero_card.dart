import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../screens/top_up_balance_screen.dart';

class DashboardBalanceHeroCard extends StatefulWidget {
  final double currentBalance;
  final double podReceivable;
  final VoidCallback? onTopUpTap;
  final VoidCallback? onMovementsTap;

  const DashboardBalanceHeroCard({
    super.key,
    required this.currentBalance,
    required this.podReceivable,
    this.onTopUpTap,
    this.onMovementsTap,
  });

  @override
  State<DashboardBalanceHeroCard> createState() => _DashboardBalanceHeroCardState();
}

class _DashboardBalanceHeroCardState extends State<DashboardBalanceHeroCard> {
  bool _isObscured = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1E38),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E1E38),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Arka plan zarif eğrisel gradyan efekti
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.info.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Satır: Başlık & Göz Butonu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kullanılabilir Bakiye',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 17,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. Satır: Büyük Net Bakiye Tutarı
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isObscured ? '•••••••• ₺' : AppFormatters.formatCurrency(widget.currentBalance),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Satır: Kapıda Ödeme Alacağı
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kapıda Ödeme Alacağı: ',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        _isObscured ? '•••• ₺' : AppFormatters.formatCurrency(widget.podReceivable),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Satır: Kart İçi Aksiyon Butonu (+ Bakiye Yükle - Geniş, Belirgin ve Şık)
                Semantics(
                  button: true,
                  label: '+ Bakiye Yükle',
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.onTopUpTap != null) {
                          widget.onTopUpTap!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TopUpBalanceScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0E1E38),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20, color: Color(0xFF0E1E38)),
                      label: const Text(
                        'Bakiye Yükle',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E1E38),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
