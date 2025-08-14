import 'package:flutter/material.dart';
import 'api/api_services.dart';
import 'anime_card.dart';

void main() => runApp(
  const MaterialApp(home: AnimeSingle(), debugShowCheckedModeBanner: false),
);

class AnimeSingle extends StatefulWidget {
  const AnimeSingle({super.key});

  @override
  State<AnimeSingle> createState() => _AnimeSingleState();
}

class _AnimeSingleState extends State<AnimeSingle> {
  Map? anime;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAnime();
  }

  Future<void> loadAnime() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Gunakan fungsi baru yang mengambil detail lengkap
      final data = await ApiService.fetchFirstAnimeWithDetail();

      setState(() {
        anime = data;
        isLoading = false;
      });

      if (data == null) {
        setState(() {
          errorMessage = 'Gagal memuat data anime';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 11, 27, 40),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Skibidinime',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Memuat anime...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadAnime,
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : anime == null
          ? const Center(
              child: Text(
                'Tidak ada data anime',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimeCard(anime: anime!),
              ),
            ),
    );
  }
}
