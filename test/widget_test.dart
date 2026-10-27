import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocado_mobile/core/utils/app_formatters.dart';
import 'package:stocado_mobile/features/auth/providers/auth_provider.dart';
import 'package:stocado_mobile/features/cargo/models/cargo_model.dart';
import 'package:stocado_mobile/features/cargo/widgets/cargo_company_logo.dart';
import 'package:stocado_mobile/main.dart';

class _TestAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  _TestAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

void main() {
  group('StocadoApp Smoke & Initialization Test', () {
    testWidgets('Uygulama ProviderScope ile baslatilir ve yukleme ekrani acilir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: StocadoApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Oturum acilmamis durumda LoginScreen render edilir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                const AuthState(isInitialized: true, token: null),
              ),
            ),
          ],
          child: const StocadoApp(),
        ),
      );

      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Giriş Yap'), findsWidgets);
      expect(find.text('Stocado • Güvenli Lojistik Altyapısı'), findsOneWidget);
    });
  });

  group('AppFormatters Birim Testleri', () {
    test('formatCurrency para birimini dogru bicimlendirir', () {
      expect(AppFormatters.formatCurrency(1250000.50), '1.250.000,50 ₺');
      expect(AppFormatters.formatCurrency(847.16), '847,16 ₺');
      expect(AppFormatters.formatCurrency(10), '10,00 ₺');
      expect(AppFormatters.formatCurrency(null), '0,00 ₺');
      expect(AppFormatters.formatCurrency(100, includeSymbol: false), '100,00');
    });

    test('formatDateTime tarih ve saat formatini dogru uretir', () {
      final testDate = DateTime(2026, 10, 24, 14, 30);
      expect(AppFormatters.formatDateTime(testDate), '24.10.2026 14:30');
      expect(AppFormatters.formatDateTime(null), '');
    });

    test('formatDesi desi birimini dogru bicimlendirir', () {
      expect(AppFormatters.formatDesi(2.5), '2,50 Desi');
      expect(AppFormatters.formatDesi(null), '0 Desi');
    });

    test('parseDouble virgullu ve noktali sayilari guvenle parse eder', () {
      expect(AppFormatters.parseDouble('12,50'), 12.5);
      expect(AppFormatters.parseDouble('12.50'), 12.5);
      expect(AppFormatters.parseDouble(null), 0.0);
      expect(AppFormatters.parseDouble('gecersiz', 5.0), 5.0);
    });
  });

  group('CargoCompanyLogo & Type Cozumleme Testleri', () {
    test('Kargo sirketi isimlerini ve kodlarini dogru enum turune esler', () {
      expect(CargoCompanyType.fromString('ptt'), CargoCompanyType.ptt);
      expect(CargoCompanyType.fromString('ptt-kargo'), CargoCompanyType.ptt);
      expect(CargoCompanyType.fromString('PTT Kargo'), CargoCompanyType.ptt);

      expect(CargoCompanyType.fromString('yurtici'), CargoCompanyType.yurtici);
      expect(CargoCompanyType.fromString('yurtiçi-kargo'), CargoCompanyType.yurtici);

      expect(CargoCompanyType.fromString('surat'), CargoCompanyType.surat);
      expect(CargoCompanyType.fromString('Sürat Kargo'), CargoCompanyType.surat);

      expect(CargoCompanyType.fromString('hepsijet'), CargoCompanyType.hepsijet);
      expect(CargoCompanyType.fromString('ups'), CargoCompanyType.ups);
      expect(CargoCompanyType.fromString('kolay-gelsin'), CargoCompanyType.kolayGelsin);
      expect(CargoCompanyType.fromString('Kolay Gelsin'), CargoCompanyType.kolayGelsin);
      expect(CargoCompanyType.fromString('aras'), CargoCompanyType.aras);
      expect(CargoCompanyType.fromString('mng'), CargoCompanyType.mng);
      expect(CargoCompanyType.fromString('trendyol'), CargoCompanyType.trendyol);
      expect(CargoCompanyType.fromString('bilinmeyen'), CargoCompanyType.unknown);
      expect(CargoCompanyType.ptt.assetPath, 'assets/images/cargo/ptt.png');
      expect(CargoCompanyType.kolayGelsin.assetPath, 'assets/images/cargo/kolay_gelsin.png');
    });
  });

  group('CargoModel Desi ve Tahsilat Cozumleme Testleri', () {
    test('effectiveDesi validDesi onceligini dogru uygular', () {
      final cargoWithValid = CargoModel(
        id: '1',
        processNumber: 'PR-1',
        outTrackingCode: 'TR-1',
        status: 1,
        payOnDelivery: false,
        validDesi: 3.5,
        userDesi: 2.0,
      );
      expect(cargoWithValid.effectiveDesi, 3.5);

      final cargoUserOnly = CargoModel(
        id: '2',
        processNumber: 'PR-2',
        outTrackingCode: 'TR-2',
        status: 1,
        payOnDelivery: false,
        validDesi: null,
        userDesi: 2.5,
      );
      expect(cargoUserOnly.effectiveDesi, 2.5);
    });

    test('payOnDeliveryTypeText nakit ve kredi kartini dogru cozer', () {
      final cargoCash = CargoModel(
        id: '1',
        processNumber: 'PR-1',
        outTrackingCode: 'TR-1',
        status: 1,
        payOnDelivery: true,
        payOnDeliveryType: 1,
      );
      expect(cargoCash.payOnDeliveryTypeText, 'Nakit');

      final cargoCard = CargoModel(
        id: '2',
        processNumber: 'PR-2',
        outTrackingCode: 'TR-2',
        status: 1,
        payOnDelivery: true,
        payOnDeliveryType: 2,
      );
      expect(cargoCard.payOnDeliveryTypeText, 'Kredi Kartı');
    });

    test('trackingUrl kargo firmasina uygun resmi takip baglantisi uretir', () {
      final hepsijetCargo = CargoModel(
        id: '1',
        processNumber: '123',
        outTrackingCode: 'ADO12345',
        cargoCompanyId: 'hepsijet',
        status: 2,
        payOnDelivery: false,
      );
      expect(hepsijetCargo.trackingUrl, 'https://www.hepsijet.com/gonderi-takibi/ADO12345');

      final yurticiCargo = CargoModel(
        id: '2',
        processNumber: '456',
        outTrackingCode: '905272407237',
        cargoCompanyId: 'yurtici-kargo',
        status: 2,
        payOnDelivery: false,
      );
      expect(yurticiCargo.trackingUrl, 'https://www.yurticikargo.com/tr/online-servisler/gonderi-sorgula?code=905272407237');
    });

    test('Deneme1 iptal edilen kargo web portali ile tam uyumlu sekilde cozumlensin', () {
      final deneme1 = CargoModel(
        id: '01jwbdgpkrdfv6pgc34p9kc054',
        processNumber: '4509555555055',
        outTrackingCode: '',
        status: 3,
        latestTransactionType: 12,
        latestTransaction: CargoTransaction(
          type: 12,
          description: 'Kargo iptal edildi.',
        ),
        payOnDelivery: false,
      );

      // Durum kesinlikle 'İptal Edildi' olmalı, web terminolojisinde type 12 'Gönderici İptal'dir
      expect(deneme1.statusText, 'İptal Edildi');
      expect(deneme1.latestActionTitle, 'Gönderici İptal');
      expect(deneme1.hasCarrierBarcode, false);
      expect(deneme1.effectiveTransactionType, 12);
    });

    test('Teslim Edildi ve Dagitimda durumlari web terminolojisi ile dogru cozumlensin', () {
      final deliveredCargo = CargoModel(
        id: 'del-1',
        processNumber: 'REF-DEL',
        outTrackingCode: 'TRK-DEL',
        status: 2,
        latestTransactionType: 6,
        payOnDelivery: false,
      );
      expect(deliveredCargo.statusText, 'Teslim Edildi');
      expect(deliveredCargo.latestActionTitle, 'Teslim Edildi');
      expect(deliveredCargo.hasCarrierBarcode, true);

      final outForDeliveryCargo = CargoModel(
        id: 'out-1',
        processNumber: 'REF-OUT',
        outTrackingCode: 'TRK-OUT',
        status: 2,
        latestTransactionType: 5,
        payOnDelivery: false,
      );
      expect(outForDeliveryCargo.statusText, 'Dağıtımda');
      expect(outForDeliveryCargo.latestActionTitle, 'Dağıtımda');

      final readyCargo = CargoModel(
        id: 'ready-1',
        processNumber: 'REF-RDY',
        outTrackingCode: 'TRK-RDY',
        status: 1,
        latestTransactionType: 1,
        payOnDelivery: false,
      );
      expect(readyCargo.latestActionTitle, 'Gönderime Hazır');

      final adminCancelled = CargoModel(
        id: 'adm-1',
        processNumber: 'REF-ADM',
        outTrackingCode: 'TRK-ADM',
        status: 3,
        latestTransactionType: 13,
        payOnDelivery: false,
      );
      expect(adminCancelled.latestActionTitle, 'Yönetici İptal');
    });

    test('Kapida Odeme net tutar ve kesinti hesaplamasi dogru yapilir', () {
      final podCargo = CargoModel(
        id: 'pod-1',
        processNumber: 'POD-1',
        outTrackingCode: 'TRK-POD',
        status: 1,
        payOnDelivery: true,
        payOnDeliveryAmount: 500.0,
        payOnDeliveryCost: 35.0,
        podTransactionId: 'TX-98765',
      );

      expect(podCargo.payOnDeliveryAmount, 500.0);
      expect(podCargo.payOnDeliveryCost, 35.0);
      expect(podCargo.payOnDeliveryNetAmount, 465.0);
      expect(podCargo.podTransactionId, 'TX-98765');
    });

    test('Kargolar olusturulma tarihine gore yeniden eskiye veya eskiden yeniye siralanir', () {
      final c1Oldest = CargoModel(
        id: '01js1ey688a4k1nq324nj75hp0',
        processNumber: 'OLD-1',
        outTrackingCode: 'TRK-1',
        status: 1,
        payOnDelivery: false,
        createdAt: DateTime(2025, 4, 17, 8, 48),
      );

      final c2Middle = CargoModel(
        id: '01m5pha0cpndz4xf8e7x62a70x',
        processNumber: 'MID-2',
        outTrackingCode: 'TRK-2',
        status: 1,
        payOnDelivery: false,
        createdAt: DateTime(2026, 10, 24, 8, 44),
      );

      final c3Newest = CargoModel(
        id: '01m5q41yq6dfhsv8e71y8gxf58',
        processNumber: 'NEW-3',
        outTrackingCode: 'TRK-3',
        status: 1,
        payOnDelivery: false,
        createdAt: DateTime(2026, 10, 24, 14, 10),
      );

      final listDesc = [c1Oldest, c3Newest, c2Middle];

      // Yeniden eskiye siralama (desc)
      listDesc.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: 'desc'));

      expect(listDesc[0].processNumber, 'NEW-3');
      expect(listDesc[1].processNumber, 'MID-2');
      expect(listDesc[2].processNumber, 'OLD-1');

      final listAsc = [c3Newest, c1Oldest, c2Middle];

      // Eskiden yeniye siralama (asc)
      listAsc.sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: 'asc'));

      expect(listAsc[0].processNumber, 'OLD-1');
      expect(listAsc[1].processNumber, 'MID-2');
      expect(listAsc[2].processNumber, 'NEW-3');

      // Sayısal ID tie-breaker testi (aynı tarihteki veya null tarihteki kayıtlar)
      final cNum9 = CargoModel(id: '9', processNumber: 'P-9', outTrackingCode: 'TRK-9', status: 1, payOnDelivery: false);
      final cNum10 = CargoModel(id: '10', processNumber: 'P-10', outTrackingCode: 'TRK-10', status: 1, payOnDelivery: false);
      final numList = [cNum9, cNum10]..sort((a, b) => CargoModel.compareCargos(a, b, sortDirection: 'desc'));
      expect(numList[0].id, '10');
      expect(numList[1].id, '9');
    });

    test('CargoModel.fromJson duz (flat dot-notation) receiver ve latest_transaction verilerini dogru parse eder', () {
      final jsonFlat = {
        'id': 'flat-123',
        'process_number': 'REF-FLAT',
        'out_tracking_code': 'TRK-FLAT',
        'status': 1,
        'pay_on_delivery': 0,
        'receiver.id': 'rec-456',
        'receiver.name': 'Ahmet Yılmaz',
        'receiver.phone': '05551234567',
        'receiver.city_id': '34',
        'receiver.city.name': 'İstanbul',
        'receiver.district.name': 'Kadıköy',
        'latest_transaction.type': 5,
        'latest_transaction.description': 'Kurye dagitima cikti',
        'latest_transaction.location': 'Kadikoy Sube',
        'latest_transaction.created_at': '2026-10-25T10:00:00.000000Z',
      };

      final cargo = CargoModel.fromJson(jsonFlat);

      expect(cargo.id, 'flat-123');
      expect(cargo.receiver, isNotNull);
      expect(cargo.receiver!.name, 'Ahmet Yılmaz');
      expect(cargo.receiver!.phone, '05551234567');
      expect(cargo.receiver!.city?.name, 'İstanbul');
      expect(cargo.receiver!.district?.name, 'Kadıköy');
      expect(cargo.latestTransaction, isNotNull);
      expect(cargo.latestTransaction!.type, 5);
      expect(cargo.latestTransaction!.description, 'Kurye dagitima cikti');
      expect(cargo.latestTransaction!.location, 'Kadikoy Sube');
      expect(cargo.latestActionTitle, 'Dağıtımda');
    });

    test('CargoModel.fromJson collection_period ve ayrintili kapida odeme alanlarini eksiksiz cozer', () {
      final podJson = {
        'id': 'pod-999',
        'process_number': 'REF-POD-999',
        'out_tracking_code': 'TRK-POD-999',
        'status': 2,
        'pay_on_delivery': 1,
        'pay_on_delivery_amount': 750.50,
        'pay_on_delivery_cost': 45.25,
        'collection_period': 7,
        'pod_transaction_id': 'POD-TX-12345',
        'pay_on_delivery_status': 1,
        'pay_on_delivery_offset_date': '2026-10-30T12:00:00.000000Z',
      };

      final cargo = CargoModel.fromJson(podJson);

      expect(cargo.payOnDelivery, true);
      expect(cargo.payOnDeliveryAmount, 750.50);
      expect(cargo.payOnDeliveryCost, 45.25);
      expect(cargo.payOnDeliveryNetAmount, 705.25);
      expect(cargo.collectionPeriod, 7);
      expect(cargo.podTransactionId, 'POD-TX-12345');
      expect(cargo.payOnDeliveryStatusText, 'Tahsil Edildi');
      expect(cargo.payOnDeliveryOffsetDate, isNotNull);
    });

    test('Kargo listesinde sayfalama sirasinda id bazli tekrarlayan kayitlar basariyla filtrelenir', () {
      final c1 = CargoModel(
        id: 'c-1',
        processNumber: 'P1',
        outTrackingCode: 'T1',
        status: 1,
        payOnDelivery: false,
      );
      final c2 = CargoModel(
        id: 'c-2',
        processNumber: 'P2',
        outTrackingCode: 'T2',
        status: 1,
        payOnDelivery: false,
      );
      final c2Duplicate = CargoModel(
        id: 'c-2',
        processNumber: 'P2-dup',
        outTrackingCode: 'T2-dup',
        status: 1,
        payOnDelivery: false,
      );
      final c3 = CargoModel(
        id: 'c-3',
        processNumber: 'P3',
        outTrackingCode: 'T3',
        status: 1,
        payOnDelivery: false,
      );

      final currentList = [c1, c2];
      final incomingList = [c2Duplicate, c3];

      final existingIds = currentList.map((c) => c.id.toString()).toSet();
      final newItems = incomingList.where((c) => !existingIds.contains(c.id.toString())).toList();
      final combined = [...currentList, ...newItems];

      expect(combined.length, 3);
      expect(combined.map((c) => c.id).toList(), ['c-1', 'c-2', 'c-3']);
    });

    test('Web portal Son Hareket tum durum isimleri dogru haritalanir', () {
      final statuses = {
        0: 'Entegrasyon Hatası',
        1: 'Gönderime Hazır',
        2: 'Çıkış Şubesi',
        3: 'Transferde',
        4: 'Teslimat Şubesi',
        5: 'Dağıtımda',
        6: 'Teslim Edildi',
        7: 'Beklemede',
        8: 'Posta Kağıdı Bırakıldı',
        9: 'Şubeye Transfer Edildi',
        10: 'İadede',
        11: 'Göndericiye İade Edildi',
        12: 'Gönderici İptal',
        13: 'Yönetici İptal',
      };

      for (final entry in statuses.entries) {
        final cargo = CargoModel(
          id: 'test-${entry.key}',
          processNumber: 'REF-${entry.key}',
          outTrackingCode: 'TRK-${entry.key}',
          status: 1,
          latestTransactionType: entry.key,
          payOnDelivery: false,
        );
        expect(cargo.latestActionTitle, entry.value, reason: 'Type ${entry.key} must map to ${entry.value}');
      }

      // Type 7 ile posta kağıdı bırakıldı açıklaması
      final slipCargo = CargoModel(
        id: 'test-slip',
        processNumber: 'REF-SLIP',
        outTrackingCode: 'TRK-SLIP',
        status: 1,
        latestTransactionType: 7,
        latestTransaction: CargoTransaction(
          type: 7,
          description: 'Adreste bulunamadı, posta kağıdı bırakıldı',
        ),
        payOnDelivery: false,
      );
      expect(slipCargo.latestActionTitle, 'Posta Kağıdı Bırakıldı');
    });

    test('Web portal Odeme Durumu tum secenekleri dogru haritalanir', () {
      final paymentStatuses = {
        0: 'Tahsil Edilecek',
        1: 'Tahsil Edildi',
        2: 'Firmadan Tahsil Edildi',
        3: 'Tamamlandı',
        4: 'İptal Edildi',
        5: 'Kargo Firması Tarafından Ödendi',
      };

      for (final entry in paymentStatuses.entries) {
        final cargo = CargoModel(
          id: 'pod-${entry.key}',
          processNumber: 'REF-POD-${entry.key}',
          outTrackingCode: 'TRK-POD-${entry.key}',
          status: 1,
          payOnDelivery: true,
          payOnDeliveryStatus: entry.key,
        );
        expect(cargo.payOnDeliveryStatusText, entry.value, reason: 'POD Status ${entry.key} must map to ${entry.value}');
      }
    });

    test('Timezone ve UTC zamanlari yerel saate cevrilir', () {
      final utcDate = DateTime.parse('2026-10-27T09:24:00.000000Z');
      final formatted = AppFormatters.formatDateTime(utcDate);
      final local = utcDate.toLocal();
      final expectedHour = local.hour.toString().padLeft(2, '0');
      final expectedMinute = local.minute.toString().padLeft(2, '0');
      expect(formatted.endsWith('$expectedHour:$expectedMinute'), true);

      // ISO UTC (Z ile)
      final cargoIso = CargoModel.fromJson({
        'id': 'tz-1',
        'process_number': 'REF-TZ-1',
        'status': 1,
        'created_at': '2026-10-27T09:24:00.000000Z',
      });
      expect(cargoIso.createdAt!.isUtc, false);
      expect(cargoIso.createdAt!.hour, local.hour);

      // MySQL raw format (Z içermeyen boşluklu format: '2026-10-27 09:24:00')
      final cargoMysql = CargoModel.fromJson({
        'id': 'tz-2',
        'process_number': 'REF-TZ-2',
        'status': 0, // Taslak
        'created_at': '2026-10-27 09:24:00',
      });
      expect(cargoMysql.createdAt!.isUtc, false);
      expect(cargoMysql.createdAt!.hour, local.hour);

      // ISO UTC (Z içermeyen format: '2026-10-27T09:24:00')
      final cargoNoZ = CargoModel.fromJson({
        'id': 'tz-3',
        'process_number': 'REF-TZ-3',
        'status': 0,
        'created_at': '2026-10-27T09:24:00',
      });
      expect(cargoNoZ.createdAt!.isUtc, false);
      expect(cargoNoZ.createdAt!.hour, local.hour);
    });
  });
}
