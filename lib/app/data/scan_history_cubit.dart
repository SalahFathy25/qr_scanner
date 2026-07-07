import 'package:bloc/bloc.dart';
import 'package:qr_studio/app/models/qr_code_model.dart';
import 'package:qr_studio/core/services/storage_service.dart';

sealed class ScanHistoryState {
  const ScanHistoryState();
}

final class ScanHistoryLoaded extends ScanHistoryState {
  final List<QrCodeModel> scans;
  const ScanHistoryLoaded({required this.scans});
}

class ScanHistoryCubit extends Cubit<ScanHistoryState> {
  ScanHistoryCubit(this._storage)
      : super(const ScanHistoryLoaded(scans: [])) {
    _loadHistory();
  }

  final StorageService _storage;

  Future<void> _loadHistory() async {
    try {
      final scans = await _storage.loadScanHistory();
      emit(ScanHistoryLoaded(scans: scans));
    } catch (_) {
      emit(const ScanHistoryLoaded(scans: []));
    }
  }

  Future<void> addScan(QrCodeModel scan) async {
    try {
      final current = switch (state) {
        ScanHistoryLoaded(:final scans) => scans,
      };
      final updated = [scan, ...current].take(50).toList();
      await _storage.saveScanHistory(updated);
      emit(ScanHistoryLoaded(scans: updated));
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    try {
      await _storage.saveScanHistory([]);
      emit(const ScanHistoryLoaded(scans: []));
    } catch (_) {}
  }
}
