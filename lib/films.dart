import 'package:flutter/material.dart';

class Film {
  final String title, cat, lang;
  final Color c1, c2;
  final String? videoId;
  final String? synopsis;
  const Film(this.title, this.cat, this.lang, this.c1, this.c2,
      [this.videoId, this.synopsis]);
}

const films = [
  Film('Test lecteur', 'Test', 'Anglais', Color(0xFF1E3A8A), Color(0xFF15803D), 'dQw4w9WgXcQ'),
  Film('Papa pour rien', 'Cameroun', 'Français', Color(0xFF166534), Color(0xFFA16207), 't6wCp0pQ26k'),
  Film('Classe à Part', 'Cameroun', 'Français', Color(0xFF14532D), Color(0xFFA16207), 'jZM2SsVfmxw'),
  Film('La Dernière Dot', 'Nollywood', 'Anglais', Color(0xFF0D6B2A), Color(0xFFC98D00)),
  Film('Abidjan Nights', "Côte d'Ivoire", 'Français', Color(0xFFB45309), Color(0xFF7F1D1D)),
  Film('Le Roi de Douala', 'Cameroun', 'Français', Color(0xFF14532D), Color(0xFFA16207)),
  Film('Mariage à Lagos', 'Nollywood', 'Anglais', Color(0xFF7F1D1D), Color(0xFFC98D00)),
  Film('Cotonou Blues', 'Bénin', 'Français', Color(0xFF14532D), Color(0xFFB91C1C)),
];

const cats = [
  'Tous',
  'Ma liste',
  'Nollywood',
  "Côte d'Ivoire",
  'Cameroun',
  'Bénin',
  'Ghana',
];
