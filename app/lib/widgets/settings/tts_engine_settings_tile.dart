import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../../services/settings_provider.dart';
import '../../utils/tts_engine_helper.dart';

/// Settings tile that lets the user pick which system TTS engine is used for
/// speaking translations in study mode. Offers an "Auto" option (prefers
/// Google TTS, the most reliable engine across ROMs) plus every engine the
/// system reports via [FlutterTts.getEngines].
///
/// This exists because on Chinese ROMs (e.g. Realme/Oppo ColorOS) the default
/// engine ("Heytap") often misreports language availability or silently fails
/// to synthesize, so letting the user force Google TTS fixes study-mode speech.
class TtsEngineSettingsTile extends StatefulWidget {
  const TtsEngineSettingsTile({super.key});

  @override
  State<TtsEngineSettingsTile> createState() => _TtsEngineSettingsTileState();
}

class _TtsEngineSettingsTileState extends State<TtsEngineSettingsTile> {
  List<TtsEngineInfo> _engines = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEngines();
  }

  Future<void> _loadEngines() async {
    final engines = await enumerateTtsEngines();
    if (mounted) {
      setState(() {
        _engines = engines;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final current = settings.ttsEngine; // '' = Auto

    final Widget trailing;
    if (_loading) {
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (_engines.isEmpty) {
      // No engines visible — likely missing the <queries> declaration or a ROM
      // with no installed TTS engine. Show a hint instead of an empty dropdown.
      trailing = const Icon(Icons.warning_amber_outlined, color: Colors.orange);
    } else {
      trailing = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: DropdownButton<String>(
          value: _engines.any((e) => e.name == current) ? current : '',
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(
                l10n.ttsEngineAuto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ..._engines.map(
              (e) => DropdownMenuItem(
                value: e.name,
                child: Text(
                  e.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) async {
            if (value == null) return;
            await settings.setTtsEngine(value);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.ttsEngineReloadHint),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.record_voice_over),
      title: Text(l10n.ttsEngine),
      subtitle: Text(
        _engines.isEmpty && !_loading
            ? l10n.ttsEngineSubtitle
            : (current.isEmpty ? l10n.ttsEngineAuto : engineLabel(current)),
      ),
      trailing: trailing,
    );
  }
}
