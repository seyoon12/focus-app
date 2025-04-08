import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_1/presentation/screens/edit_app_list_screen.dart';
import 'package:flutter_application_1/utils/notification_util.dart';

class BlockedAppCategoryScreen extends StatefulWidget {
  const BlockedAppCategoryScreen({super.key});

  @override
  State<BlockedAppCategoryScreen> createState() => _BlockedAppCategoryScreenState();
}

class _BlockedAppCategoryScreenState extends State<BlockedAppCategoryScreen> {
  final Map<String, bool> _blockStatus = {
    'Social media': false,
    'Messenger': false,
    'Games': false,
    'Others': false,
  };

  final Map<String, List<String>> _categoryApps = {
    'Social media': [],
    'Messenger': [],
    'Games': [],
    'Others': [],
  };

  final Map<String, Color> _categoryColors = {
    'Social media': Colors.lightBlueAccent,
    'Messenger': Colors.cyan,
    'Games': Colors.orangeAccent,
    'Others': Colors.black87,
  };

  bool _doNotDisturb = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('blocked_apps');
    final dnd = prefs.getBool('do_not_disturb') ?? false;

    setState(() {
      _doNotDisturb = dnd;
      if (raw != null) {
        final decoded = json.decode(raw);
        for (final key in _categoryApps.keys) {
          _categoryApps[key] = List<String>.from(decoded[key] ?? []);
        }
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_categoryApps);
    await prefs.setString('blocked_apps', data);
  }

  Future<void> _setDoNotDisturb(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('do_not_disturb', value);
    setState(() => _doNotDisturb = value);

    if (value) {
      await NotificationUtil.enableDndMode(); // 전화 제외 전체 차단
    } else {
      await NotificationUtil.disableDndMode();
    }
  }

  Widget _buildCategoryCard(String name) {
    final appCount = _categoryApps[name]?.length ?? 0;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditAppListScreen(
              categoryName: name,
              apps: _categoryApps[name]!,
            ),
          ),
        );

        if (result != null && result is List<String>) {
          setState(() {
            _categoryApps[name] = result;
          });
          _saveData();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _categoryColors[name],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$appCount apps  •  Edit',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Switch(
              value: _blockStatus[name]!,
              onChanged: (val) {
                setState(() {
                  _blockStatus[name] = val;
                });
              },
              activeColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Do Not Disturb',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: _doNotDisturb,
                  onChanged: _setDoNotDisturb,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Some Apps',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          ..._blockStatus.keys.map((category) => _buildCategoryCard(category)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.brightness_low), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Report'),
        ],
      ),
    );
  }
}
