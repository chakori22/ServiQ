import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/presentation/posts/bloc/bloc/post_bloc.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/dashboard/repository/post_board_repository.dart';

const me = '9999900000';

PostBloc boardOn(PostBoardRepository store) =>
    PostBloc(dashboardRepository: const DashboardRepository(), board: store);

/// Waits for the board to finish its fetch.
Future<PostBloc> loaded(PostBoardRepository store) async {
  final bloc = boardOn(store)
    ..add(const OnFetchPostDetails(currentUsername: me));
  await bloc.stream.firstWhere((state) => !state.postsLoading);
  return bloc;
}

PostDraft draft() => const PostDraft(
  category: 'Plumbing',
  description: 'Kitchen tap is dripping',
  budget: '500',
  imagePath: '/tmp/photo.jpg',
  isInstant: true,
  username: me,
);

void main() {
  group('what the seeker did to the board survives leaving it', () {
    test('a post they shared is still there when the board reopens', () async {
      final store = PostBoardRepository();

      final first = await loaded(store);
      first.add(OnStartPostUpload(draft()));
      await first.stream.firstWhere(
        (state) => state.uploadingDraft == null && state.postDetails.isNotEmpty,
      );
      expect(
        first.state.postDetails.first.description,
        contains('Kitchen tap'),
      );
      await first.close();

      // The board is rebuilt from scratch every time it is opened, and the
      // stub feed hands back the same seeded list — so the post has to come
      // back from the session store or it is lost.
      final second = await loaded(store);
      expect(
        second.state.postDetails.first.description,
        contains('Kitchen tap'),
      );
      expect(second.state.postDetails.first.username, me);
      await second.close();
    });

    test(
      'an accepted offer is still accepted when the board reopens',
      () async {
        final store = PostBoardRepository();
        const offer = PostOffer(
          name: 'Imran AC Works',
          badge: OfferBadge.provider,
          price: '₹700',
          timing: 'today, evening',
          note: '',
        );

        final first = await loaded(store);
        final mine = first.state.postDetails.firstWhere(
          (post) => post.acceptCount > 0 && !post.isAccepted,
        );
        first.add(OnOfferAccepted(mine, offer));
        await first.stream.first;
        await first.close();

        final second = await loaded(store);
        final again = second.state.postDetails.firstWhere(
          (post) => post.key == mine.key,
        );
        expect(again.isAccepted, isTrue);
        expect(again.acceptedBy, 'Imran AC Works');
        await second.close();
      },
    );

    test('an offer made from this device is still counted', () async {
      final store = PostBoardRepository();

      final first = await loaded(store);
      final theirs = first.state.postDetails.firstWhere(
        (post) => post.username != me,
      );
      final before = theirs.acceptCount;
      first.add(OnOfferMade(theirs));
      await first.stream.first;
      await first.close();

      final second = await loaded(store);
      final again = second.state.postDetails.firstWhere(
        (post) => post.key == theirs.key,
      );
      expect(again.acceptCount, before + 1);
      await second.close();
    });
  });
}
