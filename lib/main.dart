import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.person, color: Colors.deepPurpleAccent),
          Icon(Icons.home, color: Colors.deepPurpleAccent),
          Icon(Icons.favorite, color: Colors.deepPurpleAccent),
        ],
        inactiveIcons: const [Text("My"), Text("Home"), Text("Like")],
        activeIndex: _activeIndex,
        color: Colors.white,
        onTap: (index) {
          setState(() {
            _activeIndex = index; // Update nilai _activeIndex
          });
        },
        height: 60,
        circleWidth: 60,
        cornerRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          // bottomLeft: Radius.circular(24),
          // bottomRight: Radius.circular(24),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 11, 27, 40),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Color.fromARGB(255, 11, 27, 40),
        title: Row(
          children: [
            CircleAvatar(radius: 30),
            SizedBox(width: 7),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Selamat Skibidi',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  'Kyovalskye',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const AnimeCard(),
        ),
      ),
    );
  }
}
