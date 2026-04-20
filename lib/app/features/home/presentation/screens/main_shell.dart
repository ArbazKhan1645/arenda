import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:arenda/app/core/routes/app_routes.dart';
import 'package:arenda/app/core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabs = [
    _TabItem(label: 'Explorer', path: AppRoutes.home),
    _TabItem(label: 'Maps', path: AppRoutes.search),
    _TabItem(label: 'Messages', path: AppRoutes.inbox),
    _TabItem(label: 'Profil', path: AppRoutes.profile),
  ];

  GoRouter? _router;
  int _lastTabIndex = 0;
  DateTime? _lastBackPressTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(router, _router)) {
      _router?.routerDelegate.removeListener(_onRouteChanged);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChanged);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  int get _currentIndex {
    final path = _router?.routeInformationProvider.value.uri.path ?? '';
    for (var i = 0; i < _tabs.length; i++) {
      if (path.startsWith(_tabs[i].path)) {
        _lastTabIndex = i;
        return i;
      }
    }
    return _lastTabIndex;
  }

  IconData _icon(int i, {required bool active}) => switch (i) {
    0 =>
      active
          ? PhosphorIcons.compass(PhosphorIconsStyle.fill)
          : PhosphorIcons.compass(),
    1 =>
      active
          ? PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill)
          : PhosphorIcons.mapTrifold(),
    2 =>
      active
          ? PhosphorIcons.chatCircle(PhosphorIconsStyle.fill)
          : PhosphorIcons.chatCircle(),
    3 =>
      active
          ? PhosphorIcons.user(PhosphorIconsStyle.fill)
          : PhosphorIcons.user(),
    _ => PhosphorIcons.compass(),
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (currentIndex != 0) {
          context.go(AppRoutes.home);
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Appuyez encore pour quitter',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.textPrimary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = i == currentIndex;
                final color = isActive
                    ? AppColors.primary
                    : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(_tabs[i].path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icon(i, active: isActive),
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.path});
  final String label;
  final String path;
}
