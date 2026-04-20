import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabs = [
    _TabItem(label: 'Explorer', path: AppRoutes.home),
    _TabItem(label: 'Maps',     path: AppRoutes.search),
    _TabItem(label: 'Messages', path: AppRoutes.inbox),
    _TabItem(label: 'Profil',   path: AppRoutes.profile),
  ];

  GoRouter? _router;
  int _lastTabIndex = 0;

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
        0 => active
            ? PhosphorIcons.compass(PhosphorIconsStyle.fill)
            : PhosphorIcons.compass(),
        1 => active
            ? PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill)
            : PhosphorIcons.mapTrifold(),
        2 => active
            ? PhosphorIcons.chatCircle(PhosphorIconsStyle.fill)
            : PhosphorIcons.chatCircle(),
        3 => active
            ? PhosphorIcons.user(PhosphorIconsStyle.fill)
            : PhosphorIcons.user(),
        _ => PhosphorIcons.compass(),
      };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                        Icon(_icon(i, active: isActive), size: 22, color: color),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
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
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.path});
  final String label;
  final String path;
}
