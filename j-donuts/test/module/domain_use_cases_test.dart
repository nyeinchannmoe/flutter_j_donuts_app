import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/product/domain/entities/cart_rules.dart';
import 'package:jdonuts/module/product/domain/repositories/cart_repository.dart';
import 'package:jdonuts/module/product/domain/usecases/add_to_cart.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AddToCart', () {
    late _MockCartRepository repository;

    setUp(() => repository = _MockCartRepository());

    test('rejects quantities outside the cart limits', () async {
      final addToCart = AddToCart(repository);

      for (final quantity in [0, CartRules.maxQuantity + 1]) {
        final result = await addToCart(productId: 'p', quantity: quantity);
        expect(result.failureOrNull?.code, AddToCart.quantityOutOfRangeCode);
      }
      verifyZeroInteractions(repository);
    });

    test('delegates a valid quantity to the repository', () async {
      when(
        () => repository.addToCart(productId: 'p', quantity: 3),
      ).thenAnswer((_) async => const Ok(5));

      final result = await AddToCart(repository)(productId: 'p', quantity: 3);

      expect(result, const Ok(5));
    });
  });

  group('auth use cases', () {
    late _MockAuthRepository repository;

    setUpAll(
      () => registerFallbackValue(
        RegistrationDetails(firstName: '', dateOfBirth: DateTime(2000)),
      ),
    );
    setUp(() => repository = _MockAuthRepository());

    test('RequestOtp rejects an invalid phone number', () async {
      final result = await RequestOtp(repository)('12345');

      expect(result.failureOrNull?.code, RequestOtp.invalidPhoneCode);
      verifyZeroInteractions(repository);
    });

    test('VerifyOtp rejects an incomplete code', () async {
      final result = await VerifyOtp(repository)(
        phoneE164: '+959123456789',
        code: '123',
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.code, FailureCodes.invalidCode);
    });

    test('RegisterUser rejects a member younger than 13', () async {
      final register = RegisterUser(
        repository,
        today: () => DateTime(2026, 11, 9),
      );

      final result = await register(
        RegistrationDetails(firstName: 'Su', dateOfBirth: DateTime(2020)),
      );

      expect(result.failureOrNull?.code, RegisterUser.invalidDetailsCode);
      verifyNever(() => repository.register(any()));
    });

    test('RegisterUser forwards valid details', () async {
      final details = RegistrationDetails(
        firstName: 'Su',
        dateOfBirth: DateTime(2000),
      );
      final profile = UserProfile(
        id: 'u_1',
        phoneE164: '+959123456789',
        firstName: 'Su',
        dateOfBirth: DateTime(2000),
      );
      when(
        () => repository.register(details),
      ).thenAnswer((_) async => Ok(profile));

      final result = await RegisterUser(repository)(details);

      expect(result, Ok(profile));
    });
  });
}
