import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocado_mobile/features/auth/models/user_model.dart';
import 'package:stocado_mobile/features/auth/providers/auth_provider.dart';
import 'package:stocado_mobile/features/auth/screens/login_screen.dart';
import 'package:stocado_mobile/features/cargo/models/cargo_model.dart';
import 'package:stocado_mobile/features/cargo/models/cargo_offer_model.dart';
import 'package:stocado_mobile/features/home/screens/more_screen.dart';

class _TestAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  _TestAuthNotifier(this._initialState);

  @override
  AuthState build() => _initialState;
}

void main() {
  group('App Store 5.1.1 & Play Store Uyum Testleri: Giriş & Kayıt', () {
    testWidgets('LoginScreen üzerinde Web Kayıt Ol linki ve yönlendirme butonu bulunur',
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
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // "Hesabınız yok mu?" ve "Kayıt Ol" butonu görünmelidir
      expect(find.text('Hesabınız yok mu?'), findsOneWidget);
      expect(find.text('Kayıt Ol'), findsOneWidget);
      expect(find.byKey(const ValueKey('login_register_button')), findsOneWidget);

      // Kayıt Ol butonuna basıldığında hata vermeden tetiklenir
      await tester.tap(find.byKey(const ValueKey('login_register_button')));
      await tester.pump();
    });
  });

  group('App Store 5.1.1 Hesap Silme & Destek Merkezi Testleri', () {
    testWidgets('MoreScreen Hesap & Güvenlik altında Müşteri Desteği ve Hesabımı Sil seçeneklerini render eder',
        (WidgetTester tester) async {
      final user = UserModel(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        fullName: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        accountId: 'acc-1',
        accounts: [
          AccountModel(id: 'acc-1', name: 'Yılmaz Ticaret', companyName: 'Yılmaz Ltd.'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(isInitialized: true, token: 'token', user: user),
              ),
            ),
          ],
          child: const MaterialApp(
            home: MoreScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hesap & Güvenlik'), findsOneWidget);
      expect(find.text('Müşteri Destek Merkezi'), findsOneWidget);
      expect(find.text('Hesabımı Sil'), findsOneWidget);
      expect(find.text('Çıkış Yap'), findsOneWidget);
    });

    testWidgets('Hesabımı Sil tıklandığında App Store 5.1.1 uyumlu bilgilendirme ve WhatsApp destek modalı açılır',
        (WidgetTester tester) async {
      final user = UserModel(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        fullName: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        accountId: 'acc-1',
        accounts: [
          AccountModel(id: 'acc-1', name: 'Yılmaz Ticaret', companyName: 'Yılmaz Ltd.'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthNotifier(
                AuthState(isInitialized: true, token: 'token', user: user),
              ),
            ),
          ],
          child: const MaterialApp(
            home: MoreScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Hesabımı Sil menü öğesine scroll et ve tıkla
      await tester.ensureVisible(find.text('Hesabımı Sil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hesabımı Sil'));
      await tester.pumpAndSettle();

      // Modal dialog render edilmeli
      expect(find.text('Hesap Silme Talebi'), findsOneWidget);
      expect(find.text('Güvenlik ve Yasal Doğrulama Gerekliliği'), findsOneWidget);
      expect(
        find.textContaining('Mevcut aktif kargo gönderileriniz, tahsilatlı (kapıda ödeme) teslimat süreçleriniz ve cüzdan bakiyeniz bulunabileceğinden dolayı'),
        findsOneWidget,
      );

      // WhatsApp ve iletişim aksiyonları
      expect(find.text('WhatsApp Destek (+90 553 448 81 92)'), findsOneWidget);
      expect(find.text('Telefon ile Ara (+90 553 448 81 92)'), findsOneWidget);
      expect(find.text('Web Portalı (portal.stocado.com)'), findsOneWidget);
      expect(find.text('Vazgeç'), findsOneWidget);

      // Vazgeç butonuna basıldığında modal kapanır
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();

      expect(find.text('Hesap Silme Talebi'), findsNothing);
    });
  });

  group('0 Desi ve OpenAPI Entegrasyon Testleri', () {
    test('CargoModel 0.0 desi (Evrak) değerini 1.0 desiye ezmeden 0.0 olarak korur', () {
      final cargoWithZeroDesi = CargoModel(
        id: 'c-0',
        processNumber: 'REF-0',
        outTrackingCode: 'TRK-0',
        status: 1,
        payOnDelivery: false,
        validDesi: 0.0,
        userDesi: 0.0,
      );
      expect(cargoWithZeroDesi.effectiveDesi, 0.0);

      final cargoUserZero = CargoModel(
        id: 'c-1',
        processNumber: 'REF-1',
        outTrackingCode: 'TRK-1',
        status: 1,
        payOnDelivery: false,
        validDesi: null,
        userDesi: 0.0,
      );
      expect(cargoUserZero.effectiveDesi, 0.0);
    });

    test('CargoCalculateRequest normal Alıcı Öder durumunda receiver_pays true ve pod_receiver_pays false serialize eder', () {
      final req = CargoCalculateRequest(
        accountId: '100',
        package: PackageData(desi: 0.0),
        payOnDelivery: false,
        podReceiverPays: false,
        receiverPays: true,
      );

      final json = req.toJson();
      expect(json['pay_on_delivery'], isFalse);
      expect(json['pod_receiver_pays'], isFalse);
      expect(json['receiver_pays'], isTrue);
      expect(json['package']['desi'], 0.0);
    });

    test('CargoCalculateRequest Kapıda Alıcı Öder durumunda pod_receiver_pays true serialize eder', () {
      final req = CargoCalculateRequest(
        accountId: '100',
        package: PackageData(desi: 2.0),
        payOnDelivery: true,
        payOnDeliveryAmount: 350.0,
        podReceiverPays: true,
        receiverPays: false,
      );

      final json = req.toJson();
      expect(json['pay_on_delivery'], isTrue);
      expect(json['pay_on_delivery_amount'], 350.0);
      expect(json['pod_receiver_pays'], isTrue);
      expect(json['receiver_pays'], isFalse);
    });

    test('CargoCalculateRequest cargo_company_id boş ise payload içinde yer almaz, belirtilirse eklenir', () {
      final reqWithoutCompany = CargoCalculateRequest(
        accountId: '100',
        package: PackageData(desi: 1.0),
      );
      final jsonWithout = reqWithoutCompany.toJson();
      expect(jsonWithout.containsKey('cargo_company_id'), isFalse);

      final reqWithCompany = CargoCalculateRequest(
        accountId: '100',
        cargoCompanyId: 'ptt-kargo',
        package: PackageData(desi: 1.0),
      );
      final jsonWith = reqWithCompany.toJson();
      expect(jsonWith['cargo_company_id'], 'ptt-kargo');
    });
  });
}
