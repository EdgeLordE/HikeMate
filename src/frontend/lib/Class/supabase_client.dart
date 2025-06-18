import 'package:supabase/supabase.dart';

/// Supabase Client für die HikeMate App
/// 
/// Diese Datei konfiguriert die Verbindung zur Supabase-Datenbank,
/// die als Backend-as-a-Service für zusätzliche Funktionen verwendet wird.
/// Dieser Client wird aber nur auf den Pages genützt die für die Zukunft sind
/// und nicht für die aktuelle Version der App. Darum haben wir manche sachen (SOS nicht mit swagger gemacht)
final supabase = SupabaseClient(
  'https://cyzdfdweghhrlquxwaxl.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0',
);
