import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:share_plus/share_plus.dart';

sealed class ExportImportState {}

final class ExportImportInitial extends ExportImportState {}

final class ExportImportLoading extends ExportImportState {}

final class ExportImportSuccess extends ExportImportState {
  final String message;
  final List<QrCodeModel>? importedCodes;
  ExportImportSuccess({required this.message, this.importedCodes});
}

final class ExportImportError extends ExportImportState {
  final String message;
  ExportImportError({required this.message});
}

class ExportImportCubit extends Cubit<ExportImportState> {
  ExportImportCubit() : super(ExportImportInitial());

  Future<void> exportQrCodes(List<QrCodeModel> codes) async {
    emit(ExportImportLoading());
    try {
      final exportData = {
        'app': 'QR Studio',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'count': codes.length,
        'qrCodes': codes.map((c) => c.toJson()).toList(),
      };

      final json = const JsonEncoder.withIndent('  ').convert(exportData);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_studio_backup.json');
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Studio - ${codes.length} QR codes',
      );

      emit(ExportImportSuccess(message: 'Exported ${codes.length} QR codes'));
    } catch (e) {
      emit(ExportImportError(message: 'Export failed: $e'));
    }
  }

  Future<List<QrCodeModel>?> importFromFile(String filePath) async {
    emit(ExportImportLoading());
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        emit(ExportImportError(message: 'File not found'));
        return null;
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['app'] != 'QR Studio') {
        emit(ExportImportError(message: 'Invalid backup file'));
        return null;
      }

      final codesJson = data['qrCodes'] as List<dynamic>;
      final codes = codesJson
          .map((j) => QrCodeModel.fromJson(j as Map<String, dynamic>))
          .toList();

      emit(ExportImportSuccess(
        message: 'Imported ${codes.length} QR codes',
        importedCodes: codes,
      ));
      return codes;
    } catch (e) {
      emit(ExportImportError(message: 'Import failed: $e'));
      return null;
    }
  }

  Future<String?> pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.files.single.path;
  }
}
