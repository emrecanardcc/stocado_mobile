import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../cargo/widgets/cargo_company_logo.dart';
import '../models/pricing_plan_model.dart';

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
    final raw = int.tryParse(_desiController.text.trim()) ?? 1;
    final desi = raw.clamp(1, 999);

    final filtered = widget.plans.where((plan) {
      if (_filterPod && !plan.hasPod) return false;
      if (_filterControlled && !plan.isPtt) return false;
      return true;
    }).toList();

    final results = filtered.map((plan) {
      final price = plan.calculatePrice(desi);
      return _CalcResult(plan: plan, price: price);
    }).toList();

    // 0 veya negatif fiyata sahip geçersiz tarifeleri sona at, geçerli fiyatları küçükten büyüğe sırala
    results.sort((a, b) {
      if (a.price <= 0 && b.price <= 0) return 0;
      if (a.price <= 0) return 1;
      if (b.price <= 0) return -1;
      return a.price.compareTo(b.price);
    });

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
      setState(() {
        _sliderValue = 1.0;
      });
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
              const Flexible(
                child: Text(
                  'CANLI FİYAT HESAPLA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD8B4FE)),
                ),
                child: const Text(
                  'KDV DAHİL',
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
                    const Flexible(
                      child: Text(
                        'Gönderi Desisi:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                          'DESİ',
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
              Expanded(child: _buildFilterToggle('Kapıda Ödeme', _filterPod, (v) => setState(() => _filterPod = v))),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterToggle('Kontrollü Teslimat', _filterControlled, (v) => setState(() => _filterControlled = v))),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 320;
          return Row(
            children: [
              // Logo
              CargoCompanyLogo(
                companyId: plan.code,
                companyName: plan.companyName,
                width: isNarrow ? 56 : 68,
                height: 24,
                borderRadius: 6,
              ),
              const SizedBox(width: 6),
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
              const SizedBox(width: 4),
              // EN UYGUN FİYAT Rozeti
              if (isCheapest) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isNarrow ? 68 : 78),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF6EE7B7)),
                      ),
                      child: const Text(
                        'EN UYGUN FİYAT',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // Fiyat
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isNarrow ? 76 : 90),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    result.price > 0 ? AppFormatters.formatCurrency(result.price) : '-',
                    style: TextStyle(
                      fontSize: isNarrow ? 11.5 : 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _filterPod || _filterControlled
              ? 'Seçilen filtrelerle uyumlu tarife bulunamadı.'
              : 'Hesaplanacak tarife bulunamadı.',
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
