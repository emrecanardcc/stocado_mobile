import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../cargo/widgets/cargo_company_logo.dart';
import '../models/pricing_plan_model.dart';

/// Verilen desi değeri için plan içindeki fiyat dilimlerine bakarak fiyat hesaplar.
/// Desi kademeleri: zeroTwoDesi (0-2), fiveDesi (5), tenDesi (10), twentyDesi (20),
/// thirtyDesi (30) ve additionalDesi (+1 ek desi).
double _getPriceForDesi(PricingPlan plan, int desi) {
  if (desi <= 2) return plan.zeroTwoDesi;
  if (desi <= 5) {
    // Lineer interpolasyon: 2 ile 5 arası
    if (plan.fiveDesi <= 0) return plan.zeroTwoDesi;
    final ratio = (desi - 2) / (5 - 2);
    return plan.zeroTwoDesi + ratio * (plan.fiveDesi - plan.zeroTwoDesi);
  }
  if (desi <= 10) {
    if (plan.tenDesi <= 0) return plan.fiveDesi;
    final ratio = (desi - 5) / (10 - 5);
    return plan.fiveDesi + ratio * (plan.tenDesi - plan.fiveDesi);
  }
  if (desi <= 20) {
    if (plan.twentyDesi <= 0) return plan.tenDesi;
    final ratio = (desi - 10) / (20 - 10);
    return plan.tenDesi + ratio * (plan.twentyDesi - plan.tenDesi);
  }
  if (desi <= 30) {
    if (plan.thirtyDesi <= 0) return plan.twentyDesi;
    final ratio = (desi - 20) / (30 - 20);
    return plan.twentyDesi + ratio * (plan.thirtyDesi - plan.twentyDesi);
  }
  // 30'dan büyük desi: ek desi ücreti ile hesapla
  if (plan.additionalDesi > 0) {
    return plan.thirtyDesi + (desi - 30) * plan.additionalDesi;
  }
  return plan.thirtyDesi;
}

class _CalcResult {
  final PricingPlan plan;
  final double price;
  _CalcResult({required this.plan, required this.price});
}

class LivePriceCalculator extends StatefulWidget {
  final List<PricingPlan> plans;

  const LivePriceCalculator({super.key, required this.plans});

  @override
  State<LivePriceCalculator> createState() => _LivePriceCalculatorState();
}

class _LivePriceCalculatorState extends State<LivePriceCalculator> {
  final TextEditingController _desiController = TextEditingController(text: '2');
  double _sliderValue = 2.0;
  bool _filterPod = false;
  bool _filterControlled = false;

  @override
  void dispose() {
    _desiController.dispose();
    super.dispose();
  }

  List<_CalcResult> get _results {
    final raw = int.tryParse(_desiController.text.trim()) ?? 2;
    final desi = raw.clamp(1, 999);

    final filtered = widget.plans.where((plan) {
      if (_filterPod && !plan.hasPod) return false;
      if (_filterControlled && !plan.hasControlledDelivery) return false;
      return true;
    }).toList();

    final results = filtered.map((plan) {
      final price = _getPriceForDesi(plan, desi);
      return _CalcResult(plan: plan, price: price);
    }).toList();

    results.sort((a, b) => a.price.compareTo(b.price));
    return results;
  }

  void _onSliderChanged(double val) {
    setState(() {
      _sliderValue = val;
      _desiController.text = val.round().toString();
    });
  }

  void _onDesiInputChanged(String text) {
    final val = int.tryParse(text.trim());
    if (val != null) {
      setState(() {
        _sliderValue = val.clamp(1, 30).toDouble();
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CANLI FIYAT HESAPLA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD8B4FE)),
                ),
                child: const Text(
                  'KDV DAHIL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6B21A8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Desi Giriş Alanı + Slider
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gonderi Desisi:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _desiController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: _onDesiInputChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'DESI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    min: 1,
                    max: 30,
                    value: _sliderValue,
                    onChanged: _onSliderChanged,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('1 Desi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    Text('10 Desi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    Text('20 Desi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    Text('30 Desi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Filtre Kutuları: Kapıda Ödeme & Kontrollü Teslimat
          Row(
            children: [
              Expanded(child: _buildFilterToggle('Kapida Odeme', _filterPod, (v) => setState(() => _filterPod = v))),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterToggle('Kontrollu Teslimat', _filterControlled, (v) => setState(() => _filterControlled = v))),
            ],
          ),
          const SizedBox(height: 12),

          // Sonuç Listesi
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),

          if (results.isEmpty)
            _buildNoResultsMessage()
          else
            Column(
              children: results.asMap().entries.map((entry) {
                final i = entry.key;
                final result = entry.value;
                final isCheapest = i == 0 && result.price > 0;
                return _buildResultRow(result, isCheapest);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: value ? AppColors.primary : AppColors.textSecondary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: value ? AppColors.primary : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(_CalcResult result, bool isCheapest) {
    final plan = result.plan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Logo
          CargoCompanyLogo(
            companyId: plan.code,
            companyName: plan.companyName,
            height: 18,
            width: 80,
          ),
          const SizedBox(width: 8),
          // Şirket Adı
          Expanded(
            child: Text(
              plan.companyName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // EN UYGUN FİYAT Rozeti
          if (isCheapest) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: const Text(
                'EN UYGUN',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF065F46),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          // Fiyat
          Text(
            result.price > 0 ? AppFormatters.formatCurrency(result.price) : '-',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _filterPod || _filterControlled
              ? 'Secilen filtrelerle uyumlu tarife bulunamadi.'
              : 'Hesaplanacak tarife bulunamadi.',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
