import 'dart:async';
import 'package:flutter/material.dart';
import 'api/api_services.dart';

class AnimeCard extends StatefulWidget {
  const AnimeCard({super.key});

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  List<Map>? slidingAnimeList;
  List<Map>? ongoingAnimeList;
  bool isLoadingSliding = true;
  bool isLoadingOngoing = true;

  PageController pageController = PageController();
  Timer? autoSlideTimer;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadSlidingAnime();
    loadOngoingAnime();
  }

  @override
  void dispose() {
    autoSlideTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadSlidingAnime() async {
    try {
      final animeList = await ApiService.fetchRandomAnimeWithDetails();

      setState(() {
        slidingAnimeList = animeList;
        isLoadingSliding = false;
      });

      // Start auto sliding timer setelah data loaded
      if (animeList != null && animeList.isNotEmpty) {
        startAutoSliding();
      }
    } catch (e) {
      print('Error loading sliding anime: $e');
      setState(() {
        isLoadingSliding = false;
      });
    }
  }

  void startAutoSliding() {
    autoSlideTimer?.cancel();
    autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (slidingAnimeList != null && slidingAnimeList!.isNotEmpty) {
        currentPage = (currentPage + 1);

        if (pageController.hasClients) {
          pageController.animateToPage(
            currentPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Future<void> loadOngoingAnime() async {
    try {
      final animeList = await ApiService.fetchOngoingAnime();

      // Untuk setiap anime, ambil detail lengkap untuk mendapatkan poster yang benar
      List<Map> detailedAnimeList = [];

      if (animeList != null) {
        for (var anime in animeList.take(15)) {
          // Ambil maksimal 15 anime
          final animeId = anime['animeId'];
          if (animeId != null) {
            final detail = await ApiService.fetchAnimeDetail(animeId);
            if (detail != null) {
              detailedAnimeList.add({
                ...anime,
                'poster': detail['poster'] ?? anime['poster'],
                'title': detail['title'].isNotEmpty
                    ? detail['title']
                    : anime['title'],
              });
            }
          }
        }
      }

      setState(() {
        ongoingAnimeList = detailedAnimeList;
        isLoadingOngoing = false;
      });
    } catch (e) {
      print('Error loading ongoing anime: $e');
      setState(() {
        isLoadingOngoing = false;
      });
    }
  }

  // Fungsi untuk format genre list menjadi string
  String formatGenres(Map anime) {
    if (anime['genreList'] != null && anime['genreList'] is List) {
      final genres = anime['genreList'] as List;
      return genres.map((genre) => genre['title']).join(', ');
    }
    return anime['genre'] ?? 'Genre tidak tersedia';
  }

  // Fungsi untuk mendapatkan tahun/status
  String getYear(Map anime) {
    return anime['aired'] ??
        anime['season'] ??
        anime['status'] ??
        'Tahun tidak tersedia';
  }

  Widget buildSlidingAnimeCard(Map anime) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () {
          print('Card diklik: ${anime['title']}');
        },
        child: Container(
          height: 300, // Increased height untuk show full poster
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full Poster Image - Clean tanpa overlay yang menghalangi
                Image.network(
                  'http://localhost:3000/image?url=${Uri.encodeComponent(anime['poster'] ?? '')}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 60,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue[600],
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                // Subtle gradient hanya di bagian bawah untuk text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Rating - Clean design di pojok kanan atas
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[600],
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${anime['score']?['value'] ?? '8.5'}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // // Episode badge - COMMENTED OUT
                // Positioned(
                //   top: 16,
                //   left: 16,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.8),
                //       borderRadius: BorderRadius.circular(6),
                //     ),
                //     child: Text(
                //       '#${anime['episodes'] ?? '1'}',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),

                // // View count - COMMENTED OUT
                // Positioned(
                //   top: 12,
                //   right: 12,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.8),
                //       borderRadius: BorderRadius.circular(6),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Icon(
                //           Icons.visibility,
                //           color: Colors.white,
                //           size: 16,
                //         ),
                //         SizedBox(width: 4),
                //         Text(
                //           '${anime['score']?['users'] ?? '715.040'}',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 12,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Judul - Clean typography di bagian bawah
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Text(
                    anime['title'] ??
                        anime['japanese'] ??
                        'Judul tidak tersedia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridAnimeCard(Map anime) {
    return GestureDetector(
      onTap: () {
        print('Grid anime diklik: ${anime['title']}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Poster image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 0.7, // Portrait ratio
                child: Image.network(
                  'http://localhost:3000/image?url=${Uri.encodeComponent(anime['poster'] ?? '')}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
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
            ),

            // Blue "New" badge (top left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Rating (top right)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 12),
                    SizedBox(width: 2),
                    Text(
                      '${anime['score']?['value'] ?? '7.50'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Episode info at bottom
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Eps ${anime['episodes'] ?? '7'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auto sliding anime cards (bagian atas)
        Container(
          height: 300, // Updated height untuk card yang lebih tinggi
          child: isLoadingSliding
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : slidingAnimeList == null || slidingAnimeList!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gagal memuat anime',
                        style: TextStyle(color: Colors.white70),
                      ),
                      ElevatedButton(
                        onPressed: loadSlidingAnime,
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: pageController,
                  itemBuilder: (context, index) {
                    final animeIndex = index % slidingAnimeList!.length;
                    return buildSlidingAnimeCard(slidingAnimeList![animeIndex]);
                  },
                ),
        ),

        // Indicator dots
        if (!isLoadingSliding &&
            slidingAnimeList != null &&
            slidingAnimeList!.isNotEmpty) ...[
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slidingAnimeList!.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: (currentPage % slidingAnimeList!.length) == index
                    ? 20
                    : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (currentPage % slidingAnimeList!.length) == index
                      ? Colors.blue
                      : Colors.grey[600],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 30),

        // Section title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'New Update Anime',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: 15),

        // Grid anime cards (3 kolom)
        isLoadingOngoing
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55, // Adjust untuk proporsi card
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: ongoingAnimeList?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (ongoingAnimeList != null &&
                        index < ongoingAnimeList!.length) {
                      return buildGridAnimeCard(ongoingAnimeList![index]);
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),

        SizedBox(height: 20),
      ],
    );
  }
}