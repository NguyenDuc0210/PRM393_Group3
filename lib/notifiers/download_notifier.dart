
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/database_helper.dart';
import '../main.dart';

class DownloadState {
  final Set<int> downloadingIds;
  final List<Map<String, dynamic>> downloadedArticles;

  DownloadState({
    required this.downloadingIds,
    required this.downloadedArticles,
  });

  DownloadState copyWith({
    Set<int>? downloadingIds,
    List<Map<String, dynamic>>? downloadedArticles,
  }) {
    return DownloadState(
      downloadingIds: downloadingIds ?? this.downloadingIds,
      downloadedArticles: downloadedArticles ?? this.downloadedArticles,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(DownloadState(downloadingIds: {}, downloadedArticles: [])) {
    loadDownloadedArticles();
  }

  Future<void> loadDownloadedArticles() async {
    final articles = await DatabaseHelper.instance.getDownloadedArticles();
    state = state.copyWith(downloadedArticles: articles);
  }

  Future<void> downloadArticle(Map<String, dynamic> article, {BuildContext? context}) async {
    final id = article['id'];
    if (id == null) return;
    if (state.downloadingIds.contains(id)) return;

    // THÔNG BÁO BẮT ĐẦU ĐỂ BIẾT NÚT ĐÃ HOẠT ĐỘNG
    debugPrint("Starting download for article: $id");

    try {
      // KIỂM TRA MẠNG (Bọc trong try-catch để tránh crash nếu thư viện chưa cài xong)
      final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
      bool isOffline = results.contains(ConnectivityResult.none) && results.length == 1;

      if (isOffline) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection. Please check your network.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint("Connectivity check failed: $e. Proceeding with download anyway.");
    }

    state = state.copyWith(downloadingIds: {...state.downloadingIds, id});

    try {
      // Giả lập delay tải (2 giây)
      await Future.delayed(const Duration(seconds: 2));

      final result = await DatabaseHelper.instance.insertDownloadedArticle(article);

      if (result != -1) {
        await _showNotification(article['name']);
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      final updatedArticles = await DatabaseHelper.instance.getDownloadedArticles();
      final newDownloadingIds = {...state.downloadingIds};
      newDownloadingIds.remove(id);
      
      state = state.copyWith(
        downloadingIds: newDownloadingIds,
        downloadedArticles: updatedArticles,
      );
    }
  }

  Future<void> removeDownloadedArticle(int id) async {
    await DatabaseHelper.instance.deleteDownloadedArticle(id);
    await loadDownloadedArticles();
  }

  Future<void> _showNotification(String articleName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notifications for downloaded articles',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      'Download Complete! 📥',
      'Article "$articleName" is now available offline.',
      details,
    );
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier();
});
