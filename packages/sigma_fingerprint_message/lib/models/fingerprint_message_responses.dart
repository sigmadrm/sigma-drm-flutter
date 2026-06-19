import './fingerprint_settings.dart';
import './message_settings.dart';

class FPMSettingsResponse {
  final SmMessageSettings? messageSettings;
  final SmFingerprintSettings? fingerprintSettings;

  FPMSettingsResponse({this.messageSettings, this.fingerprintSettings});
}
