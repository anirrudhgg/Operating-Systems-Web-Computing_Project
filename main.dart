import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const LoadoutLockerApp());

/// Simple Data Store to keep settings in memory while the app is open.
class AppData {
  // PC Settings Store: Map<GameName, Settings>
  static Map<String, Map<String, dynamic>> pcSettings = {};

  // Console Progress Store: Map<GameName, Percentage>
  static Map<String, double> consoleProgress = {};
}

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

// 1. MAIN OPTIONS
class MainCategoryPage extends StatelessWidget {
  const MainCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loadout Locker'), centerTitle: true),
      body: Row(
        children: [
          Expanded(child: _buildBigBlock(context, 'PC', Icons.computer, const Color(0xFF2196F3))),
          const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(child: _buildBigBlock(context, 'Console', Icons.videogame_asset, const Color(0xFF4CAF50))),
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
        decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
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

// 3. PC PROFILE SETTINGS (Saves to AppData)
class PCProfilePage extends StatefulWidget {
  final String gameName;
  const PCProfilePage({super.key, required this.gameName});

  @override
  State<PCProfilePage> createState() => _PCProfilePageState();
}

class _PCProfilePageState extends State<PCProfilePage> {
  late TextEditingController _dpiController;
  late TextEditingController _sensController;
  late String _selectedQuality;

  @override
  void initState() {
    super.initState();
    // Load existing data or set defaults
    var saved = AppData.pcSettings[widget.gameName] ?? {'dpi': '', 'sens': '', 'quality': 'High'};
    _dpiController = TextEditingController(text: saved['dpi']);
    _sensController = TextEditingController(text: saved['sens']);
    _selectedQuality = saved['quality'];
  }

  void _saveSettings() {
    AppData.pcSettings[widget.gameName] = {
      'dpi': _dpiController.text,
      'sens': _sensController.text,
      'quality': _selectedQuality,
    };
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.gameName} Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _dpiController, decoration: const InputDecoration(labelText: 'DPI')),
            TextField(controller: _sensController, decoration: const InputDecoration(labelText: 'Sensitivity')),
            const SizedBox(height: 20),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedQuality,
              items: ['Low', 'Medium', 'High', 'Ultra'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (val) => setState(() => _selectedQuality = val!),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, minimumSize: const Size(double.infinity, 50)),
              onPressed: _saveSettings,
              child: const Text('Save & Apply', style: TextStyle(color: Colors.black)),
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
      body: Column(
        children: [
          ListTile(title: const Text('PS5'), onTap: () => _nav(context, 'PS5')),
          ListTile(title: const Text('Xbox Series X/S'), onTap: () => _nav(context, 'Xbox')),
        ],
      ),
    );
  }

  void _nav(BuildContext context, String platform) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleGamesPage(platform: platform)));
  }
}

// 5. CONSOLE GAMES LIST (With Progress Bar and Real-time Save)
class ConsoleGamesPage extends StatefulWidget {
  final String platform;
  const ConsoleGamesPage({super.key, required this.platform});

  @override
  State<ConsoleGamesPage> createState() => _ConsoleGamesPageState();
}

class _ConsoleGamesPageState extends State<ConsoleGamesPage> {
  List<String> getGames() {
    return widget.platform == 'PS5' 
      ? ['Spider-Man 2', 'Gran Turismo 7', 'GTA 5'] 
      : ['Forza Horizon', 'Gears of War', 'Halo'];
  }

  @override
  Widget build(BuildContext context) {
    final games = getGames();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.platform} Games')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          String game = games[index];
          double progress = AppData.consoleProgress[game] ?? 0.0;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(game, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: (progress * 100).toInt().toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(hintText: '%'),
                          onChanged: (val) {
                            setState(() {
                              double newVal = (double.tryParse(val) ?? 0).clamp(0, 100) / 100;
                              AppData.consoleProgress[game] = newVal;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('${(progress * 100).toInt()}% Completed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
