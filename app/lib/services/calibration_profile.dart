import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/fft.dart';

/// Класс звука для эталонного профиля детекции.
///
/// Делиться на «машины» (триггерят alert) и «шумы» (не триггерят). Классификатор
/// [CarDetectionService] сравнивает входной кадр со всеми сохранёнными профилями
/// и берёт ближайший; если ближайший класс — машина, выдается alert.
enum ProfileClass {
  /// 🚗 Легковая машина близко (5-15 м). Сильный НЧ-гул, низкий центроид.
  carClose,

  /// 🚙 Легковая машина далеко (30-50 м). Тот же спектр, но тише.
  carFar,

  /// 🚛 Грузовик/автобус. Очень низкий фундаментальный тон (~60 Гц).
  carTruck,

  /// 🏍 Мотоцикл. Более высокий центроид, тональный.
  carMotorcycle,

  /// 🌬 Ветер в микрофон. Высокий flatness (равномерный шум).
  wind,

  /// 👟 Шаги при беге. Периодические широкополосные всплески.
  steps,

  /// 🗣 Голоса/речь. Высокий центроид (форманты 300-3000 Гц).
  voice,

  /// 🛣 Фоновый шум улицы. Низко-уровневая смесь.
  street,

  /// 🎵 Музыка, просачивающаяся из наушников. Регулярный спектр.
  music,

  /// ❓ Прочее.
  other,
}

/// Расширение над [ProfileClass]: относится ли класс к машинам (триггер alert).
extension ProfileClassX on ProfileClass {
  /// Классы, относящиеся к машинам (триггерят alert детектора).
  bool get isCar => const [
        ProfileClass.carClose,
        ProfileClass.carFar,
        ProfileClass.carTruck,
        ProfileClass.carMotorcycle,
      ].contains(this);

  /// Material-иконка для UI (список эталонов, dropdown).
  IconData get icon => switch (this) {
        ProfileClass.carClose => Icons.directions_car,
        ProfileClass.carFar => Icons.directions_car_filled,
        ProfileClass.carTruck => Icons.local_shipping,
        ProfileClass.carMotorcycle => Icons.motorcycle,
        ProfileClass.wind => Icons.air,
        ProfileClass.steps => Icons.directions_walk,
        ProfileClass.voice => Icons.record_voice_over,
        ProfileClass.street => Icons.add_road,
        ProfileClass.music => Icons.music_note,
        ProfileClass.other => Icons.help_outline,
      };

  /// Строковый идентификатор класса (для сериализации JSON).
  String get wireName => name;

  /// Парсинг класса из строки (из JSON). Бросает [ArgumentError] при ошибке.
  static ProfileClass fromWire(String wire) {
    return ProfileClass.values.firstWhere(
      (c) => c.name == wire,
      orElse: () => throw ArgumentError('Unknown ProfileClass: $wire'),
    );
  }
}

/// Эталонный профиль звука для классификации детектором машин.
///
/// Хранит среднее (μ) и стандартное отклонение (σ) для каждого из 6 спектральных
/// признаков, вычисленных по коллекции семплов [SpectrumFeatures]. Расстояние от
/// нового кадра до профиля — [distanceTo] — это Mahalanobis distance с
/// диагональной ковариацией (учитывает σ каждого признака, без кросс-корреляций).
///
/// Математика:
/// ```
///   z_i = (x_i - μ_i) / max(σ_i, ε)
///   d(x, profile) = sqrt( Σ_i z_i² )
/// ```
/// где ε = 1e-6 защищает от деления на ноль для признаков с нулевой вариацией.
@immutable
class CalibrationProfile {
  /// UUID v4 (или иной уникальный идентификатор).
  final String id;

  /// Пользовательское имя («Машина у дома», «Ветер в парке»).
  final String name;

  /// Класс звука (определяет, триггерит ли alert).
  final ProfileClass cls;

  /// Дата создания (ISO-8601).
  final DateTime createdAt;

  // Среднее и std для каждого признака (для Mahalanobis distance).
  final double lowMean, lowStd;
  final double midMean, midStd;
  final double highMean, highStd;
  final double centroidMean, centroidStd;
  final double flatnessMean, flatnessStd;
  final double rmsMean, rmsStd;

  const CalibrationProfile({
    required this.id,
    required this.name,
    required this.cls,
    required this.createdAt,
    required this.lowMean,
    required this.lowStd,
    required this.midMean,
    required this.midStd,
    required this.highMean,
    required this.highStd,
    required this.centroidMean,
    required this.centroidStd,
    required this.flatnessMean,
    required this.flatnessStd,
    required this.rmsMean,
    required this.rmsStd,
  });

