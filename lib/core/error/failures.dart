abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(
      [String message = 'A server error occurred. Please try again.'])
      : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [String message = 'No Internet connection. Please check your network.'])
      : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(
      [String message = 'Connection timed out. Please try again.'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Failed to load local data.'])
      : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(
      [String message = 'Authentication failed. Please try again.'])
      : super(message);
}
