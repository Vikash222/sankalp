import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/tracking_session.dart';

/// Manages atomic local disk persistence for mid-run crash recovery and offline resumption.
class CrashRecoveryStorage {
  static const String sessionFileName = 'active_tracking_session.json';
  static const String tempFileName = 'active_tracking_session.tmp';

  Future<File> _getFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$name');
  }

  /// Atomically saves the active tracking session to local disk.
  Future<void> saveActiveSession(TrackingSession session) async {
    try {
      final jsonString = jsonEncode(session.toJson());
      final tempFile = await _getFile(tempFileName);
      final targetFile = await _getFile(sessionFileName);

      await tempFile.writeAsString(jsonString, flush: true);
      if (await tempFile.exists()) {
        await tempFile.rename(targetFile.path);
      }
    } catch (e) {
      // In case of disk I/O errors, do not crash the tracking loop
    }
  }

  /// Loads an unfinalized session left behind by an unexpected app termination or device reboot.
  Future<TrackingSession?> loadActiveSession() async {
    try {
      final file = await _getFile(sessionFileName);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;

      final map = jsonDecode(content) as Map<String, dynamic>;
      return TrackingSession.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Clears the crash recovery cache upon a clean session stop or intentional discard.
  Future<void> clearActiveSession() async {
    try {
      final file = await _getFile(sessionFileName);
      if (await file.exists()) {
        await file.delete();
      }
      final tempFile = await _getFile(tempFileName);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}
  }
}
