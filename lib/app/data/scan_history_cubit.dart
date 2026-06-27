import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ScanHistoryState {}

final class ScanHistoryLoaded extends ScanHistoryState {
  final List<QrCodeModel> scans;
  ScanHistoryLoaded({required this.scans});
}

class ScanHistoryCubit extends Cubit<ScanHistoryState> {
  ScanHistoryCubit() : super(ScanHistoryLoaded(scans: [])) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(AppConstants.scanHistoryKey) ?? [];
      final scans = jsonList
          .map((j) => QrCodeModel.fromJson(jsonDecode(j)))
          .toList();
      emit(ScanHistoryLoaded(scans: scans));
    } catch (_) {
      emit(ScanHistoryLoaded(scans: []));
    }
  }

  Future<void> addScan(QrCodeModel scan) async {
    try {
      final current = state is ScanHistoryLoaded
          ? (state as ScanHistoryLoaded).scans
          : <QrCodeModel>[];
      final updated = [scan, ...current].take(50).toList();
      final prefs = await SharedPreferences.getInstance();
      final jsonList = updated.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(AppConstants.scanHistoryKey, jsonList);
      emit(ScanHistoryLoaded(scans: updated));
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.scanHistoryKey);
      emit(ScanHistoryLoaded(scans: []));
    } catch (_) {}
  }
}
