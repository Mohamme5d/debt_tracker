import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/theme/app_colors.dart';

// ─── Search Bar ─────────────────────────────────────────────────────────────
class ListSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const ListSearchBar({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ─── Gradient Avatar (name-based) ────────────────────────────────────────────
class GradientAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;

  const GradientAvatar({
    super.key,
    required this.name,
    this.size = 52,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.avatarGradient(name);
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

// ─── Leading Icon ────────────────────────────────────────────────────────────
class LeadingIcon extends StatelessWidget {
  final IconData icon;
  final List<Color>? gradient;
  final Color? accentColor;

  const LeadingIcon({super.key, required this.icon, this.gradient, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient!,
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd)
            : null,
        color: accentColor?.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (accentColor ?? Colors.white).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(icon, color: accentColor ?? Colors.white, size: 24),
    );
  }
}

// ─── Dark Gradient Card (base) ───────────────────────────────────────────────
class _DarkCard extends StatelessWidget {
  final Widget child;
  const _DarkCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

// ─── Swipe Card ──────────────────────────────────────────────────────────────
class SwipeCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String editLabel;
  final String deleteLabel;

  const SwipeCard({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    required this.editLabel,
    required this.deleteLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Slidable(
        endActionPane: onDelete != null
            ? ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.22,
                children: [
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_rounded,
                    label: deleteLabel,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                ],
              )
            : null,
        startActionPane: onEdit != null
            ? ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.22,
                children: [
                  SlidableAction(
                    onPressed: (_) => onEdit!(),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    icon: Icons.edit_rounded,
                    label: editLabel,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                ],
              )
            : null,
        child: _DarkCard(child: child),
      ),
    );
  }
}

// ─── Staggered list item animation ───────────────────────────────────────────
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({super.key, required this.index, required this.child});

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final delay = (widget.index * 0.08).clamp(0.0, 0.6);
    final end = (delay + 0.5).clamp(delay + 0.1, 1.0);

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, end, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class EmptyListState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyListState(this.message, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 44,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
