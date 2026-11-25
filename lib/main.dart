import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'films.dart';

void main() => runApp(const AfriFilmApp());

const accent = Color(0xFF7C5CF6);
const bgColor = Color(0xFF050505);
const cardBg = Color(0xFF14141A);
const discoverCats = [
  'Tous',
  'Cameroun',
  'Nollywood',
  "Côte d'Ivoire",
  'Bénin',
  'Ghana',
];

Future<Set<String>> loadFavs() async {
  final p = await SharedPreferences.getInstance();
  return (p.getStringList('favs') ?? <String>[]).toSet();
}

Future<void> saveFavs(Set<String> s) async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList('favs', s.toList());
}

class Prog {
  final String title;
  final int pos, dur;
  const Prog(this.title, this.pos, this.dur);
  double get ratio => dur <= 0 ? 0.0 : (pos / dur).clamp(0.0, 1.0);
}

Future<List<Prog>> loadProgress() async {
  final p = await SharedPreferences.getInstance();
  final raw = p.getStringList('prog') ?? <String>[];
  final out = <Prog>[];
  for (final s in raw) {
    final parts = s.split('|');
    if (parts.length != 3) continue;
    final pos = int.tryParse(parts[1]);
    final dur = int.tryParse(parts[2]);
    if (pos == null || dur == null) continue;
    out.add(Prog(parts[0], pos, dur));
  }
  return out;
}

Future<void> saveProgress(String title, int pos, int dur) async {
  final list = await loadProgress();
  list.removeWhere((e) => e.title == title);
  if (pos >= 10 && dur > 0 && pos < dur * 0.95) {
    list.insert(0, Prog(title, pos, dur));
  }
  final p = await SharedPreferences.getInstance();
  await p.setStringList(
    'prog',
    list.take(12).map((e) => '${e.title}|${e.pos}|${e.dur}').toList(),
  );
}

Future<int> savedPos(String title) async {
  final list = await loadProgress();
  for (final e in list) {
    if (e.title == title) return e.pos;
  }
  return 0;
}

String fmtDuree(int m) {
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$m min';
  if (r == 0) return '$h h';
  return '$h h ${r.toString().padLeft(2, '0')}';
}

String fmtMo(double mo) {
  if (mo >= 1000) {
    final go = mo / 1000;
    return '${go.toStringAsFixed(1).replaceAll('.', ',')} Go';
  }
  final r = (mo / 10).round() * 10;
  return '$r Mo';
}

