import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrapSupabase({
  required String url,
  required String anonKey,
}) async {
  await Supabase.initialize(url: url, anonKey: anonKey);
  final authCode = Uri.base.queryParameters['code'];
  if (authCode != null && authCode.isNotEmpty) {
    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(authCode);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('exchangeCodeForSession error: $e');
      }
    }
  }
}
