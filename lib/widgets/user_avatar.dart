import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/servis_auth.dart';
import '../theme/tema_app.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final isLoggedIn = auth.isLoggedIn;
    final photo = auth.userPhoto.trim();

    Widget avatarChild;

    if (isLoggedIn && photo.isNotEmpty) {
      avatarChild = Image.network(
        photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: size * 0.58,
          );
        },
      );
    } else if (isLoggedIn) {
      avatarChild = Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: size * 0.58,
      );
    } else {
      avatarChild = Padding(
        padding: EdgeInsets.all(size * 0.14),
        child: SvgPicture.asset(
          'assets/images/PawPetlogo.svg',
          fit: BoxFit.contain,
        ),
      );
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        color: Colors.white,
      ),
      child: ClipOval(child: avatarChild),
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
