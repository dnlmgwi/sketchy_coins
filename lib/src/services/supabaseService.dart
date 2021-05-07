import 'package:sketchy_coins/src/services/databaseService.dart';
import 'package:supabase/supabase.dart';

class SupabaseService {
  static final client =
      SupabaseClient(DatabaseService.supabaseUrl, DatabaseService.supabaseKey);
}
