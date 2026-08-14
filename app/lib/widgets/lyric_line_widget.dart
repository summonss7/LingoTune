import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lyric_line.dart';
import '../services/settings_provider.dart';

class LyricLineWidget extends StatelessWidget {
  final LyricLine line;
  final bool isCurrent;
  final bool isNext;
  final bool isEditMode;
  final VoidCallback? onTap;

  const LyricLineWidget({
    super.key,
    required this.line,
    required this.isCurrent,
    this.isNext = false,
    this.isEditMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final lyricsFontSize = settingsProvider.lyricsFontSize;
        final translationFontSize = settingsProvider.translationFontSize;
        final transcriptFontSize = settingsProvider.transcriptFontSize;
        final lyricsBold = settingsProvider.lyricsBold;
        final translationBold = settingsProvider.translationBold;
        final transcriptBold = settingsProvider.transcriptBold;
        final fontFamily = settingsProvider.fontFamily.isEmpty ? null : settingsProvider.fontFamily;
        // Пользовательская подсветка строк цветами. Когда useCustomLyricColors
        // включён и цвет задан (!= null), он перекрывает цвет темы для оригинала
        // и/или перевода (с прозрачностью для неактивных строк). null = «авто».
        final origCustom =
            settingsProvider.useCustomLyricColors ? settingsProvider.originalTextColor : null;
        final transCustom =
            settingsProvider.useCustomLyricColors ? settingsProvider.translationTextColor : null;

        return InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isEditMode
                  ? Colors.orange.withOpacity(0.2)
                  : isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer
                      : isNext
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              border: isEditMode
                  ? Border.all(color: Colors.orange, width: 1)
                  : null,
            ),
             padding: const EdgeInsets.symmetric(
               vertical: 8.0,
               horizontal: 12.0,
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  if (settingsProvider.showTranslationFirst && line.translatedText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        line.translatedText!,
                        style: TextStyle(
                          fontSize: isCurrent ? settingsProvider.translationFontSize + 2 : isNext ? settingsProvider.translationFontSize : settingsProvider.translationFontSize - 2,
                          fontWeight: translationBold ? FontWeight.bold : FontWeight.normal,
                          fontFamily: fontFamily,
                          color: transCustom != null
                              ? transCustom.withOpacity(isCurrent ? 1.0 : isNext ? 0.75 : 0.65)
                              : isCurrent
                                  ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                                  : isNext
                                      ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5)
                                      : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Text(
                    line.text,
                    style: TextStyle(
                      fontSize: isCurrent ? lyricsFontSize + 4 : isNext ? lyricsFontSize + 2 : lyricsFontSize,
                      fontWeight: (lyricsBold && isCurrent) ? FontWeight.bold :
                                   (lyricsBold && isNext) ? FontWeight.w500 :
                                   isCurrent ? FontWeight.bold :
                                   isNext ? FontWeight.w500 :
                                   lyricsBold ? FontWeight.bold : FontWeight.normal,
                      fontFamily: fontFamily,
                      color: isEditMode
                          ? Colors.orange[900]
                          : origCustom != null
                              ? origCustom.withOpacity(isCurrent ? 1.0 : isNext ? 0.75 : 0.65)
                              : isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : isNext
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                                      : Colors.black87,
                    ),
                  ),
                  if (!settingsProvider.showTranslationFirst && line.translatedText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        line.translatedText!,
                        style: TextStyle(
                          fontSize: isCurrent ? settingsProvider.translationFontSize + 2 : isNext ? settingsProvider.translationFontSize : settingsProvider.translationFontSize - 2,
                          fontWeight: translationBold ? FontWeight.bold : FontWeight.normal,
                          fontFamily: fontFamily,
                          color: transCustom != null
                              ? transCustom.withOpacity(isCurrent ? 1.0 : isNext ? 0.75 : 0.65)
                              : isCurrent
                                  ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                                  : isNext
                                      ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5)
                                      : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (settingsProvider.showTranscript && line.transcript != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 2.0),
                     child: Text(
                       line.transcript!,
                       style: TextStyle(
                         fontSize: transcriptFontSize - 2,
                         fontWeight: transcriptBold ? FontWeight.bold : FontWeight.normal,
                         fontFamily: fontFamily,
                         color: Colors.blue[600],
                         fontStyle: FontStyle.italic,
                       ),
                     ),
                   ),
                if (isEditMode)
                   Padding(
                     padding: const EdgeInsets.only(top: 2.0),
                     child: Text(
                       _formatTimestamp(line.startTime),
                       style: TextStyle(
                         fontSize: lyricsFontSize - 3,
                         color: Colors.orange[700],
                       ),
                     ),
                   ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(double seconds) {
    final minutes = (seconds ~/ 60).toInt();
    final secs = (seconds % 60).toInt();
    final millis = ((seconds % 1) * 100).toInt();
    return '$minutes:${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
  }
}
