import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class KeysValuesConfig {
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String get supabaseServiceRoleKey {
    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  }

  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }
}
