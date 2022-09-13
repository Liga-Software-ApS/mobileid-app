class UnauthorizedException implements Exception {
  String cause;
  UnauthorizedException(this.cause);
}

class UnreachableException implements Exception {
  String cause;
  UnreachableException(this.cause);
}