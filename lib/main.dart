import 'package:emotion_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  await Supabase.initialize(
    url: "https://mftyadvkuddrtfrodgmd.supabase.co",
    anonKey: "sb_publishable_5DHv6pItqNPUqQr2kQjRaA_UEEVzx_L",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}