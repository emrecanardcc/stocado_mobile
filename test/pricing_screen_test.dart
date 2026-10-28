import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocado_mobile/core/utils/app_formatters.dart';
import 'package:stocado_mobile/features/auth/providers/auth_provider.dart';
import 'package:stocado_mobile/features/pricing/models/pricing_plan_model.dart';
import 'package:stocado_mobile/features/pricing/providers/pricing_provider.dart';
import 'package:stocado_mobile/features/pricing/screens/pricing_screen.dart';
import 'package:stocado_mobile/features/pricing/widgets/live_price_calculator.dart';
import 'package:stocado_mobile/features/pricing/widgets/pricing_plan_card.dart';
import 'package:stocado_mobile/features/products/providers/products_provider.dart';

class _TestPricingNotifier extends PricingNotifier {
  final PricingState _initialState;
  _TestPricingNotifier(this._initialState);

  @override
  PricingState build() => _initialState;

  @override
  Future<void> loadPricingPlans() async {}

  @override
  Future<void> refresh() async {}
}

class _TestAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  _TestAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

class _TestProductsNotifier extends ProductsNotifier {
  final ProductsState _initialState;
  _TestProductsNotifier(this._initialState);

  @override
  ProductsState build() => _initialState;

  @override
  Future<void> loadProducts({bool reset = false}) async {}
}

