import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenPayments,
    required this.onOpenCertificates,
    required this.onOpenAnnouncements,
    required this.onOpenResults,
    required this.onOpenAttendance,
    required this.onOpenCourses,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenCertificates;
  final VoidCallback onOpenAnnouncements;
  final VoidCallback onOpenResults;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const PageHeader(
            title: 'More',
            subtitle: 'Account, learning history, and support.',
          ),
          _tile(
            context,
            Icons.person_outline_rounded,
            'Parent profile & settings',
            onOpenSettings,
          ),
          _tile(context, Icons.payments_outlined, 'Payments', onOpenPayments),
          _tile(
            context,
            Icons.workspace_premium_outlined,
            'Certificates',
            onOpenCertificates,
          ),
          _tile(context, Icons.emoji_events_outlined, 'Results', onOpenResults),
          _tile(
            context,
            Icons.event_available_outlined,
            'Attendance',
            onOpenAttendance,
          ),
          _tile(
            context,
            Icons.menu_book_outlined,
            'Courses & levels',
            onOpenCourses,
          ),
          _tile(
            context,
            Icons.notifications_outlined,
            'Announcements',
            onOpenAnnouncements,
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onPrivacy,
    required this.onTerms,
    required this.onHelp,
    required this.onLogout,
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final parent = AppState.read(context).parent;
    _name = TextEditingController(text: parent?.name ?? '');
    _email = TextEditingController(text: parent?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _saveDetails() {
    final parent = AppState.read(context).parent;
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (parent == null || name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Parent name is required.')));
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address or leave it blank.'),
        ),
      );
      return;
    }
    AppState.read(
      context,
    ).updateParent(parent.copyWith(name: name, email: email));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Parent details updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final parent = state.parent;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (parent != null) ...[
            Text(parent.mobile, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Parent / guardian name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address (optional)',
              ),
            ),
            const SizedBox(height: 12),
            AppPrimaryButton(
              label: 'Save parent details',
              onPressed: _saveDetails,
            ),
            const SizedBox(height: 20),
          ],
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push notifications'),
            subtitle: const Text('UI preference only'),
            value: parent?.notificationsEnabled ?? true,
            onChanged: (v) {
              if (parent == null) return;
              state.updateParent(parent.copyWith(notificationsEnabled: v));
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Practice reminders'),
            value: parent?.practiceReminders ?? true,
            onChanged: (v) {
              if (parent == null) return;
              state.updateParent(parent.copyWith(practiceReminders: v));
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Announcement alerts'),
            value: parent?.announcementAlerts ?? true,
            onChanged: (v) {
              if (parent == null) return;
              state.updateParent(parent.copyWith(announcementAlerts: v));
            },
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onPrivacy,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Terms and conditions'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onTerms,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Help and support'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: widget.onHelp,
          ),
          const SizedBox(height: 24),
          AppSecondaryButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            onPressed: () async {
              final ok = await showAppConfirmDialog(
                context: context,
                title: 'Log out?',
                message:
                    'You can sign back in anytime with your mobile number.',
                confirmLabel: 'Log out',
                isDestructive: true,
              );
              if (ok) widget.onLogout();
            },
          ),
          const SizedBox(height: 16),
          Text(
            '${AppConstants.appName} · UI prototype',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SimpleInfoScreen extends StatelessWidget {
  const SimpleInfoScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
