import 'package:sketchy_coins/packages.dart';
import 'package:supabase/supabase.dart';

class DatabaseService {
  static final client = PostgrestClient(
    '${Env.supabaseUrl}/rest/v1',
    headers: {'apikey': '${Env.supabaseKey}'},
    schema: 'public',
  );

  static final sbClient = SupabaseClient(
    Env.supabaseUrl!,
    Env.supabaseKey!,
    schema: 'public',
  );
}
