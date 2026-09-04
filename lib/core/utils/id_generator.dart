import 'dart:math';

final _random = Random();

/// A short, device-generated id: unique enough locally (timestamp + random
/// suffix) to key persisted records like recipes or meal plan entries,
/// without needing a backend-assigned id or a uuid package.
String generateLocalId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';
