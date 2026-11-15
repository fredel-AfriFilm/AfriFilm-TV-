import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'films.dart';

void main() => runApp(const AfriFilmApp());

const yellow = Color(0xFFFFC61A);

Future<Set<String>> loadFavs() async {
  final p = await SharedPreferences.getInstance();
  return (p.getStringList('favs') ?? <String>[]).toSet();
}

Future<void> saveFavs(Set<String> s) async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList('favs', s.toList());
}

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
  Set<String> favs = {};

  @override
  void initState() {
    super.initState();
    refreshFavs();
  }

  Future<void> refreshFavs() async {
    final s = await loadFavs();
    if (mounted) setState(() => favs = s);
  }

  Future<void> open(Film f) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WatchPage(film: f)),
    );
    await refreshFavs();
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
    final myList = films.where((f) => favs.contains(f.title)).toList();
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
            ] else if (cur == 'Ma liste') ...[
              if (myList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ta liste est vide. Ouvre un film et touche « Ma liste ».',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                row('Ma liste', myList),
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
  bool fav = false;

  @override
  void initState() {
    super.initState();
    final id = widget.film.videoId;
    if (id != null) {
      c = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(autoPlay: true),
      );
    }
    loadFavs().then((s) {
      if (mounted) setState(() => fav = s.contains(widget.film.title));
    });
  }

  @override
  void dispose() {
    c?.dispose();
    super.dispose();
  }

  Future<void> toggleFav() async {
    final s = await loadFavs();
    final t = widget.film.title;
    if (s.contains(t)) {
      s.remove(t);
    } else {
      s.add(t);
    }
    await saveFavs(s);
    if (mounted) setState(() => fav = s.contains(t));
  }

  Future<void> shareFilm() async {
    final text = Uri.encodeComponent(
        'Regarde « ${widget.film.title} » sur AfriFilm TV !');
    await launchUrl(
      Uri.parse('https://wa.me/?text=$text'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> openYoutube() async {
    final id = widget.film.videoId;
    if (id == null) return;
    await launchUrl(
      Uri.parse('https://www.youtube.com/watch?v=$id'),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget errorBox() {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFF141414),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cette vidéo ne peut pas se lire ici pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: openYoutube,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Regarder la vidéo'),
            style: FilledButton.styleFrom(
                backgroundColor: yellow, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
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
            ValueListenableBuilder<YoutubePlayerValue>(
              valueListenable: c!,
              builder: (context, value, _) {
                if (value.errorCode != 0) return errorBox();
                return YoutubePlayer(
                  controller: c!,
                  showVideoProgressIndicator: true,
                );
              },
            )
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: toggleFav,
                        icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                        label: Text(fav ? 'Dans ma liste' : 'Ma liste'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: shareFilm,
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                    ),
                  ],
                ),
                if (f.videoId != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: openYoutube,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ouvrir dans YouTube'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Résumé',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(f.synopsis ?? 'Résumé bientôt disponible.',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
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
