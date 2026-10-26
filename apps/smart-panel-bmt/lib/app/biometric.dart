import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// Only confirms commands to mock repositories; it does not authenticate a BMT account.
abstract interface class BiometricConfirmation {
  Future<bool> confirm(
    String reason, {
    required String title,
    required String cancel,
  });
  Future<void> cancel();
}

final biometricProvider = Provider<BiometricConfirmation>(
  (ref) => DeviceBiometricConfirmation(),
);

class DeviceBiometricConfirmation implements BiometricConfirmation {
  final _auth = LocalAuthentication();
  @override
  Future<bool> confirm(
    String reason, {
    required String title,
    required String cancel,
  }) async {
    try {
      if (!await _auth.canCheckBiometrics ||
          (await _auth.getAvailableBiometrics()).isEmpty) {
        return false;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: [
          AndroidAuthMessages(signInTitle: title, cancelButton: cancel),
          IOSAuthMessages(cancelButton: cancel, localizedFallbackTitle: ''),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      /* Hold remains available. */
    } on MissingPluginException {
      /* No Android host in widget rendering. */
    }
  }
}