  /// Mahalanobis distance от кадра [f] до этого профиля (диагональная
  /// ковариация). Меньше = больше похож. ε = 1e-6 для стабильности деления.
  ///
  /// Интерпретация:
  /// - d < 1  — кадр внутри 1σ профиля (очень похож)
  /// - d ≈ 2  — на границе 2σ (похоже)
  /// - d > 3  — сильно отличается
  /// - d > 4  — практически другой класс
  double distanceTo(SpectrumFeatures f) {
    const double eps = 1e-6;
    double z2(double x, double mean, double std) {
      final double s = std < eps ? eps : std;
      final double d = (x - mean) / s;
      return d * d;
    }

    final double sum = z2(f.lowBandEnergy, lowMean, lowStd) +
        z2(f.midBandEnergy, midMean, midStd) +
        z2(f.highBandEnergy, highMean, highStd) +
        z2(f.spectralCentroid, centroidMean, centroidStd) +
        z2(f.spectralFlatness, flatnessMean, flatnessStd) +
        z2(f.rms, rmsMean, rmsStd);
    return sqrt(sum);
  }

  /// Сериализация в JSON для SharedPreferences.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cls': cls.wireName,
        'createdAt': createdAt.toIso8601String(),
        'lowMean': lowMean,
        'lowStd': lowStd,
        'midMean': midMean,
        'midStd': midStd,
        'highMean': highMean,
        'highStd': highStd,
        'centroidMean': centroidMean,
        'centroidStd': centroidStd,
        'flatnessMean': flatnessMean,
        'flatnessStd': flatnessStd,
        'rmsMean': rmsMean,
        'rmsStd': rmsStd,
      };

  /// Десериализация из JSON. Возвращает `null` при критической ошибке формата
  /// (позволяет пропустить повреждённую запись вместо падения всего детектора).
  static CalibrationProfile? fromJson(Map<String, dynamic> j) {
    try {
      return CalibrationProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        cls: ProfileClassX.fromWire(j['cls'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        lowMean: (j['lowMean'] as num).toDouble(),
        lowStd: (j['lowStd'] as num).toDouble(),
        midMean: (j['midMean'] as num).toDouble(),
        midStd: (j['midStd'] as num).toDouble(),
        highMean: (j['highMean'] as num).toDouble(),
        highStd: (j['highStd'] as num).toDouble(),
        centroidMean: (j['centroidMean'] as num).toDouble(),
        centroidStd: (j['centroidStd'] as num).toDouble(),
        flatnessMean: (j['flatnessMean'] as num).toDouble(),
        flatnessStd: (j['flatnessStd'] as num).toDouble(),
        rmsMean: (j['rmsMean'] as num).toDouble(),
        rmsStd: (j['rmsStd'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Строит профиль из коллекции семплов (5 сек × 30 кадров/сек ≈ 150 семплов):
  /// вычисляет mean/std по каждому из 6 признаков.
  ///
  /// [id] — уникальный идентификатор; если не передан, генерируется новый UUID.
  factory CalibrationProfile.fromSamples(
    String name,
    ProfileClass cls,
    List<SpectrumFeatures> samples, {
    String? id,
    DateTime? createdAt,
  }) {
    assert(samples.isNotEmpty, 'samples must not be empty');

    double mean(List<double> xs) {
      double s = 0.0;
      for (final x in xs) {
        s += x;
      }
      return s / xs.length;
    }

    // Выборочное std (population, /N) — для >30 семплов разница с /N-1 невелика.
    double std(List<double> xs, double m) {
      if (xs.length < 2) return 0.0;
      double sumSq = 0.0;
      for (final x in xs) {
        final double d = x - m;
        sumSq += d * d;
      }
      return sqrt(sumSq / xs.length);
    }

    final List<double> low = samples.map((s) => s.lowBandEnergy).toList(growable: false);
    final List<double> mid = samples.map((s) => s.midBandEnergy).toList(growable: false);
    final List<double> high = samples.map((s) => s.highBandEnergy).toList(growable: false);
    final List<double> cent =
        samples.map((s) => s.spectralCentroid).toList(growable: false);
    final List<double> flat =
        samples.map((s) => s.spectralFlatness).toList(growable: false);
    final List<double> rms = samples.map((s) => s.rms).toList(growable: false);

    final double lowM = mean(low);
    final double midM = mean(mid);
    final double highM = mean(high);
    final double centM = mean(cent);
    final double flatM = mean(flat);
    final double rmsM = mean(rms);

    return CalibrationProfile(
      id: id ?? _generateId(),
      name: name,
      cls: cls,
      createdAt: createdAt ?? DateTime.now(),
      lowMean: lowM,
      lowStd: std(low, lowM),
      midMean: midM,
      midStd: std(mid, midM),
      highMean: highM,
      highStd: std(high, highM),
      centroidMean: centM,
      centroidStd: std(cent, centM),
      flatnessMean: flatM,
      flatnessStd: std(flat, flatM),
      rmsMean: rmsM,
      rmsStd: std(rms, rmsM),
    );
  }

  /// Простой генератор идентификатора без зависимости от uuid-пакета
  /// (для случаев, когда [fromSamples] вызывается без явного [id]).
  /// Формат: `p-<millis>-<random>`.
  static String _generateId() {
    final int t = DateTime.now().millisecondsSinceEpoch;
    final int r = Random().nextInt(0xFFFFFFFF);
    return 'p-$t-${r.toRadixString(16)}';
  }

  @override
  String toString() =>
      'CalibrationProfile($cls, name="$name", lowMean=$lowMean, rmsMean=$rmsMean)';
}
