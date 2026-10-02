import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Standard Circular Sankalp Logo Badge utilized across all application screens
/// in the top-left corner and during splash / onboarding startup.
class SankalpRoundLogo extends StatelessWidget {
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;
  final String? heroTag;

  const SankalpRoundLogo({
    super.key,
    this.size = 36.0,
    this.showBorder = true,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: showBorder
              ? Border.all(
                  color: const Color(0xFFFFC727), // Sankalp Accent Yellow
                  width: 2.0,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(size * 0.10), // Aesthetic breathing padding
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback to branded paper plane icon
                return Icon(
                  Icons.near_me_rounded,
                  color: const Color(0xFFFFC727),
                  size: size * 0.65,
                );
              },
            ),
          ),
        ),
      );

    if (heroTag != null) {
      content = Hero(
        tag: heroTag!,
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// Universal Scaffold AppBar featuring the required circular logo in the top-left corner
/// along with standard navigation actions.
class SankalpAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onLogoTap;

  const SankalpAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: showBackButton ? 96 : 54,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBackButton) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/app/today');
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
            ],
            SankalpRoundLogo(
              size: 34,
              onTap: onLogoTap,
            ),
          ],
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 19,
          letterSpacing: 0.2,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
