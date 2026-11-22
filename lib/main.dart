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
  const PosterCard({super.key, required this.film, required this.onTap});

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
  const PosterRow(
      {super.key, required this.title, required this.list, required this.onOpen});

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
            itemBuilder: (_, i) =>
                PosterCard(film: list[i], onTap: () => onOpen(list[i])),
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
  bool searching = false;
  String q = '';

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

  Widget header() {
    if (searching) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => q = v),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un film',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                searching = false;
                q = '';
              }),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.movie, color: yellow, size: 32),
          const SizedBox(width: 10),
          const Text('AfriFilm TV',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => searching = true),
          ),
        ],
      ),
    );
  }

  Widget chips() {
    return SizedBox(
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
                labelStyle:
                    TextStyle(color: cur == c ? Colors.black : Colors.white),
                onSelected: (_) => setState(() => cur = c),
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
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 18),
        height: 260,
        child: Stack(
          children: [
            artwork(h, height: 260, radius: 20),
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
                          color: yellow, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(h.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> content() {
    final real = films.where((f) => f.cat != 'Test').toList();
    final h = real.isEmpty ? films[0] : real[0];
    final myList = films.where((f) => favs.contains(f.title)).toList();
    final out = <Widget>[hero(h)];
    if (cur == 'Tous') {
      out.add(PosterRow(
          title: 'Populaires en ce moment',
          list: real.take(6).toList(),
          onOpen: open));
      out.add(PosterRow(
          title: 'Nouveautés',
          list: real.reversed.take(6).toList(),
          onOpen: open));
    } else if (cur == 'Ma liste') {
      if (myList.isEmpty) {
        out.add(const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Ta liste est vide. Ouvre un film et touche « Ma liste ».',
            style: TextStyle(color: Colors.grey),
          ),
        ));
      } else {
        out.add(PosterRow(title: 'Ma liste', list: myList, onOpen: open));
      }
    } else {
      out.add(PosterRow(
          title: cur,
          list: films.where((f) => f.cat == cur).toList(),
          onOpen: open));
    }
    return out;
  }

  Widget searchResults() {
    final query = q.trim().toLowerCase();
    final results =
        films.where((f) => f.title.toLowerCase().contains(query)).toList();
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Aucun film trouvé.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: [
          for (final f in results) PosterCard(film: f, onTap: () => open(f)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showResults = searching && q.trim().isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            header(),
            if (!searching) chips(),
            if (showResults) searchResults() else ...content(),
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
  PlayerState? lastState;

  @override
  void initState() {
    super.initState();
    final id = widget.film.videoId;
    if (id != null) {
      c = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          enableCaption: false,
          showLiveFullscreenButton: false,
        ),
      );
      c!.addListener(killCaptions);
    }
    loadFavs().then((s) {
      if (mounted) setState(() => fav = s.contains(widget.film.title));
    });
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

  void openOther(Film x) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WatchPage(film: x)),
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
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: const Color(0xFF050505),
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
                      selectedColor: yellow,
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
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(10)),
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
      ),
      builder: (context, player) => page(player),
    );
  }
}
