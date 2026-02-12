import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const LoadoutLockerApp());

class LoadoutLockerApp extends StatelessWidget {
  const LoadoutLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loadout Locker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 8,
        ),
      ),
      home: const MainCategoryPage(),
    );
  }
}

// 1. MAIN OPTIONS: PC and Console as Big Blocks (Left and Right)
class MainCategoryPage extends StatelessWidget {
  const MainCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loadout Locker'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            child: _buildBigBlock(context, 'PC', Icons.computer, const Color(0xFF2196F3)),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            child: _buildBigBlock(context, 'Console', Icons.videogame_asset, const Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }

  Widget _buildBigBlock(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (title == 'PC') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PCGamesPage()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsoleSelectionPage()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 2. PC GAMES LIST
class PCGamesPage extends StatelessWidget {
  const PCGamesPage({super.key});
  final List<String> games = const ['Apex Legends', 'Fortnite', 'Valorant', 'Minecraft', 'Counter Strike 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PC Games')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(games[index]),
          trailing: const Icon(Icons.settings),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PCProfilePage(gameName: games[index]))),
        ),
      ),
    );
  }
}

// 3. PC PROFILE SETTINGS (With Apply Button)
class PCProfilePage extends StatefulWidget {
  final String gameName;
  const PCProfilePage({super.key, required this.gameName});

  @override
  State<PCProfilePage> createState() => _PCProfilePageState();
}

class _PCProfilePageState extends State<PCProfilePage> {
  String _selectedQuality = 'High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.gameName} Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mouse Settings', style: TextStyle(fontSize: 18, color: Colors.cyanAccent)),
            const TextField(decoration: InputDecoration(labelText: 'DPI')),
            const TextField(decoration: InputDecoration(labelText: 'Sensitivity')),
            const SizedBox(height: 30),
            const Text('Graphics Quality', style: TextStyle(fontSize: 18, color: Colors.cyanAccent)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedQuality,
              items: <String>['Low', 'Medium', 'High', 'Ultra'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedQuality = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes Applied Successfully!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. CONSOLE SELECTION
class ConsoleSelectionPage extends StatelessWidget {
  const ConsoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Console')),
      body: ListView(
        children: [
          _consoleOption(context, 'PS5'),
          _consoleOption(context, 'Xbox Series X/S'),
        ],
      ),
    );
  }

  Widget _consoleOption(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleGamesPage(platform: title))),
    );
  }
}

// 5. CONSOLE GAMES LIST (With Numerical Completion Box)
class ConsoleGamesPage extends StatelessWidget {
  final String platform;
  const ConsoleGamesPage({super.key, required this.platform});

  List<String> getGames() {
    if (platform == 'PS5') {
      return ['Spider-Man 2', 'Gran Turismo 7', 'GTA 5', 'Ghost of Tsushima', 'Assassins Creed Mirage'];
    } else {
      return ['Forza Horizon', 'Gears of War', 'Metal Gear Solid', 'Battlefield 6'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$platform Games')),
      body: ListView.builder(
        itemCount: getGames().length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getGames()[index], style: const TextStyle(fontSize: 16)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Comp. %',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}