import 'package:flutter/material.dart';
import 'package:supabase_flutter/src/supabase.dart';
import 'package:supabase_flutter/src/supabase_state.dart';

/// Interface for screen that requires an authenticated user
abstract class SupabaseAuthRequiredState<T extends StatefulWidget>
    extends SupabaseState<T> with WidgetsBindingObserver {
  @override
  void startAuthObserver() {
    Supabase().log('***** SupabaseAuthRequiredState startAuthObserver');
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void stopAuthObserver() {
    Supabase().log('***** SupabaseAuthRequiredState stopAuthObserver');
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<bool> onResumed() async {
    Supabase().log('***** SupabaseAuthRequiredState onResumed');
    final bool exist = await Supabase().hasAccessToken;
    if (!exist) {
      onUnauthenticated();
      return false;
    }

    final String? jsonStr = await Supabase().accessToken;
    if (jsonStr == null) {
      onUnauthenticated();
      return false;
    }

    final response = await Supabase().client.auth.recoverSession(jsonStr);
    if (response.error != null) {
      Supabase().removePersistSession();
      onUnauthenticated();
      return false;
    } else {
      return true;
    }
  }

  /// Callback when user is unauthenticated
  void onUnauthenticated();
}