Widget artwork(Film f, {required double height, double radius = 14}) {
  final fallback = Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [f.c1, f.c2],
      ),
    ),
  );
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (f.thumb != null)
            Image.network(
              f.thumb!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
          else
            fallback,
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class PosterCard extends StatelessWidget {
  final Film film;
  final VoidCallback onTap;
  final double? ratio;
  const PosterCard(
      {super.key, required this.film, required this.onTap, this.ratio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 184,
              child: Stack(
                children: [
                  artwork(film, height: 184),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(film.lang,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (ratio != null)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          color: accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(film.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(film.cat, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class PosterRow extends StatelessWidget {
  final String title;
  final List<Film> list;
  final void Function(Film) onOpen;
  final Map<String, double>? ratios;
  const PosterRow({
    super.key,
    required this.title,
    required this.list,
    required this.onOpen,
    this.ratios,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        SizedBox(
          height: 252,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => PosterCard(
              film: list[i],
              onTap: () => onOpen(list[i]),
              ratio: ratios?[list[i].title],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
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
        scaffoldBackgroundColor: bgColor,
        colorScheme: const ColorScheme.dark(primary: accent),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  String cat = 'Tous';
  Set<String> favs = {};
  List<Prog> prog = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final f = await loadFavs();
    final p = await loadProgress();
    if (mounted) {
      setState(() {
        favs = f;
        prog = p;
      });
    }
  }

  Future<void> open(Film f) async {
    final pos = await savedPos(f.title);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WatchPage(film: f, startAt: pos)),
    );
    await refresh();
  }

  Future<void> openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchPage(onOpen: open)),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Image.asset('assets/splash_logo.png', width: 42, height: 42),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: openSearch,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text('Rechercher un film…',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Icon(Icons.search),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget hero(Film h) {
    return GestureDetector(
      onTap: () => open(h),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        height: 220,
        child: Stack(
          children: [
            artwork(h, height: 220, radius: 20),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('À la une',
                      style: TextStyle(
                          color: accent, fontWeight: FontWeight.w800, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(h.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeTab() {
    final real = films.where((f) => f.cat != 'Test').toList();
    final byTitle = {for (final f in films) f.title: f};
    final cont = <Film>[];
    final ratios = <String, double>{};
    for (final p in prog) {
      final f = byTitle[p.title];
      if (f != null) {
        cont.add(f);
        ratios[f.title] = p.ratio;
      }
    }
    final h = real.isEmpty ? films[0] : real[0];
    return ListView(
      children: [
        searchBar(),
        if (cont.isNotEmpty)
          PosterRow(
            title: 'Continuer de regarder',
            list: cont,
            onOpen: open,
            ratios: ratios,
          ),
        hero(h),
        PosterRow(
            title: 'Populaires en ce moment',
            list: real.take(6).toList(),
            onOpen: open),
        PosterRow(
            title: 'Nouveautés',
            list: real.reversed.take(6).toList(),
            onOpen: open),
        for (final c in discoverCats.skip(1))
          PosterRow(
            title: c,
            list: real.where((f) => f.cat == c).toList(),
            onOpen: open,
          ),
      ],
    );
  }

  Widget grid(List<Film> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucun film ici pour le moment.',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: [
          for (final f in list) PosterCard(film: f, onTap: () => open(f)),
        ],
      ),
    );
  }

  Widget discoverTab() {
    final real = films.where((f) => f.cat != 'Test').toList();
    final list = cat == 'Tous' ? real : real.where((f) => f.cat == cat).toList();
    return ListView(
      children: [
        searchBar(),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in discoverCats)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: cat == c,
                    selectedColor: accent,
                    labelStyle: TextStyle(
                        color: cat == c ? Colors.white : Colors.white70),
                    onSelected: (_) => setState(() => cat = c),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        grid(list),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget listTab() {
    final mine = films.where((f) => favs.contains(f.title)).toList();
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Text('Ma liste',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        if (mine.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ta liste est vide. Ouvre un film et touche « Ma liste ».',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          grid(mine),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [homeTab(), discoverTab(), listTab()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B0B10),
        indicatorColor: accent.withOpacity(0.35),
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Découvrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Ma liste',
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final void Function(Film) onOpen;
  const SearchPage({super.key, required this.onOpen});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final query = q.trim().toLowerCase();
    final results = query.isEmpty
        ? <Film>[]
        : films.where((f) => f.title.toLowerCase().contains(query)).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => q = v),
          decoration: const InputDecoration(
            hintText: 'Rechercher un film…',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView(
        children: [
          if (query.isNotEmpty && results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun film trouvé.',
                  style: TextStyle(color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final f in results)
                  PosterCard(film: f, onTap: () => widget.onOpen(f)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WatchPage extends StatefulWidget {
  final Film film;
  final int startAt;
  const WatchPage({super.key, required this.film, this.startAt = 0});
  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  YoutubePlayerController? c;
  bool fav = false;
  PlayerState? lastState;
  Timer? saver;

  @override
  void initState() {
    super.initState();
    final id = widget.film.videoId;
    if (id != null) {
      c = YoutubePlayerController(
        initialVideoId: id,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          enableCaption: false,
          showLiveFullscreenButton: false,
          startAt: widget.startAt,
        ),
      );
      c!.addListener(killCaptions);
      saver = Timer.periodic(const Duration(seconds: 5), (_) {
        final ctl = c;
        if (ctl != null && ctl.value.playerState == PlayerState.playing) {
          saveNow();
        }
      });
    }
    loadFavs().then((s) {
      if (mounted) setState(() => fav = s.contains(widget.film.title));
    });
  }

  void saveNow() {
    final ctl = c;
    if (ctl == null) return;
    final pos = ctl.value.position.inSeconds;
    var dur = ctl.metadata.duration.inSeconds;
    if (dur <= 0) dur = (widget.film.minutes ?? 0) * 60;
    if (dur <= 0) return;
    saveProgress(widget.film.title, pos, dur);
  }

  void killCaptions() {
    final ctl = c;
    if (ctl == null) return;
    final st = ctl.value.playerState;
    if (st == lastState) return;
    lastState = st;
    if (ctl.value.isReady && st == PlayerState.playing) {
      ctl.value.webViewController?.evaluateJavascript(
        source:
            "try{player.unloadModule('captions');player.unloadModule('cc');}catch(e){}",
      );
    }
  }

  @override
  void dispose() {
    saver?.cancel();
    saveNow();
    c?.removeListener(killCaptions);
    c?.dispose();
    super.dispose();
  }

  void seek(int sec) {
    final ctl = c;
    if (ctl == null) return;
    final pos = ctl.value.position + Duration(seconds: sec);
    ctl.seekTo(pos < Duration.zero ? Duration.zero : pos);
  }

  Future<void> openOther(Film x) async {
    final pos = await savedPos(x.title);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WatchPage(film: x, startAt: pos)),
    );
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
      color: cardBg,
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
                backgroundColor: accent, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget seekButton(IconData icon, int sec) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: () => seek(sec),
      ),
    );
  }

  Widget withSeek(Widget player, bool visible) {
    return Stack(
      children: [
        player,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(-0.55, -0.1),
                    child: seekButton(Icons.replay_10, -10),
                  ),
                  Align(
                    alignment: const Alignment(0.55, -0.1),
                    child: seekButton(Icons.forward_10, 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget dataBox(Film f) {
    final m = f.minutes;
    if (m == null) return const SizedBox.shrink();
    Widget line(String label, double ratePerMin) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey)),
            ),
            Text('≈ ${fmtMo(m * ratePerMin)}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Internet utilisé · durée ${fmtDuree(m)}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          line('Qualité basse (144p)', 70 / 60),
          line('Qualité normale (360p)', 5),
          line('Qualité HD (720p)', 1000 / 60),
          const SizedBox(height: 8),
          const Text(
            'Estimation : la taille réelle dépend de la qualité choisie par YouTube.',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget page(Widget? player) {
    final f = widget.film;
    final others =
        films.where((x) => x.title != f.title && x.cat != 'Test').toList();
    final episodes = f.serie == null
        ? <Film>[]
        : (films.where((x) => x.serie == f.serie).toList()
          ..sort((a, b) => (a.ep ?? 0).compareTo(b.ep ?? 0)));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(f.title),
      ),
      body: ListView(
        children: [
          if (player != null)
            ValueListenableBuilder<YoutubePlayerValue>(
              valueListenable: c!,
              builder: (context, value, _) {
                if (value.errorCode != 0) return errorBox();
                return withSeek(player, value.isControlsVisible);
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
                dataBox(f),
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
                if (episodes.length > 1) ...[
                  const SizedBox(height: 20),
                  Text('Épisodes · ${f.serie}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  for (final e in episodes)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      selected: e.title == f.title,
                      selectedColor: accent,
                      leading: Text(e.ep == null ? 'Ép.' : 'Ép. ${e.ep}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      title: Text(e.title),
                      onTap: () => openOther(e),
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
                      color: cardBg, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Espace publicité',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
          ),
          PosterRow(title: 'Autres films', list: others, onOpen: openOther),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (c == null) return page(null);
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: c!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: accent,
      ),
      builder: (context, player) => page(player),
    );
  }
}
