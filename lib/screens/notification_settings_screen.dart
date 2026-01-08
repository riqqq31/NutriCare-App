import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/notification_service.dart';

/// Screen untuk pengaturan notifikasi
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService();
  bool _isLoading = true;

  // Notification preferences
  bool _breakfastReminder = true;
  bool _lunchReminder = true;
  bool _dinnerReminder = true;
  bool _weeklyUpdate = false;

  // Time preferences
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _notificationService.loadPreferences();
    setState(() {
      _breakfastReminder = prefs.breakfastEnabled;
      _lunchReminder = prefs.lunchEnabled;
      _dinnerReminder = prefs.dinnerEnabled;
      _weeklyUpdate = prefs.weeklyEnabled;
      _breakfastTime = prefs.breakfastTime;
      _lunchTime = prefs.lunchTime;
      _dinnerTime = prefs.dinnerTime;
      _isLoading = false;
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(String type) async {
    TimeOfDay initialTime;
    switch (type) {
      case 'breakfast':
        initialTime = _breakfastTime;
        break;
      case 'lunch':
        initialTime = _lunchTime;
        break;
      case 'dinner':
        initialTime = _dinnerTime;
        break;
      default:
        initialTime = const TimeOfDay(hour: 12, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (type) {
          case 'breakfast':
            _breakfastTime = picked;
            break;
          case 'lunch':
            _lunchTime = picked;
            break;
          case 'dinner':
            _dinnerTime = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan Notifikasi',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifikasi membantu Anda tetap konsisten dengan jadwal makan.',
                      style: TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meal Reminders Section
            Text(
              'PENGINGAT MAKAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Breakfast
            _buildNotificationTile(
              icon: Icons.wb_sunny_outlined,
              iconColor: const Color(0xFFFBBF24),
              title: 'Pengingat Sarapan',
              subtitle: _formatTime(_breakfastTime),
              value: _breakfastReminder,
              onChanged: (val) => setState(() => _breakfastReminder = val),
              onTimeTap: () => _selectTime('breakfast'),
            ),
            const SizedBox(height: 12),

            // Lunch
            _buildNotificationTile(
              icon: Icons.wb_cloudy_outlined,
              iconColor: const Color(0xFF60A5FA),
              title: 'Pengingat Makan Siang',
              subtitle: _formatTime(_lunchTime),
              value: _lunchReminder,
              onChanged: (val) => setState(() => _lunchReminder = val),
              onTimeTap: () => _selectTime('lunch'),
            ),
            const SizedBox(height: 12),

            // Dinner
            _buildNotificationTile(
              icon: Icons.nights_stay_outlined,
              iconColor: const Color(0xFF818CF8),
              title: 'Pengingat Makan Malam',
              subtitle: _formatTime(_dinnerTime),
              value: _dinnerReminder,
              onChanged: (val) => setState(() => _dinnerReminder = val),
              onTimeTap: () => _selectTime('dinner'),
            ),

            const SizedBox(height: 32),

            // Updates Section
            Text(
              'UPDATE & LAPORAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Weekly Update
            _buildNotificationTile(
              icon: Icons.bar_chart,
              iconColor: const Color(0xFF22C55E),
              title: 'Ringkasan Mingguan',
              subtitle: 'Setiap hari Minggu pukul 09:00',
              value: _weeklyUpdate,
              onChanged: (val) => setState(() => _weeklyUpdate = val),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Save preferences and schedule notifications
                  final prefs = NotificationPreferences(
                    breakfastEnabled: _breakfastReminder,
                    lunchEnabled: _lunchReminder,
                    dinnerEnabled: _dinnerReminder,
                    weeklyEnabled: _weeklyUpdate,
                    breakfastTime: _breakfastTime,
                    lunchTime: _lunchTime,
                    dinnerTime: _dinnerTime,
                  );
                  await _notificationService.savePreferences(prefs);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pengaturan notifikasi disimpan & dijadwalkan',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: value && onTimeTap != null ? onTimeTap : null,
                  child: Row(
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: value
                              ? AppColors.primary
                              : AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      if (onTimeTap != null && value) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary(context),
            inactiveTrackColor: AppColors.isDark(context)
                ? const Color(0xFF27272A)
                : const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}
