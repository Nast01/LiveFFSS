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
}
