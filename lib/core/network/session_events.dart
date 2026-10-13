import 'dart:async';

/// Broadcasts session-level events (e.g. 401 from the error interceptor) so
/// interested listeners (AuthController) can react — typically by clearing
/// the session and redirecting to /login — without the network layer having
/// a direct dependency on GetX controllers.
enum SessionEvent { unauthorized }

class SessionEvents {
  SessionEvents._();
  static final SessionEvents instance = SessionEvents._();

  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void emitUnauthorized() => _controller.add(SessionEvent.unauthorized);

  void dispose() => _controller.close();
}
