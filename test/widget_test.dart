import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocado_mobile/core/utils/app_formatters.dart';
import 'package:stocado_mobile/features/auth/models/user_model.dart';
import 'package:stocado_mobile/features/auth/providers/auth_provider.dart';
import 'package:stocado_mobile/features/cargo/models/address_model.dart';
import 'package:stocado_mobile/features/cargo/models/cargo_model.dart';
import 'package:stocado_mobile/features/cargo/widgets/cargo_company_logo.dart';
import 'package:stocado_mobile/features/cargo/widgets/cargo_detail_modal.dart';
import 'package:stocado_mobile/features/cargo/widgets/cargo_card.dart';
import 'package:stocado_mobile/features/cargo/widgets/cargo_status_icon.dart';
import 'package:stocado_mobile/features/cargo/screens/cargos_screen.dart';
import 'package:stocado_mobile/features/cargo/providers/cargo_list_provider.dart';
import 'package:stocado_mobile/features/dashboard/models/dashboard_stats_model.dart';
import 'package:stocado_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:stocado_mobile/features/dashboard/screens/top_up_balance_screen.dart';
import 'package:stocado_mobile/features/dashboard/widgets/dashboard_balance_hero_card.dart';
import 'package:stocado_mobile/features/dashboard/widgets/dashboard_package_status_row.dart';
import 'package:stocado_mobile/features/dashboard/widgets/dashboard_recent_cargos_section.dart';
import 'package:stocado_mobile/features/home/providers/navigation_provider.dart';
import 'package:stocado_mobile/features/home/screens/dashboard_screen.dart';
import 'package:stocado_mobile/features/home/screens/main_screen.dart';
import 'package:stocado_mobile/main.dart';

class _TestAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  _TestAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

class _TestCargoListNotifier extends CargoListNotifier {
  final CargoListState _initialState;
  _TestCargoListNotifier(this._initialState);

  @override
  CargoListState build() => _initialState;
}

class _TestDashboardNotifier extends DashboardNotifier {
  final DashboardState _initialState;
  _TestDashboardNotifier(this._initialState);

  @override
  DashboardState build() => _initialState;
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
      expect(CargoCompanyType.fromString('yk'), CargoCompanyType.yurtici);

      expect(CargoCompanyType.fromString('surat'), CargoCompanyType.surat);
      expect(CargoCompanyType.fromString('Sürat Kargo'), CargoCompanyType.surat);
      expect(CargoCompanyType.fromString('sur'), CargoCompanyType.surat);

      expect(CargoCompanyType.fromString('hepsijet'), CargoCompanyType.hepsijet);
      expect(CargoCompanyType.fromString('hj'), CargoCompanyType.hepsijet);
      expect(CargoCompanyType.fromString('ups'), CargoCompanyType.ups);
      expect(CargoCompanyType.fromString('kolay-gelsin'), CargoCompanyType.kolayGelsin);
      expect(CargoCompanyType.fromString('Kolay Gelsin'), CargoCompanyType.kolayGelsin);
      expect(CargoCompanyType.fromString('kg'), CargoCompanyType.kolayGelsin);
      expect(CargoCompanyType.fromString('aras'), CargoCompanyType.aras);
      expect(CargoCompanyType.fromString('mng'), CargoCompanyType.mng);
      expect(CargoCompanyType.fromString('trendyol'), CargoCompanyType.trendyol);
      expect(CargoCompanyType.fromString('ty'), CargoCompanyType.trendyol);
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

