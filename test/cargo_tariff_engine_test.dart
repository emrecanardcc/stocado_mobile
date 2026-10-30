import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocado_mobile/core/utils/app_formatters.dart';
import 'package:stocado_mobile/features/cargo/models/cargo_offer_model.dart';
import 'package:stocado_mobile/features/pricing/models/cargo_tariff_engine.dart';
import 'package:stocado_mobile/features/pricing/widgets/live_price_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CargoTariffEngine Resmi Fiyat Listesi (kargo.txt) Birebir Testleri', () {
    test('HepsiJET Standart Kademe ve Artan Desi Fiyatları', () {
      // 0-4 desi: 116.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 0), 116.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 1), 116.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 4), 116.00);
      // 5-10 desi: 190.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 5), 190.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 10), 190.00);
      // 11-20 desi: 253.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 11), 253.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 20), 253.00);
      // 21-30 desi: 370.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 21), 370.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 30), 370.00);
      // 31-40 desi: 441.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 31), 441.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 40), 441.00);
      // 40+ desi: +1 desi: 25.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 45), 441.00 + 5 * 25.00);
    });

    test('HepsiJET Alıcı Ödemeli Kademe Fiyatları', () {
      // 0-4 desi: 167.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 0, isReceiverPays: true), 167.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 4, isReceiverPays: true), 167.00);
      // 5-10 desi: 257.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 5, isReceiverPays: true), 257.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 10, isReceiverPays: true), 257.00);
      // 11-20 desi: 340.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 11, isReceiverPays: true), 340.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 20, isReceiverPays: true), 340.00);
      // 21 desi: 465.00 ₺, 22-30 desi: 525.00 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 21, isReceiverPays: true), 465.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 22, isReceiverPays: true), 525.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'hepsijet', desi: 30, isReceiverPays: true), 525.00);
    });

    test('PTT Kargo Standart Kademe ve Artan Desi Fiyatları', () {
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 0), 104.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 1), 107.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 2), 124.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 3), 142.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 4), 167.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 5), 179.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 10), 240.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 20), 420.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 30), 613.00);
      // 30+ desi: +25.79 ₺
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ptt-kargo', desi: 35), closeTo(613.00 + 5 * 25.79, 0.01));
    });

    test('Sürat Kargo Standart ve Alıcı Ödemeli Fiyatları', () {
      // Standart
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 0), 117.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 2), 117.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 3), 131.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 10), 206.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 20), 290.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 30), 462.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 35), closeTo(462.00 + 5 * 23.34, 0.01));

      // Alıcı Ödemeli
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 0, isReceiverPays: true), 202.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 3, isReceiverPays: true), 202.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 5, isReceiverPays: true), 238.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 10, isReceiverPays: true), 259.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 20, isReceiverPays: true), 364.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'surat-kargo', desi: 30, isReceiverPays: true), 515.00);
    });

    test('Kolay Gelsin Standart Fiyatları ve Kapıda Ödeme Olmaması', () {
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 0), 132.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 2), 132.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 5), 137.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 10), 151.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 20), 246.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 30), 366.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'kolay-gelsin', desi: 35), closeTo(366.00 + 5 * 23.34, 0.01));

      expect(CargoTariffEngine.isPodSupported('kolay-gelsin'), isFalse);
      expect(CargoTariffEngine.isControlledDeliverySupported('kolay-gelsin'), isFalse);
    });

    test('Yurtiçi Kargo Standart Fiyatları', () {
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 0), 229.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 1), 234.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 2), 239.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 10), 396.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 20), 708.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 30), 984.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'yurtici-kargo', desi: 35), closeTo(984.00 + 5 * 39.30, 0.01));
    });

    test('UPS Kargo Standart ve Alıcı Ödemeli Fiyatları (70 Desiye kadar)', () {
      // Standart
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 0), 196.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 5), 196.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 10), 241.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 30), 359.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 70), 836.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 75), closeTo(836.00 + 5 * 28.66, 0.01));

      // Alıcı Ödemeli
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 0, isReceiverPays: true), 426.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 5, isReceiverPays: true), 426.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 10, isReceiverPays: true), 486.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 30, isReceiverPays: true), 695.00);
      expect(CargoTariffEngine.calculateBasePrice(companyCode: 'ups', desi: 70, isReceiverPays: true), 825.00);
    });

    test('Kapıda Ödeme Nakit ve Kredi Kartı Kesintileri', () {
      // HepsiJET: Yalnızca Nakit
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 400), 60.06);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 800), 79.20);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 1500), 113.84);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 2500), 145.20);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 3500), 207.60);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 4500), 246.00);
      expect(CargoTariffEngine.calculatePodFee('hepsijet', 6000), 406.80);
      expect(CargoTariffEngine.isPodSupported('hepsijet', isCreditCard: true), isFalse);

      // PTT: Yalnızca Nakit
      expect(CargoTariffEngine.calculatePodFee('ptt-kargo', 400), 12.00);
      expect(CargoTariffEngine.calculatePodFee('ptt-kargo', 800), 14.40);
      expect(CargoTariffEngine.calculatePodFee('ptt-kargo', 1500), 18.00);
      expect(CargoTariffEngine.calculatePodFee('ptt-kargo', 2500), 30.00);
      expect(CargoTariffEngine.isPodSupported('ptt-kargo', isCreditCard: true), isFalse);

      // Sürat Kargo: Nakit ve Kart
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 400), 52.20);
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 800), 61.86);
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 1500), 93.49);
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 2500), 116.88);
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 3500), 144.54);
      expect(CargoTariffEngine.calculatePodFee('surat-kargo', 5000), closeTo(5000 * 0.036, 0.01));
      // Kredi Kartı: nakitKesintisi + erken ödeme (%5.40)
      final suratCcFee = CargoTariffEngine.calculatePodFee('surat-kargo', 1000, isCreditCard: true);
      expect(suratCcFee, closeTo(61.86 + 1000 * 0.054, 0.01));

      // UPS: Nakit ve Kart
      expect(CargoTariffEngine.calculatePodFee('ups', 400), 47.40);
      expect(CargoTariffEngine.calculatePodFee('ups', 800), 58.20);
      expect(CargoTariffEngine.calculatePodFee('ups', 1500), 81.26);
      expect(CargoTariffEngine.calculatePodFee('ups', 2500), 108.74);
      expect(CargoTariffEngine.calculatePodFee('ups', 3500), 131.28);
      expect(CargoTariffEngine.calculatePodFee('ups', 4500), 147.00);
      expect(CargoTariffEngine.calculatePodFee('ups', 6000), closeTo(6000 * 0.0474, 0.01));
      // Kredi Kartı: nakitKesintisi + erken ödeme (%5.96)
      final upsCcFee = CargoTariffEngine.calculatePodFee('ups', 1000, isCreditCard: true);
      expect(upsCcFee, closeTo(58.20 + 1000 * 0.0596, 0.01));
    });

    test('Kontrollü Teslimat Ücretleri', () {
      expect(CargoTariffEngine.getControlledDeliveryFee('ptt-kargo'), 49.99);
      expect(CargoTariffEngine.getControlledDeliveryFee('ups'), 60.84);
      expect(CargoTariffEngine.getControlledDeliveryFee('hepsijet'), 0.0);
      expect(CargoTariffEngine.getControlledDeliveryFee('surat-kargo'), 0.0);
    });
  });

  group('OpenAPI Schema Parite ve Serializasyon Testleri', () {
    test('CargoCalculateRequest default toJson() OpenAPI string enum standardını üretir', () {
      final req = CargoCalculateRequest(
        accountId: 456,
        localId: '10',
        foreignId: '25',
        package: PackageData(desi: 0.0, length: 0, width: 0, height: 0, weight: 0),
        payOnDelivery: true,
        payOnDeliveryAmount: 150.0,
        payOnDeliveryType: 'cash',
        direction: 'send',
      );

      final json = req.toJson();
      expect(json['direction'], 'send');
      expect(json['pay_on_delivery_type'], 'cash');
      expect(json['account_id'], 456);
      expect(json['local_id'], 10);
      expect(json['foreign_id'], 25);
      expect(json['package']['desi'], 0.0);
    });

    test('CargoCalculateRequest direction receive ve credit_card doğru serialize edilir', () {
      final req = CargoCalculateRequest(
        accountId: '123',
        package: PackageData(desi: 5.5),
        payOnDelivery: true,
        payOnDeliveryAmount: 500.0,
        payOnDeliveryType: 'credit_card',
        direction: 'receive',
      );

      final json = req.toJson();
      expect(json['direction'], 'receive');
      expect(json['pay_on_delivery_type'], 'credit_card');
      expect(json['account_id'], 123);
    });

    test('CargoCalculateRequest pay_on_delivery: false iken pay_on_delivery_amount 0 olarak serialize edilir', () {
      final req = CargoCalculateRequest(
        accountId: 456,
        package: PackageData(desi: 1.0),
        payOnDelivery: false,
      );

      final json = req.toJson();
      expect(json['pay_on_delivery'], isFalse);
      expect(json['pay_on_delivery_amount'], 0);
      expect(json['controlled_delivery'], isFalse);
    });

    test('CargoOffer.fromJson hem nested cargo_company hem de duz propertyleri cozer', () {
      // 1. Nested schema (OpenAPI)
      final offer1 = CargoOffer.fromJson({
        'cargo_company': {'id': 'ptt-kargo', 'title': 'PTT Kargo', 'logo': 'ptt.png'},
        'price': 104.0,
      });
      expect(offer1.cargoCompany.id, 'ptt-kargo');
      expect(offer1.cargoCompany.title, 'PTT Kargo');
      expect(offer1.price, 104.0);

      // 2. Total ve düz company_title alternatifi
      final offer2 = CargoOffer.fromJson({
        'company_id': 'ups',
        'company_title': 'UPS Kargo',
        'total': '196.00',
      });
      expect(offer2.cargoCompany.id, 'ups');
      expect(offer2.cargoCompany.title, 'UPS Kargo');
      expect(offer2.price, 196.00);
    });
  });

  group('LivePriceCalculator 0 Desi ve Ek Ücret Hesaplama Testleri', () {
    final officialPlans = CargoTariffEngine.getOfficialPricingPlans();

    testWidgets('LivePriceCalculator 0 Desi (Evrak) değerinde PTT için 104 TL taban fiyatını doğru hesaplar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivePriceCalculator(plans: officialPlans),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Desi inputuna '0' yazalım
      final desiFinder = find.byType(TextField);
      await tester.enterText(desiFinder, '0');
      await tester.pumpAndSettle();

      // PTT Kargo 0 desi = 104,00 ₺ (en ucuz firma)
      expect(find.text(AppFormatters.formatCurrency(104.0)), findsOneWidget);
      // HepsiJET 0 desi = 116,00 ₺
      expect(find.text(AppFormatters.formatCurrency(116.0)), findsOneWidget);
      // Sürat Kargo 0 desi = 117,00 ₺
      expect(find.text(AppFormatters.formatCurrency(117.0)), findsOneWidget);
    });

    testWidgets('LivePriceCalculator Kapıda Ödeme ve Kontrollü Teslimat seçildiğinde komisyonları ekler', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivePriceCalculator(plans: officialPlans),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Varsayılan desi 2
      // Kontrollü Teslimat tıkla (kargo.txt: PTT 124.00 + 49.99 = 173.99 ₺, UPS 196.00 + 60.84 = 256.84 ₺)
      await tester.tap(find.text('Kontrollü Teslimat'));
      await tester.pumpAndSettle();

      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text(AppFormatters.formatCurrency(173.99)), findsOneWidget);
      expect(find.text('UPS Kargo'), findsOneWidget);
      expect(find.text(AppFormatters.formatCurrency(256.84)), findsOneWidget);

      // Kapıda Ödeme de ekle: PTT (173.99 + 12.00 = 185.99 ₺), UPS (256.84 + 47.40 = 304.24 ₺)
      await tester.tap(find.text('Kapıda Ödeme'));
      await tester.pumpAndSettle();

      expect(find.text('PTT Kargo'), findsOneWidget);
      expect(find.text(AppFormatters.formatCurrency(185.99)), findsOneWidget);
      expect(find.text('UPS Kargo'), findsOneWidget);
      expect(find.text(AppFormatters.formatCurrency(304.24)), findsOneWidget);
    });
  });

  group('PricingPlan.calculatePrice Parite ve Kısıtlama Testleri', () {
    final officialPlans = CargoTariffEngine.getOfficialPricingPlans();
    final hepsiPlan = officialPlans.firstWhere((p) => p.code == 'hepsijet');
    final pttPlan = officialPlans.firstWhere((p) => p.code == 'ptt-kargo');
    final suratPlan = officialPlans.firstWhere((p) => p.code == 'surat-kargo');
    final kolayPlan = officialPlans.firstWhere((p) => p.code == 'kolay-gelsin');
    final upsPlan = officialPlans.firstWhere((p) => p.code == 'ups');

    test('isReceiverPays: true olduğunda resmi Alıcı Ödemeli tarifesi uygulanır', () {
      // HepsiJET: Standart 116 ₺, Alıcı Ödemeli 167 ₺
      expect(hepsiPlan.calculatePrice(1, isReceiverPays: false), 116.00);
      expect(hepsiPlan.calculatePrice(1, isReceiverPays: true), 167.00);
      expect(hepsiPlan.calculatePrice(21, isReceiverPays: true), 465.00);
      expect(hepsiPlan.calculatePrice(22, isReceiverPays: true), 525.00);

      // Sürat Kargo: Standart 117 ₺, Alıcı Ödemeli 202 ₺
      expect(suratPlan.calculatePrice(1, isReceiverPays: false), 117.00);
      expect(suratPlan.calculatePrice(1, isReceiverPays: true), 202.00);
      expect(suratPlan.calculatePrice(4, isReceiverPays: true), 238.00);

      // UPS Kargo: Standart 196 ₺, Alıcı Ödemeli 426 ₺
      expect(upsPlan.calculatePrice(1, isReceiverPays: false), 196.00);
      expect(upsPlan.calculatePrice(1, isReceiverPays: true), 426.00);
      expect(upsPlan.calculatePrice(41, isReceiverPays: true), 1014.00);
      expect(upsPlan.calculatePrice(45, isReceiverPays: true), 1161.00);
    });

    test('Desteklenmeyen ek hizmetler istendiğinde 0.0 döner', () {
      // HepsiJET Kontrollü Teslimat desteklemez
      expect(hepsiPlan.calculatePrice(2, isControlled: true), 0.0);
      // Kolay Gelsin Kapıda Ödeme desteklemez
      expect(kolayPlan.calculatePrice(2, isPod: true), 0.0);
      // PTT Kredi Kartı ile Kapıda Ödeme desteklemez (yalnızca nakit)
      expect(pttPlan.calculatePrice(2, isPod: true, podType: 'credit_card'), 0.0);
      expect(pttPlan.calculatePrice(2, isPod: true, podType: 'cash'), 124.00 + 12.00);

      // UPS hem Kontrollü Teslimat hem de Kredi Kartı POD destekler
      final upsTotal = upsPlan.calculatePrice(
        2,
        isPod: true,
        podType: 'credit_card',
        podAmount: 500,
        isControlled: true,
      );
      // 196 (base) + 47.40 (nakit POD) + 29.80 (%5.96 erken ödeme) + 60.84 (kontrollü) = 334.04
      expect(upsTotal, closeTo(196.00 + 47.40 + 29.80 + 60.84, 0.01));
    });
  });

  group('CreateCargoProvider Fallback Teklifleri Testleri', () {
    test('generateFallbackOffers resmi tarifelere tam uyar ve fiyata göre sıralanır', () {
      // 2 Desi Standart
      final offers = CargoTariffEngine.generateFallbackOffers(desi: 2.0);
      expect(offers.length, 6);
      // En ucuz firma HepsiJET (116 ₺) olmalı
      expect(offers.first.cargoCompany.title, 'HepsiJET');
      expect(offers.first.price, 116.00);

      // 0 Desi Standart
      final zeroOffers = CargoTariffEngine.generateFallbackOffers(desi: 0.0);
      // 0 Deside en ucuz firma PTT Kargo (104 ₺) olmalıdır
      expect(zeroOffers.first.cargoCompany.title, 'PTT Kargo');
      expect(zeroOffers.first.price, 104.00);

      // Kredi Kartı Kapıda Ödeme: Sadece Sürat ve UPS
      final ccOffers = CargoTariffEngine.generateFallbackOffers(
        desi: 2.0,
        isPod: true,
        podAmount: 500.0,
        podType: 'credit_card',
      );
      expect(ccOffers.length, 2);
      expect(ccOffers.map((o) => o.cargoCompany.id).toList(), containsAll(['surat-kargo', 'ups']));

      // Kontrollü Teslimat: PTT Kargo ve UPS Kargo (kargo.txt)
      final controlledOffers = CargoTariffEngine.generateFallbackOffers(
        desi: 2.0,
        isControlled: true,
      );
      expect(controlledOffers.length, 2);
      expect(controlledOffers[0].cargoCompany.id, 'ptt-kargo');
      expect(controlledOffers[0].price, 124.00 + 49.99);
      expect(controlledOffers[1].cargoCompany.id, 'ups');
      expect(controlledOffers[1].price, 196.00 + 60.84);

      // Kontrollü Teslimat + Kredi Kartı Kapıda Ödeme: Yalnızca UPS destekler
      final controlledCcOffers = CargoTariffEngine.generateFallbackOffers(
        desi: 2.0,
        isControlled: true,
        isPod: true,
        podAmount: 500.0,
        podType: 'credit_card',
      );
      expect(controlledCcOffers.length, 1);
      expect(controlledCcOffers.first.cargoCompany.id, 'ups');
      expect(controlledCcOffers.first.price, closeTo(196.00 + 47.40 + 29.80 + 60.84, 0.01));
    });
  });
}
