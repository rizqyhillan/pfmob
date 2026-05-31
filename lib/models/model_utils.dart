import '../config/api_config.dart';

String resolveStorageUrl(dynamic raw) {
  final value = raw?.toString() ?? '';
  if (value.isEmpty) return '';

  if (value.startsWith('http://') || value.startsWith('https://')) {
    if (value.contains('127.0.0.1')) {
      return value.replaceAll('127.0.0.1', '10.0.2.2');
    }
    return value;
  }

  var path = value.trim();
  while (path.startsWith('/')) {
    path = path.substring(1);
  }

  if (path.startsWith('storage/')) {
    path = path.replaceFirst('storage/', '');
  }

  while (path.startsWith('/')) {
    path = path.substring(1);
  }

  final serverBaseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');
  final resolved = '$serverBaseUrl/storage/$path';
  if (resolved.contains('127.0.0.1')) {
    return resolved.replaceAll('127.0.0.1', '10.0.2.2');
  }
  return resolved;
}
