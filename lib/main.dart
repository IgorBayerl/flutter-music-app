import 'package:flutter/material.dart';
import 'package:flutter_audio_service_demo/pages/downloaded/downloaded.dart';
import 'package:flutter_audio_service_demo/pages/library/library_page.dart';
import 'package:flutter_audio_service_demo/pages/search/search_page.dart';
import 'pages/settings/settings_page.dart';
import 'services/page_manager.dart';
import 'pages/player/player_page.dart';
import 'services/service_locator.dart';

void main() async {
  await setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedPage = 2;
  final List<Widget> _pages = [
    // DownloadedSongsWidget(),
    SearchPage(),
    LibraryPage(),
    MusicPlayer(),
    SettingsPage(),
  ];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPage);
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _selectedPage = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.white),
              label: 'Search',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music, color: Colors.white),
              label: 'Library',
              backgroundColor: Colors.purple,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: 'Player',
              backgroundColor: Colors.pink,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Colors.white),
              label: 'Settings',
              backgroundColor: Colors.red,
            ),
            
          ],
          currentIndex: _selectedPage,
          onTap: (index) {
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text('Placeholder page 1'),
      ),
    );
  }
}
