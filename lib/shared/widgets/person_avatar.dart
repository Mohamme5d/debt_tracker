import 'package:flutter/material.dart';
import '../../app/theme.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.size = 50,
    this.fontSize = 18,
    this.heroTag,
  });

  final String name;
  final double size;
  final double fontSize;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final gradientColors = AppTheme.avatarGradient(name);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: gradientColors,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
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

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: avatar);
    }
    return avatar;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}
