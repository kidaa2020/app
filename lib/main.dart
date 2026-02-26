import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/local/hive_database.dart';
import 'app.dart';

import 'package:healthbuddy/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await NotificationService.init();
  await NotificationService.requestPermissions();

  // Schedule default reminders
  await NotificationService.scheduleDailyReminder(
    id: 1,
    title: '¡Hora de desayunar!',
    body: 'Registra tu primera comida del día con HealthBuddy 🍏',
    hour: 9,
    minute: 0,
  );

  await NotificationService.scheduleDailyReminder(
    id: 2,
    title: '¿Listo para entrenar?',
    body: 'Mantén tu racha activa y gana monedas para tu mascota 🪙',
    hour: 18,
    minute: 30,
  );

  runApp(
    const ProviderScope(
      child: HealthBuddyApp(),
    ),
  );
}
