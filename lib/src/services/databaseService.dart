import 'package:sketchy_coins/packages.dart';

class DatabaseService {
  static final client = PostgrestClient(
    '${Env.supabaseUrl}/rest/v1',
    headers: {'apikey': '${Env.supabaseKey}'},
    schema: 'public',
  );
}
