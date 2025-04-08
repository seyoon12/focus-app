import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_application_1/constants/app_category_rules.dart';

class EditAppListScreen extends StatefulWidget {
  final String categoryName;
  final List<String> apps;

  const EditAppListScreen({
    super.key,
    required this.categoryName,
    required this.apps,
  });

  @override
  State<EditAppListScreen> createState() => _EditAppListScreenState();
}

class _EditAppListScreenState extends State<EditAppListScreen> {
  List<ApplicationWithIcon> allApps = [];
  List<String> selectedApps = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();  
    selectedApps = List<String>.from(widget.apps);
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: false,
    );

    final filtered = apps.whereType<ApplicationWithIcon>().where((app) {
      final category = _classifyApp(app);
      final mapped = _mapCategoryName(widget.categoryName);
      return category.toLowerCase() == mapped.toLowerCase();
    }).toList();

    setState(() {
      allApps = filtered;
      loading = false;
    });
  }

  String _classifyApp(Application app) {
    final name = app.appName.toLowerCase();
    final pkg = app.packageName.toLowerCase();

    for (final keyword in appCategoryRules.keys) {
      if (name.contains(keyword) || pkg.contains(keyword)) {
        return appCategoryRules[keyword]!;
      }
    }
    return "Others";
  }

  String _mapCategoryName(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'social media':
        return 'Social';
      case 'messenger':
        return 'Messenger';
      case 'games':
        return 'Game';
      case 'others':
        return 'Others';
      default:
        return displayName;
    }
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (selectedApps.contains(packageName)) {
        selectedApps.remove(packageName);
      } else {
        selectedApps.add(packageName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.categoryName} 앱 선택')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : allApps.isEmpty
              ? const Center(child: Text('해당 카테고리에 해당하는 앱이 없습니다.'))
              : ListView.builder(
                  itemCount: allApps.length,
                  itemBuilder: (context, index) {
                    final app = allApps[index];
                    final isSelected = selectedApps.contains(app.packageName);
                    final category = _classifyApp(app);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _toggleApp(app.packageName),
                      title: Text(app.appName),
                      subtitle: Text(category),
                      secondary: Image.memory(
                        app.icon,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, selectedApps),
          child: const Text('저장'),
        ),
      ),
    );
  }
} 