import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const AniStreamApp());

class VideoItem {
  final String title, channel, views, thumb, url;
  const VideoItem(this.title, this.channel, this.views, this.thumb, this.url);
}

const sampleUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

final List<VideoItem> dummyVideos = List.generate(
  12,
  (i) => VideoItem(
    'Judul Video Contoh #${i + 1}',
    'Kreator ${i + 1}',
    '${(i + 1) * 12}K x ditonton',
    'https://picsum.photos/seed/anistream$i/480/270',
    sampleUrl,
  ),
);

class AniStreamApp extends StatelessWidget {
  const AniStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const tabs = ['Beranda', 'Anime', 'Game', 'Musik'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AniStream',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final t in tabs) Tab(text: t)],
          ),
        ),
        body: TabBarView(
          children: [for (final _ in tabs) const VideoGrid()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.explore), label: 'Jelajah'),
            NavigationDestination(
                icon: Icon(Icons.subscriptions), label: 'Langganan'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Saya'),
          ],
        ),
      ),
    );
  }
}

class VideoGrid extends StatelessWidget {
  const VideoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemCount: dummyVideos.length,
      itemBuilder: (_, i) => VideoCard(video: dummyVideos[i]),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoItem video;
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerPage(video: video)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                video.thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.black12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(video.channel,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(video.views,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final VideoItem video;
  const PlayerPage({super.key, required this.video});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final VideoPlayerController _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
      ..initialize().then((_) {
        setState(() {});
        _c.play();
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: ListView(
        children: [
          if (_c.value.isInitialized)
            AspectRatio(
              aspectRatio: _c.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_c),
                  VideoProgressIndicator(_c, allowScrubbing: true),
                ],
              ),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 36,
                icon: Icon(
                    _c.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => setState(() =>
                    _c.value.isPlaying ? _c.pause() : _c.play()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.video.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${widget.video.channel} • ${widget.video.views}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
