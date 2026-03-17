abstract class AuthTokenStore {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class InMemoryTokenStore implements AuthTokenStore {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}