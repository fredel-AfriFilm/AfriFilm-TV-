import 'package:flutter/material.dart';

class Film {
  final String title, cat, lang;
  final Color c1, c2;
  final String? videoId;
  final String? synopsis;
  final String? serie;
  final int? ep;
  const Film(this.title, this.cat, this.lang, this.c1, this.c2,
      {this.videoId, this.synopsis, this.serie, this.ep});

  String? get thumb => videoId == null
      ? null
      : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

// Pour une série, ajoute à chaque épisode : serie: 'Nom de la série', ep: 1
// (puis ep: 2, ep: 3...). Les autres épisodes s'affichent sous la vidéo.

const films = [
  Film('Ma patience', 'Cameroun', 'Français', Color(0xFF166534), Color(0xFFA16207), videoId: 'AB1cbaz5DnQ'),
  Film('Père Non Déterminé', 'Cameroun', 'Français', Color(0xFF14532D), Color(0xFFB91C1C), videoId: 'l3N6TsIn_xg'),
  Film('Addiction scandaleuse', 'Cameroun', 'Français', Color(0xFF7F1D1D), Color(0xFFC98D00), videoId: '-FwSkwj3GpY'),
  Film('Envie mortelle', 'Cameroun', 'Français', Color(0xFF1E3A8A), Color(0xFF15803D), videoId: 'X34sl0pKmIo'),
  Film("Le cœur d'Adzai", 'Cameroun', 'Français', Color(0xFF854D0E), Color(0xFF991B1B), videoId: 'qyNFg7m1phI'),
  Film('Clémence', 'Cameroun', 'Français', Color(0xFF115E59), Color(0xFFA16207), videoId: 'YVFbbXPK5Tg'),
  Film('Papa pour rien', 'Cameroun', 'Français', Color(0xFF166534), Color(0xFFA16207), videoId: 't6wCp0pQ26k'),
  Film('Classe à Part', 'Cameroun', 'Français', Color(0xFF14532D), Color(0xFFA16207), videoId: 'jZM2SsVfmxw'),
  Film('La Dernière Dot', 'Nollywood', 'Anglais', Color(0xFF0D6B2A), Color(0xFFC98D00)),
  Film('Abidjan Nights', "Côte d'Ivoire", 'Français', Color(0xFFB45309), Color(0xFF7F1D1D)),
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
