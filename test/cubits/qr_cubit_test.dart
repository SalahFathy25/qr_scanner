import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/qr_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  blocTest<QrCubit, QrState>(
    'initializes with success state and empty codes',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    verify: (cubit) {
      final state = cubit.state;
      expect(state, isA<QrSuccess>());
      expect((state as QrSuccess).qrCodes, isEmpty);
    },
  );

  blocTest<QrCubit, QrState>(
    'adds a QR code correctly',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) => cubit.addQrCode(title: 'Test', data: 'test data', category: 'text'),
    verify: (cubit) {
      final state = cubit.state as QrSuccess;
      expect(state.qrCodes.length, 1);
      expect(state.qrCodes.first.title, 'Test');
      expect(state.qrCodes.first.data, 'test data');
      expect(state.qrCodes.first.category, 'text');
    },
  );

  blocTest<QrCubit, QrState>(
    'deletes a QR code and returns to empty',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) async {
      await cubit.addQrCode(title: 'Test', data: 'data', category: 'text');
      final id = (cubit.state as QrSuccess).qrCodes.first.id;
      await cubit.deleteQrCode(id);
    },
    verify: (cubit) {
      final state = cubit.state as QrSuccess;
      expect(state.qrCodes.length, 0);
    },
  );

  blocTest<QrCubit, QrState>(
    'toggles favorite status',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) async {
      await cubit.addQrCode(title: 'Test', data: 'data', category: 'text');
      final id = (cubit.state as QrSuccess).qrCodes.first.id;
      await cubit.toggleFavorite(id);
    },
    verify: (cubit) {
      final state = cubit.state as QrSuccess;
      expect(state.qrCodes.first.isFavorite, true);
    },
  );

  blocTest<QrCubit, QrState>(
    'searches QR codes by title',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) async {
      await cubit.addQrCode(title: 'Alpha', data: 'aaa', category: 'text');
      await cubit.addQrCode(title: 'Beta', data: 'bbb', category: 'text');
    },
    verify: (cubit) {
      final results = cubit.searchQrCodes('Alpha');
      expect(results.length, 1);
      expect(results.first.title, 'Alpha');
    },
  );

  blocTest<QrCubit, QrState>(
    'filters by category',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) async {
      await cubit.addQrCode(title: 'Wifi1', data: 'wifi', category: 'wifi');
      await cubit.addQrCode(title: 'Text1', data: 'txt', category: 'text');
    },
    verify: (cubit) {
      final wifiCodes = cubit.getQrCodesByCategory('wifi');
      expect(wifiCodes.length, 1);
      expect(wifiCodes.first.title, 'Wifi1');
    },
  );

  blocTest<QrCubit, QrState>(
    'updates a QR code',
    build: () => QrCubit(),
    wait: const Duration(milliseconds: 200),
    act: (cubit) async {
      await cubit.addQrCode(title: 'Old', data: 'old', category: 'text');
      final id = (cubit.state as QrSuccess).qrCodes.first.id;
      await cubit.updateQrCode(id: id, title: 'New Title');
    },
    verify: (cubit) {
      final state = cubit.state as QrSuccess;
      expect(state.qrCodes.first.title, 'New Title');
    },
  );
}
