import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../../services/settings_provider.dart';

/// Настройки детекции автомобилей через микрофон.
///
/// Раскрывающийся тайл: главный переключатель включения/выключения + внутри —
/// слайдер чувствительности и переключатели типов предупреждений
/// (звук / вибрация / голос).
///
/// Реальная логика захвата микрофона и анализа живёт в [CarDetectionService],
/// а выдача предупреждений — в [CarAlertService]; здесь только настройки.
class CarDetectionSettingsTile extends StatelessWidget {
  const CarDetectionSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return ExpansionTile(
      leading: const Icon(Icons.directions_car),
      title: Text(l10n.carDetectionTitle),
      subtitle: Text(settings.carDetectionEnabled
          ? l10n.carDetectionEnabled
          : l10n.carDetectionDisabled),
      trailing: Switch(
        value: settings.carDetectionEnabled,
        onChanged: (value) => settings.setCarDetectionEnabled(value),
      ),
      children: [
        // --- Чувствительность ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.carDetectionSensitivity),
                    Slider(
                      value: settings.carDetectionSensitivity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label:
                          '${(settings.carDetectionSensitivity * 100).round()}%',
                      onChanged: (value) =>
                          settings.setCarDetectionSensitivity(value),
                    ),
                    Text(
                      l10n.carDetectionSensitivityHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // --- Типы предупреждений ---
        SwitchListTile(
          secondary: const Icon(Icons.volume_up),
          title: Text(l10n.carAlertSound),
          subtitle: Text(l10n.carAlertSoundSubtitle),
          value: settings.carAlertSound,
          onChanged: (value) => settings.setCarAlertSound(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.vibration),
          title: Text(l10n.carAlertVibration),
          subtitle: Text(l10n.carAlertVibrationSubtitle),
          value: settings.carAlertVibration,
          onChanged: (value) => settings.setCarAlertVibration(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.record_voice_over),
          title: Text(l10n.carAlertVoice),
          subtitle: Text(l10n.carAlertVoiceSubtitle),
          value: settings.carAlertVoice,
          onChanged: (value) => settings.setCarAlertVoice(value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.carDetectionPrivacyNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
