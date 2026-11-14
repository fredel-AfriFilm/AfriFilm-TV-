import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() => runApp(const AfriFilmApp());

const yellow = Color(0xFFFFC61A);

class Film {
  final String title, cat, lang;
  final Color c1, c2;
  final String? videoId;
  const Film(this.title, this.cat, this.lang, this.c1, this.c2, [this.videoId]);
}

const films = [
  Film('Classe à Part', 'Cameroun', 'Français', Color(0xFF166534), Color(0xFFA16207), 'jZM2SsVfmxw'),
  Film('La Dernière Dot', 'Nollywood', 'Anglais', Color(0xFF0D6B2A), Color(0xFFC98D00)),
  Film('Abidjan Nights', "Côte d'Ivoire", 'Français', Color(0xFFB45309), Color(0xFF7F1D1D)),
  Film('Le Roi de Douala', 'Cameroun', 'Français', Color(0xFF14532D), Color(0xFFA16207)),
  Film('Mariage à Lagos', 'Nollywood', 'Anglais', Color(0xFF7F1D1D), Color(0xFFC98D00)),
  Film('Cotonou Blues', 'Bénin', 'Français', Color(0xFF14532D), Color(0xFFB91C1C)),
  Film('Le Griot', 'Cameroun', 'Français', Color(0xFF1E3A8A), Color(0xFF15803D)),
  Film('Accra Hearts', 'Ghana', 'Anglais', Color(0xFF854D0E), Color(0xFF991B1B)),
];

const cats = ['Tous', 'Nollywood', "Côte d'Ivoire", 'Cameroun', 'Bénin', 'Ghana'];

class AfriFilmApp extends StatelessWidget {
  const AfriFilmApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AfriFilm TV',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorScheme: const ColorScheme.dark(primary: yellow),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String cur = 'Tous';

  void open(Film f) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WatchPage(film: f)),
    );
  }

  Widget poster(Film f) {
    return GestureDetector(
      onTap: () => open(f),
      child: SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 184,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [f.c1, f.c2]),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(f.lang,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(f.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16, height: 1.05)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(f.cat, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget row(String t, List<Film> l) {
    if (l.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(t,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        SizedBox(
          height: 224,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: l.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => poster(l[i]),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hero = films[0];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.movie, color: yellow, size: 32),
                  SizedBox(width: 10),
                  Text('AfriFilm TV',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Spacer(),
                  Icon(Icons.search),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in cats)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: cur == c,
                        selectedColor: yellow,
                        labelStyle: TextStyle(
                            color: cur == c ? Colors.black : Colors.white),
                        onSelected: (_) => setState(() => cur = c),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => open(hero),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                height: 260,
                padding: const EdgeInsets.all(18),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [hero.c1, const Color(0xFF7A5A00), const Color(0xFF6B0F0B)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('À la une',
                        style: TextStyle(
                            color: yellow, fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(hero.title,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            if (cur == 'Tous') ...[
              row('Populaires en ce moment', films.take(6).toList()),
              row('Nouveautés', films.skip(3).toList()),
            ] else
              row(cur, films.where((f) => f.cat == cur).toList()),
          ],
        ),
      ),
    );
  }
}

class WatchPage extends StatefulWidget {
  final Film film;
  const WatchPage({super.key, required this.film});
  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  YoutubePlayerController? c;

  @override
  void initState() {
    super.initState();
    final id = widget.film.videoId;
    if (id != null) {
      c = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: true,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );
    }
  }

  @override
  void dispose() {
    c?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.film;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        title: Text(f.title),
      ),
      body: ListView(
        children: [
          if (c != null)
            YoutubePlayer(controller: c!, aspectRatio: 16 / 9)
          else
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [f.c1, f.c2]),
              ),
              child: const Center(
                child: Text('Bientôt disponible',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${f.cat} · ${f.lang} · Gratuit',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Espace publicité',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
