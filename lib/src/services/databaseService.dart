import 'package:sketchy_coins/packages.dart';

class DatabaseService {
  static final supabaseUrl = 'https://shepbpgqtqyeddohurey.supabase.co';
  static final supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxOTkxMjAwNCwiZXhwIjoxOTM1NDg4MDA0fQ.6RRIJNmdBJ6atvWcJmnLrgCME2E53KZNiE4eC3j0BKA';
  final client = PostgrestClient('$supabaseUrl/rest/v1',
      headers: {'apikey': supabaseKey}, schema: 'public');
}
