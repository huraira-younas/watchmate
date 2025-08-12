import 'package:watchmate_app/common/widgets/skeletons/video_card_skeleton.dart';
import 'package:watchmate_app/features/my_list/widgets/video_card_preview.dart';
import 'package:watchmate_app/features/my_list/widgets/custom_list_tabs.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/features/my_list/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Completer;

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen>
    with AutomaticKeepAliveClientMixin {
  final _listBloc = getIt<ListBloc>();
  final _authBloc = getIt<AuthBloc>();

  ListType _key = ListType.public;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList({bool refresh = true}) async {
    final completer = Completer();
    _listBloc.add(
      FetchVideos(
        onSuccess: () => completer.complete(),
        userId: _authBloc.user!.id,
        refresh: refresh,
        type: _key,
      ),
    );

    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => showAppSnackBar("Network Request timeout"),
    );
  }

  void changeType(ListType newType) {
    if (newType == _key) return;

    setState(() => _key = newType);
    _fetchList(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        CustomListTabs(current: _key, onChange: changeType),
        RefreshIndicator(
          onRefresh: _fetchList,
          child: BlocBuilder<ListBloc, Map<ListType, ListState>>(
            buildWhen: (p, c) => c[_key] != p[_key],
            builder: (context, state) {
              final st = state[_key];
              if (st == null) return const SizedBox.shrink();

              final loading = st.loading;
              final error = st.error;

              if (error != null) showAppSnackBar(error.message);
              if (loading) return const VideoCardSkeleton().fadeIn();

              final pagination = st.pagination;
              if (pagination.videos.isEmpty) {
                return CustomLabelWidget(
                  text: "No videos found in your ${_key.name}. Try to add one",
                  icon: Icons.insert_emoticon_sharp,
                  title: "Oppss.. No Video Found",
                );
              }

              return ListView.builder(
                itemCount: pagination.videos.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.padding - 12,
                  vertical: AppConstants.padding - 10,
                ),
                itemBuilder: (context, idx) {
                  return VideoCardPreview(
                    video: pagination.videos[idx],
                    onMenuTap: () {},
                  );
                },
              );
            },
          ),
        ).expanded(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
