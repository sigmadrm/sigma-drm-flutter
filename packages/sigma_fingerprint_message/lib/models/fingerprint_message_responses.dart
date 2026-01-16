import './fingerprint_settings.dart';
import './message_settings.dart';

class FPMSettingsResponse {
  final MessageSettings? messageSettings;
  final FingerprintSettings? fingerprintSettings;

  FPMSettingsResponse({
    this.messageSettings,
    this.fingerprintSettings,
  });
}