  group('Yeni Tasarım AppFormatters & Hero Bakiye Testleri', () {
    test('formatDate tarihi "12 Mar 2025" seklinde formatlar', () {
      expect(AppFormatters.formatDate(DateTime(2025, 3, 12)), '12 Mar 2025');
      expect(AppFormatters.formatDate(DateTime(2025, 1, 1)), '1 Oca 2025');
      expect(AppFormatters.formatDate(DateTime(2025, 10, 28)), '28 Eki 2025');
      expect(AppFormatters.formatDate(null), '');
    });

    testWidgets('DashboardBalanceHeroCard bakiye ve alacak tutarlarini dogru render eder, Hareketler kaldirilmis ve Bakiye Yukle calisir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(
                  isInitialized: true,
                  token: 'test-token',
                  user: UserModel(
                    id: '1',
                    firstName: 'Emre',
                    lastName: 'Arslan',
                    fullName: 'Emre Arslan',
                    email: 'emre@stocado.com',
                    accountId: 'acc-1',
                    accounts: [
                      AccountModel(
                        id: 'acc-1',
                        name: 'Adorel Lojistik',
                        companyName: 'Adorel A.Ş.',
                        eftCode: 'ADO822716',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(
                const DashboardState(
                  isLoading: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardBalanceHeroCard(
                currentBalance: 20208.35,
                podReceivable: 8450.00,
              ),
            ),
          ),
        ),
      );

      // Başlık ve tutarlar görünür olmalı
      expect(find.text('Kullanılabilir Bakiye'), findsOneWidget);
      expect(find.text('20.208,35 ₺'), findsOneWidget);
      expect(find.text('8.450,00 ₺'), findsOneWidget);
      expect(find.text('Bakiye Yükle'), findsOneWidget);

      // Hareketler butonu KESİNLİKLE kaldırılmış olmalı
      expect(find.text('Hareketler'), findsNothing);

      // Göz ikonuna tıklandığında tutarlar gizlenmeli
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.text('•••••••• ₺'), findsOneWidget);
      expect(find.text('•••• ₺'), findsOneWidget);

      // Tekrar tıklandığında tutarlar açılmalı
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.text('20.208,35 ₺'), findsOneWidget);

      // Bakiye Yükle butonuna tıklandığında TopUpBalanceScreen çökmeden, pürüzsüzce açılmalı
      await tester.tap(find.text('Bakiye Yükle'));
      await tester.pumpAndSettle();

      expect(find.byType(TopUpBalanceScreen), findsOneWidget);
      expect(find.text('Kuveyt Türk Katılım Bankası A.Ş.'), findsOneWidget);
      expect(find.text('ADO822716'), findsWidgets);
    });
  });

  group('TopUpBalanceScreen Kapsamli Testleri', () {
    testWidgets('TopUpBalanceScreen banka hesap bilgilerini eksiksiz render eder ve kopyalama aksiyonlari hatasiz calisir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(
                  isInitialized: true,
                  token: 'test-token',
                  user: UserModel(
                    id: '1',
                    firstName: 'Emre',
                    lastName: 'Arslan',
                    fullName: 'Emre Arslan',
                    email: 'emre@stocado.com',
                    accountId: 'acc-1',
                    accounts: [
                      AccountModel(
                        id: 'acc-1',
                        name: 'Adorel Lojistik',
                        eftCode: 'ADO822716',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(
                const DashboardState(
                  isLoading: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: TopUpBalanceScreen(),
          ),
        ),
      );

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      expect(find.text('Bakiye Yükle'), findsOneWidget);
      expect(find.text('Kuveyt Türk Katılım Bankası A.Ş.'), findsOneWidget);
      expect(find.text('TR38 0020 5000 0956 8498 0000 01'), findsOneWidget);
      expect(find.text('ADO822716'), findsWidgets);
      expect(find.text('Nasıl Yüklenir?'), findsOneWidget);
      // Tümünü kopyala butonuna basıldığında exception atılmamalı
      await tester.ensureVisible(find.text('Tüm Hesap Bilgilerini Kopyala'));
      await tester.tap(find.text('Tüm Hesap Bilgilerini Kopyala'));
      await tester.pump();

      // Üst bardaki paylaş/kopyala ikonuna basıldığında exception atılmamalı
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();

      // Üst bardaki yenile ikonuna basıldığında exception atılmamalı
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      // Tekil kopyalama butonlarına basıldığında SnackBar'lar görüntülenmeli
      final copyButtons = find.byTooltip('Kopyala');
      expect(copyButtons, findsNWidgets(4));
      await tester.tap(copyButtons.first);
      await tester.pump();
      expect(find.text('Banka Adı panoya kopyalandı.'), findsOneWidget);
    });

    testWidgets('TopUpBalanceScreen hesabi veya eft kodu olmayan kullanici durumunda guvenle render edilir ve kopyalamada uyarir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                const AuthState(
                  isInitialized: true,
                  token: 'test-token',
                  user: null,
                ),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(
                const DashboardState(isLoading: false),
              ),
            ),
          ],
          child: const MaterialApp(
            home: TopUpBalanceScreen(),
          ),
        ),
      );

      expect(find.text('Bakiye Yükle'), findsOneWidget);
      expect(find.text('-'), findsWidgets);
      expect(find.text('0,00 ₺'), findsOneWidget);

      // Açıklama kodu atanmamışken tekil kopyala butonuna basıldığında uyarı SnackBar'ı çıkmalı
      final copyButtons = find.byTooltip('Kopyala');
      await tester.tap(copyButtons.last);
      await tester.pump();
      expect(find.text('Hesabınıza henüz bir Açıklama Kodu atanmamış.'), findsOneWidget);
    });

    testWidgets('DashboardBalanceHeroCard onTopUpTap callback parametresi basariyla calisir',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardBalanceHeroCard(
              currentBalance: 1500.0,
              podReceivable: 500.0,
              onTopUpTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bakiye Yükle'));
      expect(tapped, isTrue);
    });
  });

  group('DashboardPackageStatusRow Testleri', () {
    testWidgets('Yatay 4lu durum kutulari ve dikkat seridi dogru render edilir',
        (WidgetTester tester) async {
      String? tappedFilter;

      final mockStats = DashboardStats(
        totalCargos: 252,
        activeCargos: 28,
        pendingCargos: 12,
        problematicCargos: 3,
        deliveredToday: 206,
        returnedCargos: 6,
        deliveryRate: 95.0,
        balance: 20208.35,
        availableBalance: 20208.35,
        offsetBalance: 0.0,
        podCargoCount: 5,
        podPending: 8450.0,
        podCollected: 12000.0,
        podWillPay: 8450.0,
        recentCargos: [],
        weeklyTrend: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardPackageStatusRow(
              stats: mockStats,
              onStatusTap: (filter) => tappedFilter = filter,
            ),
          ),
        ),
      );

      expect(find.text('Kargolarım'), findsOneWidget);
      expect(find.text('Hazırlanan'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Yolda'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('Teslim'), findsOneWidget);
      expect(find.text('206'), findsOneWidget);
      expect(find.text('İade'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);

      // Dikkat / işlem bekleyen kutusu
      expect(find.text('3 gönderi işlem bekliyor'), findsOneWidget);

      // Durum kutuları tıklamaları test edilsin
      await tester.tap(find.text('Hazırlanan'));
      expect(tappedFilter, '0');

      await tester.tap(find.text('Yolda'));
      expect(tappedFilter, '1');

      await tester.tap(find.text('Teslim'));
      expect(tappedFilter, '2');

      await tester.tap(find.text('İade'));
      expect(tappedFilter, '4');

      // Dikkat kutusuna tıklandığında sorunlu/işlem bekleyenler (status 4) filtrelenir
      await tester.tap(find.text('3 gönderi işlem bekliyor'));
      expect(tappedFilter, '4');
    });
  });

  group('MainScreen 5-Tab Bar Testi', () {
    testWidgets('Gorseldeki 5 sekmeli navbar eksiksiz render edilir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Ana Sayfa'), findsOneWidget);
      expect(find.text('Kargolar'), findsOneWidget);
      expect(find.text('Yeni Kargo'), findsOneWidget);
      expect(find.text('Finans'), findsOneWidget);
      expect(find.text('Diğer'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);
    });
  });

  group('DashboardRecentCargosSection Testleri', () {
    testWidgets('Kargo listesi bos oldugunda bos durum ve Yeni Kargo butonu render edilir', (WidgetTester tester) async {
      bool newCargoTapped = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cargoListProvider.overrideWith(() => _TestCargoListNotifier(const CargoListState(isLoading: false, cargos: []))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DashboardRecentCargosSection(
                onSeeAllTap: () {},
                onNewCargoTap: () => newCargoTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Son Gönderiler'), findsOneWidget);
      expect(find.text('Tümünü Gör'), findsOneWidget);
      expect(find.text('Henüz kayıtlı gönderiniz bulunmuyor'), findsOneWidget);
      expect(find.text('Yeni Kargo Oluştur'), findsOneWidget);

      await tester.tap(find.text('Yeni Kargo Oluştur'));
      expect(newCargoTapped, isTrue);
    });

    testWidgets('Kargo verileri ile kartlar gorseldeki formatta render edilir', (WidgetTester tester) async {
      final mockCargo = CargoModel(
        id: '1',
        processNumber: 'PR-100',
        outTrackingCode: 'HJV1234567890',
        status: 1,
        latestTransactionType: 2,
        latestTransaction: CargoTransaction(
          type: 2,
          description: 'Kargo yola çıktı',
        ),
        receiver: CargoParty(
          id: 'rec-1',
          name: 'Ayşe Yılmaz',
          phone: '05551234567',
          city: LocationRef(id: '6', name: 'Ankara'),
        ),
        cargoCompanyId: 'hepsijet',
        createdAt: DateTime(2025, 3, 12),
        payOnDelivery: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cargoListProvider.overrideWith(() => _TestCargoListNotifier(CargoListState(isLoading: false, cargos: [mockCargo]))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DashboardRecentCargosSection(
                onSeeAllTap: () {},
                onNewCargoTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Son Gönderiler'), findsOneWidget);
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('Yolda'), findsOneWidget);
      expect(find.textContaining('Ankara'), findsOneWidget);
      expect(find.textContaining('12 Mar 2025'), findsOneWidget);
    });
  });

  group('DashboardScreen Tum Etkilesimler Testi', () {
    testWidgets('DashboardScreen bildirim ziline ve profil butonuna tiklandiginda sheetler acilir', (WidgetTester tester) async {
      final mockUser = UserModel(
        id: '1',
        firstName: 'Emre',
        lastName: 'Arslan',
        fullName: 'Emre Arslan',
        email: 'emre@stocado.com',
        accountId: 'acc-1',
        accounts: [
          AccountModel(
            id: 'acc-1',
            name: 'Adorel Lojistik',
            companyName: 'Adorel Lojistik A.Ş.',
            eftCode: 'ADO822716',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(
                  isInitialized: true,
                  token: 'test-token',
                  user: mockUser,
                ),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(
                const DashboardState(isLoading: false),
              ),
            ),
            cargoListProvider.overrideWith(
              () => _TestCargoListNotifier(
                const CargoListState(isLoading: false, cargos: []),
              ),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Kullanıcı karşılaması görünür olmalı
      expect(find.text('Merhaba, Emre'), findsOneWidget);

      // 1. Bildirim Zili Tıklaması
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Bildirimler'), findsOneWidget);
      expect(find.text('Tüm kargo ve bakiye bildirimleriniz günceldir.'), findsOneWidget);

      // Kapat
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 2. Profil İkonu Tıklaması
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Emre Arslan'), findsOneWidget);
      expect(find.text('Adorel Lojistik A.Ş.'), findsOneWidget);
      expect(find.text('Oturumu Kapat'), findsOneWidget);
    });

    testWidgets('DashboardScreen coklu hesap durumunda aktif accountId ile eslesen sirket adini gosterir', (WidgetTester tester) async {
      final multiAccountUser = UserModel(
        id: '2',
        firstName: 'Can',
        lastName: 'Kaya',
        fullName: 'Can Kaya',
        email: 'can@stocado.com',
        accountId: 'acc-2',
        accounts: [
          AccountModel(id: 'acc-1', name: 'Birinci Sirket', companyName: 'Birinci Sirket A.Ş.'),
          AccountModel(id: 'acc-2', name: 'İkinci Sirket', companyName: 'İkinci Sirket Ltd.'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(
                  isInitialized: true,
                  token: 'test-token',
                  user: multiAccountUser,
                ),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(const DashboardState(isLoading: false)),
            ),
            cargoListProvider.overrideWith(
              () => _TestCargoListNotifier(const CargoListState(isLoading: false, cargos: [])),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Profil ikonuna tıkla
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();

      // İlk şirket değil, aktif olan acc-2'nin şirket adı görünmeli
      expect(find.text('İkinci Sirket Ltd.'), findsOneWidget);
      expect(find.text('Birinci Sirket A.Ş.'), findsNothing);
    });

    testWidgets('DashboardScreen son gonderi kartina tiklandiginda detay modali acilir ve uzun basildiginda kopyalanir', (WidgetTester tester) async {
      final mockCargo = CargoModel(
        id: '1',
        processNumber: 'PR-100',
        outTrackingCode: 'HJV1234567890',
        status: 1,
        latestTransactionType: 2,
        latestTransaction: CargoTransaction(type: 2, description: 'Yolda'),
        receiver: CargoParty(
          id: 'rec-1',
          name: 'Mehmet Demir',
          phone: '05551234567',
          city: LocationRef(id: '34', name: 'İstanbul'),
        ),
        cargoCompanyId: 'hepsijet',
        createdAt: DateTime(2025, 3, 12),
        payOnDelivery: false,
      );

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                const AuthState(isInitialized: true, token: 'test-token'),
              ),
            ),
            dashboardProvider.overrideWith(
              () => _TestDashboardNotifier(
                const DashboardState(isLoading: false),
              ),
            ),
            cargoListProvider.overrideWith(
              () => _TestCargoListNotifier(
                CargoListState(isLoading: false, cargos: [mockCargo]),
              ),
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Mehmet Demir'), findsOneWidget);
      await tester.ensureVisible(find.text('Mehmet Demir'));

      // Uzun basıldığında takip numarası kopyalanmalı
      await tester.longPress(find.text('Mehmet Demir'));
      await tester.pump();
      expect(find.text('Takip numarası kopyalandı.'), findsOneWidget);

      // Tıklandığında CargoDetailModal açılmalı
      await tester.tap(find.text('Mehmet Demir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(CargoDetailModal), findsOneWidget);
    });

    testWidgets('DashboardScreen Tumunu Gor ve durum kutulari secimleri sekmeyi ve filtreyi gunceller', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(
              const AuthState(isInitialized: true, token: 'test-token'),
            ),
          ),
          dashboardProvider.overrideWith(
            () => _TestDashboardNotifier(
              const DashboardState(isLoading: false),
            ),
          ),
          cargoListProvider.overrideWith(
            () => _TestCargoListNotifier(
              const CargoListState(isLoading: false, cargos: []),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tümünü Gör tıklaması Tab 1'e geçmeli, aktif sekmeyi 'all' yapmalı ve filtreleri temizlemeli
      await tester.tap(find.text('Tümünü Gör'));
      expect(container.read(mainNavigationProvider).tabIndex, 1);
      expect(container.read(cargoListProvider).activeTab, 'all');
      expect(container.read(cargoListProvider).selectedStatus, isNull);

      // Durum kutusu tıklaması Tab 1'e geçmeli ve filtreyi ayarlamalı
      await tester.tap(find.text('Hazırlanan'));
      expect(container.read(mainNavigationProvider).tabIndex, 1);
      expect(container.read(cargoListProvider).activeTab, 'all');
      expect(container.read(cargoListProvider).selectedStatus, '0');

      await tester.tap(find.text('Yolda'));
      expect(container.read(cargoListProvider).selectedStatus, '1');

      await tester.tap(find.text('Teslim'));
      expect(container.read(cargoListProvider).selectedStatus, '2');

      await tester.tap(find.text('İade'));
      expect(container.read(cargoListProvider).selectedStatus, '4');
    });

    test('AccountModel.fromJson camelCase ve code fallback alanlarini hatasiz cozer', () {
      final acc1 = AccountModel.fromJson({
        'id': '10',
        'name': 'Test Lojistik',
        'eftCode': 'EFT123',
        'accountCode': 'ACC456',
      });
      expect(acc1.eftCode, 'EFT123');
      expect(acc1.accountCode, 'ACC456');

      final acc2 = AccountModel.fromJson({
        'id': '11',
        'name': 'Test 2',
        'code': 'CODE789',
      });
      expect(acc2.accountCode, 'CODE789');
    });
  });

  group('CargoStatusIcon & Status Rozeti Testleri', () {
    testWidgets('Teslim Edildi durumu icin yesil dairesel rozet ve tik ikonu render edilir', (tester) async {
      final cargo = CargoModel(
        id: 1,
        processNumber: 'P100',
        outTrackingCode: 'HJV123',
        status: 2,
        payOnDelivery: false,
        latestTransactionType: 6,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo),
          ),
        ),
      );

      expect(find.byType(CargoStatusIcon), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CargoStatusIcon), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF10B981));
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('Dagitimda durumu icin acik mavi rozet ve kurye ikonu render edilir', (tester) async {
      final cargo = CargoModel(
        id: 2,
        processNumber: 'P101',
        outTrackingCode: 'HJV124',
        status: 1,
        payOnDelivery: false,
        latestTransactionType: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo),
          ),
        ),
      );

      expect(find.byIcon(Icons.delivery_dining_rounded), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CargoStatusIcon), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF0284C7));
    });

    testWidgets('Yolda durumu icin canli mavi rozet ve kamyon ikonu render edilir', (tester) async {
      final cargo = CargoModel(
        id: 3,
        processNumber: 'P102',
        outTrackingCode: 'HJV125',
        status: 2,
        payOnDelivery: false,
        latestTransactionType: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CargoStatusIcon), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2563EB));
    });

    testWidgets('Sorunlu ve Iade durumu icin canli turuncu rozet render edilir', (tester) async {
      final cargo = CargoModel(
        id: 4,
        processNumber: 'P103',
        outTrackingCode: 'HJV126',
        status: 4,
        payOnDelivery: false,
        latestTransactionType: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo),
          ),
        ),
      );

      expect(find.byIcon(Icons.assignment_return_rounded), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CargoStatusIcon), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF97316));
    });

    testWidgets('showLabel true oldugunda kapsul rozet icinde hem ikon hem durum metni birlikte render edilir', (tester) async {
      final cargo = CargoModel(
        id: 5,
        processNumber: 'P104',
        outTrackingCode: 'HJV127',
        status: 2,
        payOnDelivery: false,
        latestTransactionType: 6,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo, showLabel: true),
          ),
        ),
      );

      expect(find.byType(CargoStatusIcon), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Teslim Edildi'), findsOneWidget);
    });

    testWidgets('latestTransactionType == 4 (Teslimat Subesi) Yolda olarak render edilir, Teslim Edildi ile karismaz', (tester) async {
      final cargo = CargoModel(
        id: 6,
        processNumber: 'P105',
        outTrackingCode: 'HJV128',
        status: 1,
        payOnDelivery: false,
        latestTransactionType: 4, // Teslimat Şubesi
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo, showLabel: true),
          ),
        ),
      );

      expect(find.text('Yolda'), findsOneWidget);
      expect(find.text('Teslim Edildi'), findsNothing);
    });

    testWidgets('latestTransactionType == 7 (Teslim Edilemedi) Sorunlu olarak render edilir', (tester) async {
      final cargo = CargoModel(
        id: 7,
        processNumber: 'P106',
        outTrackingCode: 'HJV129',
        status: 1,
        payOnDelivery: false,
        latestTransactionType: 7, // Teslim Edilemedi
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo, showLabel: true),
          ),
        ),
      );

      expect(find.text('Sorunlu'), findsOneWidget);
      expect(find.text('Teslim Edildi'), findsNothing);
    });

    testWidgets('latestTransactionType == 5 (Dagitimda) kurye ikonu ve Dagitimda metni ile render edilir', (tester) async {
      final cargo = CargoModel(
        id: 8,
        processNumber: 'P107',
        outTrackingCode: 'HJV130',
        status: 1,
        payOnDelivery: false,
        latestTransactionType: 5, // Dağıtımda
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargo, showLabel: true),
          ),
        ),
      );

      expect(find.text('Dağıtımda'), findsOneWidget);
      expect(find.byIcon(Icons.delivery_dining_rounded), findsOneWidget);
    });

    testWidgets('CargoCompanyLogo yatay modda firma logosunu net ve dogru render eder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CargoCompanyLogo(companyId: 'hepsijet', height: 20, isHorizontal: true),
                CargoCompanyLogo(companyId: 'mng', height: 20, isHorizontal: true),
                CargoCompanyLogo(companyId: 'kolay-gelsin', height: 20, isHorizontal: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('hepsi'), findsOneWidget);
      expect(find.text('JET'), findsOneWidget);
      expect(find.text('MNG'), findsOneWidget);
      expect(find.text('kolay gelsin'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('CargoCard Yeni Tasarim & Etkilesim Testleri', () {
    testWidgets('CargoCard gorsel mockup tasarimina uygun tum alanlari eksiksiz render eder', (tester) async {
      final testCargo = CargoModel(
        id: 101,
        processNumber: 'STC999',
        outTrackingCode: 'HJV1234567890',
        cargoCompanyId: 'hepsijet',
        status: 2,
        latestTransactionType: 3,
        createdAt: DateTime(2025, 3, 12, 10, 0),
        payOnDelivery: true,
        payOnDeliveryAmount: 1250.0,
        payOnDeliveryCost: 0.0,
        receiver: CargoParty(
          id: 'rec-1',
          name: 'Ayşe Yılmaz',
          phone: '05551234567',
          city: LocationRef(id: '06', name: 'Ankara'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoCard(cargo: testCargo),
          ),
        ),
      );

      // 1. Logo ve Takip No
      expect(find.text('HJV1234567890'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // 2. Alici ve Sehir
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('Ankara'), findsOneWidget);

      // 3. Durum Simgesi ve Tarih
      expect(find.byType(CargoStatusIcon), findsOneWidget);
      expect(find.text('12 Mar 2025'), findsOneWidget);

      // 4. Kapida Odeme Seridi
      expect(find.text('Kapıda Ödeme'), findsOneWidget);
      expect(find.text('1.250,00 ₺'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('Kopyala ikonuna basildiginda pano geri bildirimi verilir', (tester) async {
      final testCargo = CargoModel(
        id: 102,
        processNumber: 'P200',
        outTrackingCode: 'HJV987654',
        status: 1,
        payOnDelivery: false,
        receiver: CargoParty(
          id: 'rec-2',
          name: 'Mehmet Kaya',
          phone: '05559876543',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoCard(cargo: testCargo),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      expect(find.textContaining('Takip numarası kopyalandı'), findsOneWidget);
    });
  });

  group('CargosScreen Yeniden Tasarim & Filtre Testleri', () {
    testWidgets('CargosScreen baslik, arama kutusu ve 3lu pill sekmelerini dogru render eder', (tester) async {
      final mockCargos = [
        CargoModel(
          id: 1,
          processNumber: 'P1',
          outTrackingCode: 'HJV1',
          cargoCompanyId: 'hepsijet',
          status: 2,
          latestTransactionType: 3,
          createdAt: DateTime(2025, 3, 12),
          payOnDelivery: true,
          payOnDeliveryAmount: 1250.0,
          receiver: CargoParty(id: '1', name: 'Ayşe Yılmaz', phone: '0555', city: LocationRef(id: '6', name: 'Ankara')),
        ),
        CargoModel(
          id: 2,
          processNumber: 'P2',
          outTrackingCode: 'SR2',
          cargoCompanyId: 'surat',
          status: 2,
          latestTransactionType: 6,
          createdAt: DateTime(2025, 3, 11),
          payOnDelivery: false,
          receiver: CargoParty(id: '2', name: 'Mehmet Kaya', phone: '0555', city: LocationRef(id: '34', name: 'İstanbul')),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(
              AuthState(
                isInitialized: true,
                token: 'valid_token',
                user: UserModel(
                  id: '1',
                  firstName: 'Emirhan',
                  lastName: 'Demir',
                  fullName: 'Emirhan Demir',
                  email: 'e@test.com',
                  accountId: 'acc-1',
                  accounts: [],
                ),
              ),
            ),
          ),
          dashboardProvider.overrideWith(
            () => _TestDashboardNotifier(
              DashboardState(
                isLoading: false,
                stats: DashboardStats(
                  totalCargos: 252,
                  activeCargos: 28,
                  problematicCargos: 3,
                  pendingCargos: 5,
                  deliveredToday: 206,
                  deliveryRate: 98.0,
                  balance: 20208.35,
                  availableBalance: 20208.35,
                  offsetBalance: 0,
                  podCargoCount: 15,
                  podPending: 8450.0,
                  podCollected: 5000.0,
                  podWillPay: 8450.0,
                  recentCargos: const [],
                  weeklyTrend: const [],
                ),
              ),
            ),
          ),
          cargoListProvider.overrideWith(
            () => _TestCargoListNotifier(
              CargoListState(
                isLoading: false,
                cargos: mockCargos,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CargosScreen(),
          ),
        ),
      );

      await tester.pump();

      // 1. Baslik ve Butonlar
      expect(find.text('Kargolarım'), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      // 2. Arama Kutusu
      expect(find.text('Ad, telefon veya barkod ara'), findsOneWidget);

      // 3. 3 Kompakt Pill Tab ve Sayaclar (Mockup uyumu: Tumu 252, Yolda 28, Sorunlu 3)
      expect(find.text('Tümü'), findsOneWidget);
      expect(find.text('252'), findsOneWidget);
      expect(find.text('Yolda'), findsNWidgets(2)); // Üst filtre sekmesinde ve kargo kartı rozetinde
      expect(find.text('28'), findsOneWidget);
      expect(find.text('Sorunlu'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // 4. Kargo Kartlari
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('Mehmet Kaya'), findsOneWidget);
      expect(find.text('Teslim Edildi'), findsOneWidget); // Mehmet Kaya'nın durum rozetinde

      // 5. Pill sekmesine tiklama testi
      await tester.tap(find.text('Yolda').first);
      await tester.pump();
      expect(container.read(cargoListProvider).selectedStatus, '1');

      await tester.tap(find.text('Sorunlu'));
      await tester.pump();
      expect(container.read(cargoListProvider).selectedStatus, '4');

      await tester.tap(find.text('Tümü'));
      await tester.pump();
      expect(container.read(cargoListProvider).selectedStatus, isNull);
    });

    testWidgets('status == 2 olan ve transaction kaydi bulunmayan kargo Teslim Edildi olarak render edilir', (tester) async {
      final cargoWithoutTrans = CargoModel(
        id: 99,
        processNumber: 'P-NO-TRANS',
        outTrackingCode: 'TRK-NO-TRANS',
        status: 2, // Tamamlandı / Teslim Edildi
        payOnDelivery: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CargoStatusIcon(cargo: cargoWithoutTrans),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(CargoStatusIcon), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF10B981));
    });

    testWidgets('Ozel bir durum filtresi (or: Tamamlandi) seciliyken Tumu sekmesine basildiginda filtre sifirlanir', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(
              AuthState(
                isInitialized: true,
                token: 'valid_token',
                user: UserModel(
                  id: '1',
                  firstName: 'Emirhan',
                  lastName: 'Demir',
                  fullName: 'Emirhan Demir',
                  email: 'e@test.com',
                  accountId: 'acc-1',
                  accounts: [],
                ),
              ),
            ),
          ),
          dashboardProvider.overrideWith(
            () => _TestDashboardNotifier(
              const DashboardState(isLoading: false),
            ),
          ),
          cargoListProvider.overrideWith(
            () => _TestCargoListNotifier(
              const CargoListState(
                isLoading: false,
                activeTab: 'all',
                selectedStatus: '2', // Ozel secili durum (Tamamlandi)
                cargos: [],
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CargosScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tümü sekmesine bas
      await tester.tap(find.text('Tümü'));
      await tester.pump();

      expect(container.read(cargoListProvider).selectedStatus, isNull);
      expect(container.read(cargoListProvider).activeTab, 'all');
    });

    testWidgets('CargoCard 320px dar ekranda uzun ilce, il ve Kapida Odeme ile tasma olmadan render edilir', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final narrowCargo = CargoModel(
        id: 77,
        processNumber: 'P-NARROW-VERY-LONG-12345678',
        outTrackingCode: 'HJV-NARROW-998877665544',
        cargoCompanyId: 'hepsijet',
        status: 1,
        latestTransactionType: 3,
        createdAt: DateTime(2025, 3, 12),
        payOnDelivery: true,
        payOnDeliveryAmount: 1250.0,
        payOnDeliveryCost: 50.0,
        payOnDeliveryStatus: 0,
        receiver: CargoParty(
          id: 'rec-narrow',
          name: 'Hacı Mehmet Abdurrahman Şentürk Ticaret',
          phone: '05551234567',
          city: LocationRef(id: '34', name: 'İstanbul'),
          district: LocationRef(id: '3401', name: 'Kadıköy'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CargoCard(cargo: narrowCargo),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1.250,00 ₺'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}


