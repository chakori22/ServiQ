import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/bloc/home_bloc.dart';
import 'package:local_markerplace/discovery/model/home_feed.dart';
import 'package:local_markerplace/network/failure.dart';

import '../support/fake_home_source.dart';

/// The bloc on its own, without a screen in front of it: what it asks the
/// repository for, and what it says came back.
void main() {
  test(
    'opening an area asks the repository for it and holds the feed',
    () async {
      final source = FakeHomeSource(
        feed: sampleFeed(name: 'Galleria Market 1'),
      );
      final bloc = HomeBloc(homeRepository: source);

      final states = <HomeState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const HomeRequested('galleria-market-1'));
      await Future<void>.delayed(Duration.zero);

      expect(source.requested, ['galleria-market-1']);
      // The skeleton first, then the feed — never the feed out of nowhere.
      expect(states.first.isLoading, isTrue);
      expect(states.last.isLoading, isFalse);
      expect(states.last.localityName, 'Galleria Market 1');
      expect(states.last.categories, hasLength(3));
      expect(states.last.providersNearYou, hasLength(1));
      expect(states.last.failure, isNull);

      await sub.cancel();
      await bloc.close();
    },
  );

  test('a failure is kept with the moment it happened', () async {
    final bloc = HomeBloc(
      homeRepository: FakeHomeSource(
        failure: const Failure(
          errorMessage: 'Service unavailable',
          errorCode: 'HOME_502',
        ),
      ),
    );

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isLoading, isFalse);
    expect(bloc.state.failure?.errorCode, 'HOME_502');
    expect(bloc.state.failedAt, isNotNull);
    // A server fault is not the seeker's connection.
    expect(bloc.state.isOffline, isFalse);

    await bloc.close();
  });

  test('no connection reads as offline rather than as a fault', () async {
    final bloc = HomeBloc(
      homeRepository: FakeHomeSource(
        failure: const Failure(errorCode: 'CONNECTION_ERROR'),
      ),
    );

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isOffline, isTrue);

    await bloc.close();
  });

  test('retrying after a failure clears it', () async {
    final bloc = HomeBloc(homeRepository: _FailsOnceSource(sampleFeed()));

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.failure, isNotNull);

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.failure, isNull);
    expect(bloc.state.failedAt, isNull);
    expect(bloc.state.feed, isNotNull);

    await bloc.close();
  });

  test('pulling to refresh keeps the feed on screen', () async {
    final source = FakeHomeSource(feed: sampleFeed());
    final bloc = HomeBloc(homeRepository: source);

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);

    final states = <HomeState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const HomeRefreshed());
    await Future<void>.delayed(Duration.zero);

    // A refresh has its own indicator, so it never takes the feed away to
    // put a skeleton in its place.
    expect(states.every((state) => !state.isLoading), isTrue);
    expect(states.every((state) => state.feed != null), isTrue);
    expect(states.first.isRefreshing, isTrue);
    expect(states.last.isRefreshing, isFalse);
    // It asks for the area already in state rather than needing to be told.
    expect(source.requested, ['galleria-market-1', 'galleria-market-1']);

    await sub.cancel();
    await bloc.close();
  });

  test('changing area asks for the new one', () async {
    final source = FakeHomeSource();
    final bloc = HomeBloc(homeRepository: source);

    bloc.add(const HomeRequested('galleria-market-1'));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const HomeRequested('ajnara-gen-x'));
    await Future<void>.delayed(Duration.zero);

    expect(source.requested, ['galleria-market-1', 'ajnara-gen-x']);
    expect(bloc.state.localitySlug, 'ajnara-gen-x');

    await bloc.close();
  });
}

/// Fails the first time and answers the second, which is what a retry is
/// meant to survive.
class _FailsOnceSource extends FakeHomeSource {
  _FailsOnceSource(this._feed);

  final HomeFeed _feed;
  int _calls = 0;

  @override
  Future<Either<Failure, HomeFeed>> home({required String localitySlug}) async {
    requested.add(localitySlug);
    _calls++;
    if (_calls == 1) {
      return const Left(Failure(errorCode: 'HOME_502'));
    }
    return Right(_feed);
  }
}
