import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShellScreen extends ConsumerStatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _selectedIndex = 0;

  bool get _isBusinessAdmin {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email == 'kingmr642@gmail.com';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).uri.toString();
    _updateIndex(location);
  }

  void _updateIndex(String location) {
    if (location == '/') {
      _selectedIndex = 0;
    } else if (location.startsWith('/personal')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/tasks')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = _isBusinessAdmin ? 4 : 3;
    } else if (location.startsWith('/business')) {
      _selectedIndex = 3;
    }
    setState(() {});
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);

    if (_isBusinessAdmin) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/personal');
          break;
        case 2:
          context.go('/tasks');
          break;
        case 3:
          context.go('/business');

          break;
        case 4:
          context.go('/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/personal');
          break;
        case 2:
          context.go('/tasks');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, color: Colors.black54),
        selectedIcon: Icon(
          Icons.grid_view_rounded,
          color: AppTheme.primaryColor,
        ),
        label: 'الرئيسية',
      ),
      const NavigationDestination(
        icon: Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.black54,
        ),
        selectedIcon: Icon(
          Icons.account_balance_wallet_rounded,
          color: AppTheme.primaryColor,
        ),
        label: 'ميزانياتي',
      ),
      const NavigationDestination(
        icon: Icon(Icons.task_alt_outlined, color: Colors.black54),
        selectedIcon: Icon(
          Icons.task_alt_rounded,
          color: AppTheme.primaryColor,
        ),
        label: 'مهامي',
      ),
    ];

    if (_isBusinessAdmin) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.business_center_outlined, color: Colors.black54),
          selectedIcon: Icon(
            Icons.business_center_rounded,
            color: AppTheme.primaryColor,
          ),
          label: 'الأعمال',
        ),
      );
    }

    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded, color: Colors.black54),
        selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
        label: 'حسابي',
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/logo.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'راصد',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
            width: double.infinity,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: PageStorage(
              bucket: PageStorageBucket(),
              child: RepaintBoundary(child: widget.child),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex >= destinations.length
              ? 0
              : _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations,
        ),
      ),
    );
  }
}
