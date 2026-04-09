import 'package:flutter/material.dart';
import '../constants/generation_constants.dart';
import 'package:lingotune/l10n/app_localizations.dart';

class GenerationOptionsWidget extends StatefulWidget {
  final Function(List<String>) onLanguagesChanged;

  const GenerationOptionsWidget({
    super.key,
    required this.onLanguagesChanged,
  });

  @override
  State<GenerationOptionsWidget> createState() => _GenerationOptionsWidgetState();
}

class _GenerationOptionsWidgetState extends State<GenerationOptionsWidget> {
  final Set<String> _selectedLanguages = {};

  @override
  void initState() {
    super.initState();
    _selectedLanguages.addAll(GenerationConstants.defaultLanguages);
    widget.onLanguagesChanged(_selectedLanguages.toList());
  }

  void _toggleLanguage(String language) {
    setState(() {
      if (_selectedLanguages.contains(language)) {
        _selectedLanguages.remove(language);
      } else {
        _selectedLanguages.add(language);
      }
    });
    widget.onLanguagesChanged(_selectedLanguages.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.translate, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                l10n.selectLanguages,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                l10n.selectedLanguagesCountGen(_selectedLanguages.length),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        _buildLanguageSection(l10n.transcriptionSection, ['trans']),
        _buildLanguageSection(l10n.translationsSection, ['ru', 'ru_literal', 'en', 'de', 'es', 'fr', 'it', 'pt', 'zh', 'ar', 'uk']),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguageSection(String title, List<String> languages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languages.map((lang) {
              final isSelected = _selectedLanguages.contains(lang);
              final languageName = GenerationConstants.supportedLanguages[lang] ?? lang;

              return FilterChip(
                label: Text(languageName),
                selected: isSelected,
                onSelected: (_) => _toggleLanguage(lang),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
                avatar: isSelected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
