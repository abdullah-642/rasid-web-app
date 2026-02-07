import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';

// Simple provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Notification state provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    // themeMode unused, removed
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // ... (rest of header code remains same) ...
            // Profile Header
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        (user?.userMetadata?['full_name']?[0] ?? 'A')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.userMetadata?['full_name'] ?? 'المستخدم',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            _buildSection(context, 'الإعدادات العامة', [
              // Dark Mode removed
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: 'اللغة',
                trailing: const Text(
                  'العربية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              if (user?.email == 'kingmr642@gmail.com') ...[
                _buildDivider(),
                _buildSettingItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'معرف المحاسب (Telegram ID)',
                  onTap: () => _showEditAccountantIdDialog(context, user),
                  trailing: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ]),

            const SizedBox(height: 24),

            _buildSection(context, 'الحساب والأمان', [
              _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'تعديل البيانات الشخصية',
                onTap: () => _showEditProfileDialog(context, ref, user),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.lock_outline,
                title: 'تغيير كلمة المرور',
                onTap: () {},
              ),
              _buildDivider(),
              if (user?.email == 'sharoofy16@gmail.com') ...[
                _buildSettingItem(
                  context,
                  icon: Icons.link,
                  title: 'إعدادات Webhook',
                  onTap: () => _showEditWebhookDialog(context),
                  trailing: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                _buildDivider(),
              ],
              _buildSettingItem(
                context,
                icon: Icons.notifications_none,
                title: 'الإشعارات',
                trailing: Switch(
                  value: notificationsEnabled,
                  activeTrackColor: AppTheme.primaryColor,
                  onChanged: (val) {
                    ref.read(notificationsEnabledProvider.notifier).state = val;
                  },
                ),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSection(context, 'الدعم والمساعدة', [
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'مركز المساعدة',
                onTap: () async {
                  final url = Uri.parse('https://wa.me/966571840556');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                onTap: () => _showAboutDialog(context),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
              : null),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withValues(alpha: 0.05));
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    final nameController = TextEditingController(
      text: user?.userMetadata?['full_name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل البيانات الشخصية'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'الاسم الكامل',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && user != null) {
                try {
                  // Update user metadata in Supabase
                  await ref.read(authProvider.notifier).updateProfile(newName);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث البيانات بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'راصد (Rased) - الحل الأمثل للإدارة المالية الذكية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'يُعد تطبيق "راصد" نقلة نوعية في عالم إدارة المصروفات والميزانيات، حيث يجمع بين سهولة الاستخدام وقوة الأداء. صُمم التطبيق ليمنح الأفراد والشركات القدرة على تتبع تحركاتهم المالية لحظة بلحظة، مع واجهة عصرية تدعم الوضع الليلي لراحة عينيك.',
              ),
              const SizedBox(height: 16),
              const Text(
                'أبرز المميزات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '📊 تحديث فوري: متابعة حية للميزانيات والمصاريف المتبقية.',
              ),
              const Text('🛡️ نظام صلاحيات متطور: لوحة تحكم خاصة للمسؤولين.'),
              const Text('📑 تقارير دقيقة: إمكانية تصدير كشوفات الحساب.'),
              const Text('🔒 أمان وعالية: حماية بياناتك بأحدث تقنيات التشفير.'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '💡 تم التطوير والبرمجة بواسطة: المبرمج / عبدالله عبدالرحيم بن سنكر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                '📞 لطلب نسختك الخاصة أو للاستفسار: تواصل معنا مباشرة على: 0571840556',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountantIdDialog(BuildContext context, user) async {
    if (user == null) return;

    final controller = TextEditingController();
    // Show loading or fetch first? Better to fetch inside dialog or FutureBuilder.
    // For simplicity, we fetch first then show, or show with loader.
    // Let's show dialog with FutureBuilder or fetch then show.
    // Fetching first is cleaner UX if fast.

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('telegram_chat_id')
          .eq('id', user.id)
          .maybeSingle(); // user.id is String

      if (res != null) {
        controller.text = res['telegram_chat_id']?.toString() ?? '';
      }
    } catch (e) {
      // ignore
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معرف المحاسب (Chat ID)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سيتلقى هذا المعرف تنبيهات عند انخفاض الميزانية.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Telegram Chat ID',
                prefixIcon: Icon(Icons.chat),
                hintText: 'مثال: 123456789',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              try {
                // Upsert to ensure profile exists
                await Supabase.instance.client.from('profiles').upsert({
                  'id': user.id,
                  'telegram_chat_id': val,
                  'updated_at': DateTime.now().toIso8601String(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم الحفظ بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditWebhookDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentWebhook =
        prefs.getString('sharoofy_webhook') ??
        'https://n8n.alqamuh.com/webhook/8ec6fd3b-659a-49c5-a07e-2bc7fc8826c7';

    final controller = TextEditingController(text: currentWebhook);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات Webhook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'قم بتعيين رابط Webhook الذي سيتم إرسال بيانات المهام إليه.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Webhook URL',
                prefixIcon: Icon(Icons.link),
                hintText: 'https://example.com/webhook',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await prefs.setString('sharoofy_webhook', newUrl);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث Webhook بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
