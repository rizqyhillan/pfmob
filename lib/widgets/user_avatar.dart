import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../theme/tema_app.dart';
import '../viewmodels/auth_viewmodel.dart';

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
    return Selector<AuthViewModel, ({bool isLoggedIn, String photo})>(
      selector: (_, vm) => (
        isLoggedIn: vm.isLoggedIn,
        photo: vm.userPhoto.trim(),
      ),
      builder: (_, authState, __) {
        Widget avatarChild;

        if (authState.isLoggedIn && authState.photo.isNotEmpty) {
          avatarChild = Image.network(
            authState.photo,
            width: size,
            height: size,
            cacheWidth: (size * 3).round(),
            cacheHeight: (size * 3).round(),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: size * 0.58,
              );
            },
          );
        } else if (authState.isLoggedIn) {
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
      },
    );
  }
}
