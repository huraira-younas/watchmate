import 'package:watchmate_app/features/auth/model/user_model.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/features/auth/bloc/events.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/states.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _keys = List.generate(2, (_) => GlobalKey<FormState>());
  final _authBloc = getIt<AuthBloc>();

  late UserModel user = widget.user;
  File? _pickedImage;

  Future<void> handleUpdate() async {
    if (user.name.isNullOrEmpty) return;
    final profileURL = _pickedImage?.path;

    _authBloc.add(
      AuthUpdateUser(
        onSuccess: () => context.pop(),
        profileURL: profileURL,
        name: user.name,
        id: user.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: customAppBar(context: context, title: "Edit Profile"),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.user == c.user,
        listener: (context, state) {
          final loading = state.loading;
          final error = state.error;
          if (loading == null || error == null) {
            user = state.user!;
          }
        },
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      ProfileAvt(
                        size: 120,
                        url: _getProfile(),
                      ).hero(user.username),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.cardColor,
                          ),
                        ),
                      ),
                    ],
                  ).center(),
                  40.h,
                  Form(
                    key: _keys[0],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      validator: ValidatorBuilder.chain()
                          .required()
                          .min(3)
                          .build(),
                      onChange: (p0) {
                        setState(() => user = user.copyWith(name: p0?.trim()));
                      },
                      prefixIcon: const Icon(Icons.person_outline),
                      value: user.name,
                      hint: "Name",
                    ),
                  ),
                  10.h,
                  Form(
                    key: _keys[1],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CustomTextField(
                      prefixIcon: const Icon(Icons.email_outlined),
                      value: user.email,
                      enabled: false,
                      hint: "Email",
                    ),
                  ),
                ],
              ),
            ).expanded(),
            CustomButton(
              onPressed: user == widget.user ? null : handleUpdate,
              text: "Update",
            ),
          ],
        ).padAll(AppConstants.padding),
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedImage = File(result.files.single.path!);
        user = user.copyWith(profileURL: _pickedImage!.path);
      });
    }
  }

  String _getProfile() {
    return _pickedImage?.path ?? user.fullProfileURL;
  }
}
