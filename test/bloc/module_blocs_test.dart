import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/basket/bloc/basket_bloc.dart';
import 'package:local_markerplace/chat/bloc/chats_bloc.dart';
import 'package:local_markerplace/chat/bloc/conversation_bloc.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';
import 'package:local_markerplace/discovery/bloc/search_bloc.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/me/bloc/saved_providers_bloc.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';
import 'package:local_markerplace/notifications/bloc/notification_bloc.dart';
import 'package:local_markerplace/notifications/repository/notification_repository.dart';
import 'package:local_markerplace/visit/bloc/visit_bloc.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

/// The blocs the screens were moved onto, each exercised without a widget in
/// front of it.
void main() {
  /// Lets a bloc's handlers run before the state is read.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('notifications', () {
    test('marking all read empties the badge', () async {
      final bloc = NotificationBloc(
        notificationRepository: NotificationRepository.shared,
      )..add(const NotificationsRequested());
      await settle();

      expect(bloc.state.notifications, isNotEmpty);
      expect(bloc.state.hasUnread, isTrue);

      bloc.add(const AllNotificationsRead());
      await settle();

      expect(bloc.state.hasUnread, isFalse);
      expect(bloc.state.unreadCount, 0);
      await bloc.close();
    });
  });

  group('chats', () {
    test('searching narrows the list without losing the threads', () async {
      final bloc = ChatsBloc(chatRepository: ChatRepository())
        ..add(const ChatsRequested());
      await settle();

      final all = bloc.state.threads.length;
      expect(all, greaterThan(1));

      bloc.add(ChatsSearched(bloc.state.threads.first.providerName));
      await settle();

      expect(bloc.state.results.length, lessThan(all));
      // The empty state is decided by the threads, not the results — a
      // search that matches nothing is not the same as having no chats.
      expect(bloc.state.threads, hasLength(all));
      expect(bloc.state.hasThreads, isTrue);
      await bloc.close();
    });

    test('opening a conversation clears its badge', () async {
      final chats = ChatRepository();
      final unread = chats.threads.firstWhere((t) => t.unreadCount > 0);

      final bloc = ConversationBloc(
        chatRepository: chats,
        visitRepository: VisitRepository(),
      )..add(ConversationOpened(unread.providerName));
      await settle();

      expect(bloc.state.thread?.unreadCount, 0);
      await bloc.close();
    });
  });

  group('the cart', () {
    VisitRepository filled() {
      final visits = VisitRepository();
      visits.addService(
        providerName: 'Dev Electricals',
        providerLine: 'Galleria Market 1',
        isVerifiedProvider: true,
        service: const VisitService(
          name: 'Fan Installation',
          detail: 'Ceiling or wall',
          unitPrice: 330,
        ),
      );
      return visits;
    }

    test('opening commits the tab it opens on as the mode', () async {
      final visits = filled();
      final bloc = VisitBloc(visitRepository: visits)
        ..add(const CartOpened('Dev Electricals'));
      await settle();

      // The tab is the mode, not a highlight over it: a seeker who agrees
      // with it never touches it, and the cart has to be bookable anyway.
      expect(bloc.state.tab, VisitMode.instant);
      expect(visits.cartFor('Dev Electricals')?.mode, VisitMode.instant);
      expect(bloc.state.cart?.isReady, isTrue);
      await bloc.close();
    });

    test('confirming books it and leaves the cart empty', () async {
      final visits = filled();
      final bloc = VisitBloc(visitRepository: visits)
        ..add(const CartOpened('Dev Electricals'));
      await settle();

      bloc.add(const CartConfirmed());
      await settle();

      expect(bloc.state.booked, isNotNull);
      expect(bloc.state.cart, isNull);
      expect(visits.booked, hasLength(1));
      await bloc.close();
    });

    test('the bar hears about a cart filled somewhere else', () async {
      final visits = VisitRepository();
      final bloc = BasketBloc(visitRepository: visits)
        ..add(const BasketRequested());
      await settle();

      expect(bloc.state.bar, isNull);

      // Added through the repository rather than through this bloc, the way
      // a provider's page does it.
      visits.addService(
        providerName: 'Dev Electricals',
        providerLine: 'Galleria Market 1',
        isVerifiedProvider: true,
        service: const VisitService(
          name: 'Fan Installation',
          detail: 'Ceiling or wall',
          unitPrice: 330,
        ),
      );
      await settle();

      expect(bloc.state.bar?.providerName, 'Dev Electricals');
      expect(bloc.state.cartCount, 1);
      await bloc.close();
    });
  });

  group('search', () {
    test('a trade narrows the results and All puts them back', () async {
      const repository = DiscoveryRepository();
      final bloc = SearchBloc(discoveryRepository: repository)
        ..add(const SearchOpened(localityName: 'Ajnara Gen X'));
      await settle();

      final all = bloc.state.results.length;
      expect(all, greaterThan(0));
      expect(bloc.state.trades, isNotEmpty);

      bloc.add(SearchTradeSelected(bloc.state.trades.first));
      await settle();
      expect(bloc.state.results.length, lessThan(all));

      bloc.add(const SearchTradeSelected(null));
      await settle();
      expect(bloc.state.results, hasLength(all));
      await bloc.close();
    });

    test('the rating chip cycles and comes back to any', () async {
      final bloc = SearchBloc(discoveryRepository: const DiscoveryRepository())
        ..add(const SearchOpened(localityName: 'Ajnara Gen X'));
      await settle();

      expect(bloc.state.ratingLabel, 'Any rating');
      bloc.add(const SearchRatingCycled());
      await settle();
      expect(bloc.state.ratingLabel, '4.0+');
      bloc.add(const SearchRatingCycled());
      await settle();
      expect(bloc.state.ratingLabel, '4.5+');
      bloc.add(const SearchRatingCycled());
      await settle();
      expect(bloc.state.ratingLabel, 'Any rating');
      await bloc.close();
    });
  });

  group('saved providers', () {
    test('the filter chooses between the three sets', () async {
      final bloc = SavedProvidersBloc(meRepository: const MeRepository())
        ..add(const SavedProvidersRequested('Ajnara Gen X'));
      await settle();

      expect(bloc.state.shown, bloc.state.providers);

      bloc.add(const SavedFilterSelected(SavedFilter.openNow));
      await settle();
      expect(bloc.state.shown, bloc.state.openNow);
      expect(bloc.state.shown.every((p) => p.isOpen), isTrue);
      await bloc.close();
    });
  });
}
