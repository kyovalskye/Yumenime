  import 'dart:convert';
  import 'package:http/http.dart' as http;

  class ApiService {
    static const String baseUrl = 'https://wajik-anime-api.vercel.app/samehadaku';

    // Ambil anime pertama dari /home
    static Future<Map?> fetchFirstAnime() async {
      try {
        final res = await http.get(Uri.parse('$baseUrl/home'));

        if (res.statusCode == 200) {
          final jsonData = jsonDecode(res.body);
          return jsonData['data']['recent']['animeList'][12];
        }
      } catch (e) {
        print('API Error: $e');
      }
      return null;
    }

    // Ambil detail anime berdasarkan animeId
    static Future<Map?> fetchAnimeDetail(String animeId) async {
      try {
        final res = await http.get(Uri.parse('$baseUrl/anime/$animeId'));

        if (res.statusCode == 200) {
          final jsonData = jsonDecode(res.body);
          return jsonData['data'];
        }
      } catch (e) {
        print('API Error: $e');
      }
      return null;
    }

    // Fungsi baru: Ambil anime pertama dengan detail lengkap
    static Future<Map?> fetchFirstAnimeWithDetail() async {
      try {
        // 1. Ambil anime pertama dari /home
        final firstAnime = await fetchFirstAnime();
        if (firstAnime == null) return null;

        // 2. Ambil detail lengkap menggunakan animeId
        final animeId = firstAnime['animeId'];
        final detail = await fetchAnimeDetail(animeId);

        if (detail == null) return null;

        // 3. Gabungkan data dari /home dengan detail
        return {
          ...firstAnime, // Data dari /home
          ...detail, // Data detail (akan override jika ada key yang sama)
          // Pastikan beberapa field penting tersedia
          'genreList': detail['genreList'] ?? [],
          'synopsis': detail['synopsis'] ?? {},
          'aired': detail['aired'] ?? detail['season'] ?? '',
          'poster': detail['poster'] ?? firstAnime['poster'],
          'title': detail['title'].isNotEmpty
              ? detail['title']
              : firstAnime['title'],
        };
      } catch (e) {
        print('API Error: $e');
      }
      return null;
    }
  }
