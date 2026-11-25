/// Adresele serviciului Web REST folosit de aplicație.
class ApiConstants {
  const ApiConstants._();

  static const baseUrl = 'https://test-api-jlbn.onrender.com/lab2026/v4';
  static const feedPath = '/feed';
  static const courseDetailsPath = '/feed/details';

  /// Serverul gratuit Render poate „dormi” și pornește în ~30-50s la primul apel.
  static const timeout = Duration(seconds: 60);
}
