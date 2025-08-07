import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/auth/bloc/states.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user!;

        return Row(
          spacing: 16,
          children: <Widget>[
            ProfileAvt(size: 60, url: user.profileURL ?? AppConstants.userAvt),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  size: AppConstants.subtitle,
                  family: AppFonts.bold,
                  text: user.name,
                ),
                3.h,
                MyText(text: user.email, color: theme.hintColor, size: 12),
              ],
            ),
          ],
        );
      },
    ).padSym(h: AppConstants.padding);
  }
}
