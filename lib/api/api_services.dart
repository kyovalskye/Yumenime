import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://wajik-anime-api.vercel.app/samehadaku';

  static Future<Map?> fetchFirstAnime() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/home'));
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return jsonData['data']['recent']['animeList'][6];
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

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

  static Future<List<Map>?> fetchOngoingAnime() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/home'));
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final animeList = jsonData['data']['recent']['animeList'] as List;

        final ongoingAnime = animeList.where((anime) {
          final status = anime['status']?.toString().toLowerCase() ?? '';
          return status.contains('ongoing') || status.contains('airing');
        }).toList();

        if (ongoingAnime.isEmpty) {
          return animeList
              .take(10)
              .map((anime) => Map<String, dynamic>.from(anime))
              .toList();
        }

        return ongoingAnime
            .map((anime) => Map<String, dynamic>.from(anime))
            .toList();
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  static Future<Map?> fetchFirstAnimeWithDetail() async {
    try {
      final firstAnime = await fetchFirstAnime();
      if (firstAnime == null) return null;

      final animeId = firstAnime['animeId'];
      final detail = await fetchAnimeDetail(animeId);

      if (detail == null) return null;

      return {
        ...firstAnime,
        ...detail,
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

  static Future<List<Map>?> fetchRandomAnimeList() async {
    try {
      final random = Random();
      final characters =
          ['#'] + List.generate(26, (i) => String.fromCharCode(65 + i));
      final randomStartWith = characters[random.nextInt(characters.length)];

      print('Random startWith: $randomStartWith');

      final res = await http.get(
        Uri.parse('$baseUrl/anime?startWith=$randomStartWith'),
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final dataList = jsonData['data']['list'] as List;

        for (var item in dataList) {
          if (item['startWith'] == randomStartWith) {
            final animeList = item['animeList'] as List;
            return animeList
                .map((anime) => Map<String, dynamic>.from(anime))
                .toList();
          }
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  static Future<List<Map>?> fetchRandomAnimeWithDetails() async {
    try {
      final animeList = await fetchRandomAnimeList();
      if (animeList == null || animeList.isEmpty) return null;

      final selectedAnimes = animeList.take(10).toList();
      List<Map> detailedAnimeList = [];

      for (var anime in selectedAnimes) {
        final animeId = anime['animeId'];
        if (animeId != null) {
          final detail = await fetchAnimeDetail(animeId);
          if (detail != null) {
            detailedAnimeList.add({
              ...anime,
              ...detail,
              'genreList': detail['genreList'] ?? [],
              'synopsis': detail['synopsis'] ?? {},
              'aired': detail['aired'] ?? detail['season'] ?? '',
              'poster': detail['poster'] ?? anime['poster'],
              'title': detail['title'].isNotEmpty
                  ? detail['title']
                  : anime['title'],
            });
          }
        }
      }

      return detailedAnimeList;
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }
}
