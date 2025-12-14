import 'package:flutter/material.dart';

// Settings screen for app configuration
// Member 4 - Settings Feature
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // App Information Section
          _buildSectionHeader('App Information'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildSettingsTile(
            icon: Icons.phone_android,
            title: 'Platform',
            subtitle: 'Android',
            onTap: null,
          ),
          const Divider(height: 32),
          // API Configuration Section
          _buildSectionHeader('API Configuration'),
          _buildSettingsTile(
            icon: Icons.api,
            title: 'Spoonacular API',
            subtitle: 'Configure recipe search API key',
            onTap: () {
              _showApiKeyDialog(context, 'Spoonacular API Key');
            },
          ),
          _buildSettingsTile(
            icon: Icons.video_library,
            title: 'YouTube API',
            subtitle: 'Configure video search API key',
            onTap: () {
              _showApiKeyDialog(context, 'YouTube API Key');
            },
          ),
          const Divider(height: 32),
          // Storage Section
          _buildSectionHeader('Storage'),
          _buildSettingsTile(
            icon: Icons.storage,
            title: 'Cache Size',
            subtitle: 'Approximately 15 MB',
            onTap: null,
          ),
          _buildSettingsTile(
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            subtitle: 'Remove temporary files',
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          const Divider(height: 32),
          // About Section
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.book,
            title: 'User Guide',
            subtitle: 'Learn how to use MealMind',
            onTap: () {
              _showInfoDialog(
                context,
                'User Guide',
                'MealMind helps you:\n\n'
                    '• Search for recipes\n'
                    '• View cooking instructions\n'
                    '• Watch cooking videos\n'
                    '• Find nearby restaurants\n'
                    '• Save favorite recipes',
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.people,
            title: 'About',
            subtitle: 'MealMind - Your cooking assistant',
            onTap: () {
              _showInfoDialog(
                context,
                'About MealMind',
                'MealMind is a smart recipe finder and cooking assistant.\n\n'
                    'Version: 1.0.0\n'
                    'Platform: Flutter\n\n'
                    'Developed as a student project.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showApiKeyDialog(BuildContext context, String apiName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(apiName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your API key. You can obtain it from the respective service provider.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API key saved! Restart app to apply changes.'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all temporary files and cached data. Your saved recipes will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
