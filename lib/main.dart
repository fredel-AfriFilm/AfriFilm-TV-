import 'package:flutter/material.dart';

void main() => runApp(const AfriFilmApp());

const yellow = Color(0xFFFFC61A);

class Film {
  final String title, cat;
  final Color c1, c2;
  const Film(this.title, this.cat, this.c1, this.c2);
}

const films = [
  Film('La Dernière Dot', 'Nollywood', Color(0xFF0D6B2A), Color(0xFFC98D00)),
  Film('Abidjan Nights', "Côte d'Ivoire", Color(0xFFB45309), Color(0xFF7F1D1D)),
  Film('Le Roi de Douala', 'Cameroun', Color(0xFF166534), Color(0xFFA16207)),
  Film('Mariage à Lagos', 'Nollywood', Color(0xFF7F1D1D), Color(0xFFC98D00)),
  Film('Cotonou Blues', 'Bénin', Color(0xFF14532D), Color(0xFFB91C1C)),
  Film('Le Griot', 'Cameroun', Color(0xFF1E3A8A), Color(0xFF15803D)),
  Film('Maquis Story', "Côte d'Ivoire", Color(0xFF9A3412), Color(0xFF166534)),
  Film('Accra Hearts', 'Ghana', Color(0xFF854D0E), Color(0xFF991B1B)),
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
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: const Color(0xFF111111),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [f.c1, f.c2]),
              ),
              child: const Center(child: Icon(Icons.play_arrow, size: 64)),
            ),
            const SizedBox(height: 14),
            Text(f.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('${f.cat} · Gratuit', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Lancer le film'),
                style: FilledButton.styleFrom(
                    backgroundColor: yellow, foregroundColor: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('Espace publicité',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
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
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [f.c1, f.c2]),
              ),
              child: Text(f.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16, height: 1.05)),
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
              onTap: () => open(films[0]),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                height: 260,
                padding: const EdgeInsets.all(18),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D6B2A), Color(0xFF7A5A00), Color(0xFF6B0F0B)],
                  ),
                ),
                child: const Text('La Dernière Dot',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
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