PricingPlan _createDummyPlan({
  required String companyName,
  required String code,
  required double zeroTwo,
  required double five,
  required double ten,
  required double twenty,
  required double thirty,
  required double additional,
  bool hasPod = true,
  bool hasPodCreditCard = false,
  bool hasControlledDelivery = false,
  bool hasDoorPickup = true,
  String returnRate = '%50',
  String notes = 'Standart teslimat kurallari gecerlidir.',
}) {
  return PricingPlan(
    companyName: companyName,
    code: code,
    tariffName: '$companyName Standart Tarife',
    logo: '',
    zeroTwoDesi: zeroTwo,
    fiveDesi: five,
    tenDesi: ten,
    twentyDesi: twenty,
    thirtyDesi: thirty,
    additionalDesi: additional,
    returnRate: returnRate,
    hasPod: hasPod,
    hasPodCreditCard: hasPodCreditCard,
    hasControlledDelivery: hasControlledDelivery,
    hasDoorPickup: hasDoorPickup,
    notes: notes,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pttPlan = _createDummyPlan(
    companyName: 'PTT Kargo',
    code: 'ptt-kargo',
    zeroTwo: 90.0,
    five: 120.0,
    ten: 160.0,
    twenty: 220.0,
    thirty: 280.0,
    additional: 15.0,
    hasPod: true,
    hasPodCreditCard: true,
    hasControlledDelivery: true,
  );

  final yurticiPlan = _createDummyPlan(
    companyName: 'Yurtici Kargo',
    code: 'yurtici-kargo',
    zeroTwo: 130.0,
    five: 170.0,
    ten: 230.0,
    twenty: 320.0,
    thirty: 400.0,
    additional: 20.0,
    hasPod: true,
    hasPodCreditCard: false,
    hasControlledDelivery: false,
  );

  final suratPlan = _createDummyPlan(
    companyName: 'Surat Kargo',
    code: 'surat-kargo',
    zeroTwo: 105.0,
    five: 140.0,
    ten: 190.0,
    twenty: 260.0,
    thirty: 330.0,
    additional: 18.0,
    hasPod: false,
    hasPodCreditCard: false,
    hasControlledDelivery: false,
  );

  final dummyPlans = [pttPlan, yurticiPlan, suratPlan];

  group('PricingPlan Model Ayrıştırma Testleri', () {
    test('PricingPlan.fromBackend boolean ve KDV hesaplamasını doğru ayrıştırır', () {
      final backendItem = {
        'id': 'plan-123',
        'name': 'PTT Anlaşmalı Tarife',
        'cargo_company_id': 'ptt-kargo',
        'cargo_company': {
          'title': 'PTT Kargo',
          'can_pod': 1, // num olarak dönen boolean
          'can_pod_credit_card': 'true', // string olarak dönen boolean
          'can_controlled_delivery': false,
          'customer_note': 'Kapıdan ücretsiz kurye alımı mevcuttur.',
        },
      };

      final backendDetail = {
        'prices': [
          {'desi_threshold': 0, 'amount': 100.0},
          {'desi_threshold': 5, 'amount': 150.0},
          {'desi_threshold': 10, 'amount': 200.0},
          {'desi_threshold': 20, 'amount': 300.0},
          {'desi_threshold': 30, 'amount': 400.0},
        ],
        'fees': [
          {'type': 201, 'value': 20.0},
          {'type': 202, 'value': '60'},
        ],
      };

      final plan = PricingPlan.fromBackend(backendItem, backendDetail);

      expect(plan.companyName, 'PTT Kargo');
      expect(plan.hasPod, isTrue);
      expect(plan.hasPodCreditCard, isTrue);
      // PTT olduğu için kod/isim eşleşmesinden kontrollü teslimat true olmalı
      expect(plan.hasControlledDelivery, isTrue);
      expect(plan.hasDoorPickup, isTrue);
      // %20 KDV dahil kontrolü
      expect(plan.zeroTwoDesi, closeTo(120.0, 0.01));
      expect(plan.fiveDesi, closeTo(180.0, 0.01));
      expect(plan.additionalDesi, closeTo(24.0, 0.01));
      expect(plan.returnRate, '%60');
    });
  });

  group('LivePriceCalculator Widget Testleri', () {
    testWidgets('Canlı hesaplama başlığı, desi girişi, slider ve EN UYGUN FİYAT rozetini render eder', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivePriceCalculator(plans: dummyPlans),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık
      expect(find.text('CANLI FİYAT HESAPLA'), findsOneWidget);
      expect(find.text('KDV DAHİL'), findsOneWidget);

      // Desi Input varsayılan 2
      expect(find.text('2'), findsOneWidget);

      // En ucuz firma PTT Kargo (90 TL) olmalı ve EN UYGUN FİYAT rozeti taşımalı
      expect(find.text('EN UYGUN FİYAT'), findsOneWidget);
      // Asla EN HIZLI rozeti olmamalı
      expect(find.text('EN HIZLI'), findsNothing);

      // PTT Kargo, Sürat Kargo ve Yurtiçi Kargo sıralı render edilmiş olmalı
      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text('Surat Kargo'), findsOneWidget);
      expect(find.text('Yurtici Kargo'), findsOneWidget);
    });

    testWidgets('Kapıda Ödeme ve Kontrollü Teslimat filtreleri doğru sonuç verir', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivePriceCalculator(plans: dummyPlans),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Kapıda Ödeme filtresine tıkla (Sürat Kargo elenmeli)
      await tester.tap(find.text('Kapıda Ödeme'));
      await tester.pumpAndSettle();

      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text('Yurtici Kargo'), findsOneWidget);
      expect(find.text('Surat Kargo'), findsNothing);

      // Kontrollü Teslimat filtresine de tıkla (Yalnızca PTT Kargo kalmalı)
      await tester.tap(find.text('Kontrollü Teslimat'));
      await tester.pumpAndSettle();

      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text('Yurtici Kargo'), findsNothing);
      expect(find.text('Surat Kargo'), findsNothing);
    });

    testWidgets('Desi değiştiğinde fiyatlar dinamik hesaplanır', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivePriceCalculator(plans: dummyPlans),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Desi alanını temizleyip '35' yazalım (30 desi üzeri ek desi hesaplaması)
      final desiFinder = find.byType(TextField);
      await tester.enterText(desiFinder, '35');
      await tester.pumpAndSettle();

      // PTT: 30 desi (280) + 5 * 15 = 355 TL
      final expectedPtt = AppFormatters.formatCurrency(355.0);
      expect(find.text(expectedPtt), findsOneWidget);
    });
  });

  group('PricingPlanCard Widget Testleri', () {
    testWidgets('Plan detaylarını, desi kademelerini, ekstra ücretler satırını ve açılır POD tablosunu render eder', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PricingPlanCard(plan: pttPlan),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Başlık ve Rozetler
      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text('AKTİF TARİFE'), findsOneWidget);
      expect(find.text('Adresten Alım'), findsOneWidget);
      expect(find.text('Kapıda Ödeme (Nakit + Kart)'), findsOneWidget);
      expect(find.text('Kontrollü Teslimat'), findsOneWidget);

      // Ekstra Ücretler Satırı
      expect(find.text('İADE BEDELİ'), findsOneWidget);
      expect(find.text('%50'), findsOneWidget);
      expect(find.text('ARTAN DESİ (+1)'), findsOneWidget);
      expect(find.text(AppFormatters.formatCurrency(15.0)), findsOneWidget);

      // Kapıda Ödeme Nakit Komisyon Tablosu akordiyonuna tıkla
      final accordionFinder = find.text('Kapıda Ödeme Nakit Komisyon Tablosu');
      expect(accordionFinder, findsOneWidget);

      await tester.tap(accordionFinder);
      await tester.pumpAndSettle();

      // Komisyon tablosu satırları açılmış olmalı
      expect(find.text('Tahsilat Tutarı'), findsOneWidget);
      expect(find.text('Kesinti Oranı'), findsOneWidget);
      expect(find.text('0 - 1.000 ₺'), findsOneWidget);
      // Hem ARTAN DESİ (+1) hem de 0-1.000 TL komisyonu 15,00 ₺ olarak render edilmiştir
      expect(find.text('15,00 ₺'), findsNWidgets(2));
      expect(find.text('1.001 - 5.000 ₺'), findsOneWidget);
      expect(find.text('%1,50'), findsOneWidget);
    });
  });

  group('PricingScreen Genel Entegrasyon Testleri', () {
    testWidgets('API AKTİF rozeti ve tarife listesi başarıyla render edilir', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(
              const AuthState(isInitialized: true, token: 'fake-token'),
            ),
          ),
          pricingProvider.overrideWith(
            () => _TestPricingNotifier(
              PricingState(isLoading: false, plans: dummyPlans),
            ),
          ),
          productsProvider.overrideWith(
            () => _TestProductsNotifier(
              const ProductsState(isLoading: false, products: []),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PricingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // AppBar'da API AKTİF rozeti bulunmalı
      expect(find.text('API AKTİF'), findsOneWidget);

      // Firma Detay Tarifeleri Başlığı ve Sayaç
      expect(find.text('FİRMA DETAY TARİFELERİ'), findsOneWidget);
      expect(find.text('3 ANLAŞMA'), findsOneWidget);

      // Canlı Hesaplayıcı ve Plan Kartları
      expect(find.byType(LivePriceCalculator), findsOneWidget);
      expect(find.byType(PricingPlanCard), findsWidgets);
    });
  });
}
