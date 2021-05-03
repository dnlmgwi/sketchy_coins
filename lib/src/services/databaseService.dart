import 'package:sketchy_coins/packages.dart';

class DatabaseService {
  static final envSupabaseUrl = Platform.environment['SUPABASE_URL'];
  static const localSupabaseUrl = 'https://shepbpgqtqyeddohurey.supabase.co';
  // 'https://yhidmwnuvklxbiqbhzpv.supabase.co';
  static String supabaseUrl = envSupabaseUrl ?? localSupabaseUrl;

  static final envSupabaseKey = Platform.environment['SUPABASE_KEY'];
  static const localSupabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxOTkxMjAwNCwiZXhwIjoxOTM1NDg4MDA0fQ.6RRIJNmdBJ6atvWcJmnLrgCME2E53KZNiE4eC3j0BKA';
  // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyMDA0NzE0MCwiZXhwIjoxOTM1NjIzMTQwfQ.07I6oe0MGd66Wy8wnqh4pd2Ya3qjyt_qT2l4K1ZFb-4';
  static String supabaseKey = envSupabaseKey ?? localSupabaseKey;

  final client = PostgrestClient('$supabaseUrl/rest/v1',
      headers: {'apikey': supabaseKey}, schema: 'public');
}
