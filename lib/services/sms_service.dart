import 'package:url_launcher/url_launcher.dart';

class SMSService {
  static Future<void> sendSOS(String message) async {
    final Uri uri = Uri.parse(
      "sms:112?body=${Uri.encodeComponent(message)}",
    );

    final bool launched = await launchUrl(uri);
    if (!launched) {
      throw Exception('Could not open SMS app');
    }
  }
}
