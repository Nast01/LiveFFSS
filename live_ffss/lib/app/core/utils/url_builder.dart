class UrlBuilder {
  static Uri buildUrl<T>(
      String baseUrl, String path, Map<String, T?> queryParams) {
    // Filter out null and empty parameters, convert all to strings
    final filteredParams = <String, String>{};

    queryParams.forEach((key, value) {
      if (value != null) {
        final stringValue = value.toString();
        if (stringValue.isNotEmpty && stringValue != 'null') {
          filteredParams[key] = stringValue;
        }
      }
    });

    return Uri.parse(baseUrl + path).replace(queryParameters: filteredParams);
  }

  static Uri buildUrlAllowEmpty<T>(
      String baseUrl, String path, Map<String, T?> queryParams) {
// Clean up the base URL and path
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    // Convert query parameters to Map<String, String>
    final Map<String, String> stringParams = {};

    queryParams.forEach((key, value) {
      stringParams[key] = value.toString();
    });

    // Build the complete URL
    final uri = Uri.parse('$cleanBaseUrl$cleanPath');

    // Add query parameters
    return uri.replace(queryParameters: stringParams);
  }
}
