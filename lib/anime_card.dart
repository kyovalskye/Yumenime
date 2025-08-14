import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final Map anime;
  const AnimeCard({super.key, required this.anime});

  // Fungsi untuk format genre list menjadi string
  String formatGenres() {
    if (anime['genreList'] != null && anime['genreList'] is List) {
      final genres = anime['genreList'] as List;
      return genres.map((genre) => genre['title']).join(', ');
    }
    return anime['genre'] ?? 'Genre tidak tersedia';
  }

  // Fungsi untuk mendapatkan deskripsi
  String getDescription() {
    // Cek synopsis dari detail API
    if (anime['synopsis'] != null && anime['synopsis']['paragraphs'] != null) {
      final paragraphs = anime['synopsis']['paragraphs'] as List;
      if (paragraphs.isNotEmpty) {
        return paragraphs[0].toString();
      }
    }

    // Fallback ke field lain
    return anime['description'] ??
        anime['synopsis'] ??
        'Deskripsi tidak tersedia';
  }

  // Fungsi untuk mendapatkan tahun/status
  String getYear() {
    return anime['aired'] ??
        anime['season'] ??
        anime['status'] ??
        'Tahun tidak tersedia';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 11, 27, 40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'http://localhost:3000/image?url=${Uri.encodeComponent(anime['poster'] ?? '')}',
                    fit: BoxFit.cover,
                    height: 200,
                    width: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: 150,
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: 150,
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //! Judul anime
                      Text(
                        anime['title'] ??
                            anime['japanese'] ??
                            'Judul tidak tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),

                      //! Genre
                      Text(
                        formatGenres(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[300],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),

                      //! Tahun/Season/Status
                      Text(
                        getYear(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6),

                      //! Rating jika ada
                      if (anime['score'] != null) ...[
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${anime['score']['value']} (${anime['score']['users']} users)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],

                      //! Deskripsi
                      Text(
                        getDescription(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 12),

                      //! Tombol Tonton
                      ElevatedButton(
                        onPressed: () {
                          print('Tonton: ${anime['title']}');
                          // Tambahkan navigasi ke player di sini
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 13, 71, 119),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                        ),
                        child: Container(
                          width: 135,
                          height: 45,
                          child: Center(
                            child: Text(
                              'Tonton',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
