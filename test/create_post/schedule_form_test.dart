import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/bloc/create_post_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/schedule/schedule_form.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

CreatePostBloc _bloc() =>
    CreatePostBloc(dashboardRepository: const DashboardRepository());

/// A state with every field the instant form requires already filled.
CreatePostState _filledState() => const CreatePostState.initial().copyWith(
      selectedcategory: 'Plumbing',
      description: 'Kitchen tap is dripping',
      budget: '500',
      imagePath: '/tmp/photo.jpg',
    );

void main() {
  test('selecting a date loads the slots for that day from the repository',
      () async {
    final bloc = _bloc();
    final date = DateTime.now().add(const Duration(days: 2));

    bloc.add(OnSelectDate(date));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state.timeSlotsLoading, isTrue);
    expect(bloc.state.selectedDate, date);

    await Future<void>.delayed(const Duration(seconds: 2));
    expect(bloc.state.timeSlotsLoading, isFalse);
    expect(bloc.state.timeSlots, isNotEmpty);
    // Slots belong to the chosen day.
    expect(bloc.state.timeSlots.first.startTime.day, date.day);
    await bloc.close();
  });

  test('picking a different date clears the slot chosen for the old one',
      () async {
    final bloc = _bloc();
    final firstDate = DateTime.now().add(const Duration(days: 2));

    bloc.add(OnSelectDate(firstDate));
    await Future<void>.delayed(const Duration(seconds: 2));
    final slot = bloc.state.timeSlots.firstWhere((s) => s.isAvailable);
    bloc.add(OnSelectTimeSlot(slot.id));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(bloc.state.selectedTimeSlot, isNotNull);

    bloc.add(OnSelectDate(firstDate.add(const Duration(days: 1))));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state.selectedTimeSlotId, isEmpty);
    expect(bloc.state.selectedTimeSlot, isNull);
    await bloc.close();
  });

  test('schedule validity needs the instant fields plus a date and a slot',
      () async {
    final filled = _filledState();
    expect(filled.isFormValid, isTrue, reason: 'instant form is satisfied');
    expect(filled.isScheduleFormValid, isFalse, reason: 'no date or slot yet');

    final bloc = _bloc();
    bloc.add(OnSelectDate(DateTime.now().add(const Duration(days: 2))));
    await Future<void>.delayed(const Duration(seconds: 2));
    final slots = bloc.state.timeSlots;
    await bloc.close();

    final withDateOnly = filled.copyWith(
      selectedDate: DateTime.now(),
      timeSlots: slots,
    );
    expect(withDateOnly.isScheduleFormValid, isFalse);

    final withSlot = withDateOnly.copyWith(
      selectedTimeSlotId: slots.firstWhere((s) => s.isAvailable).id,
    );
    expect(withSlot.isScheduleFormValid, isTrue);
  });

  testWidgets('form asks for a date before showing any times', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.scheduleForm.path,
        routes: createRoutes(),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.byType(ScheduleFormPage), findsOneWidget);
    expect(find.text('Select date'), findsOneWidget);
    expect(
      find.text('Pick a date to see the times available.'),
      findsOneWidget,
    );
    // Nothing is filled in, so the form can't be submitted.
    expect(tester.widget<PrimaryButton>(find.byType(PrimaryButton)).enabled,
        isFalse);
  });

  testWidgets('Schedule for Later on the dashboard opens the form',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.home.path,
        routes: createRoutes(),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Schedule for\nLater'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.byType(ScheduleFormPage), findsOneWidget);
  });

  test('only bookable windows are offered to the form', () async {
    final bloc = _bloc();
    // Tomorrow, so no window is filtered out merely for being in the past.
    bloc.add(OnSelectDate(DateTime.now().add(const Duration(days: 1))));
    await Future<void>.delayed(const Duration(seconds: 2));

    final all = bloc.state.timeSlots;
    final available = bloc.state.availableTimeSlots;
    expect(all.any((slot) => !slot.isAvailable), isTrue,
        reason: 'the day has some taken windows to filter out');
    expect(available.every((slot) => slot.isAvailable), isTrue);
    expect(available.length, lessThan(all.length));
    await bloc.close();
  });

  testWidgets('date field matches the other inputs and opens the calendar',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.scheduleForm.path,
        routes: createRoutes(),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));

    // Rendered through the shared component, with a floating label like the
    // category / description / budget fields above it.
    final dateField = find.ancestor(
      of: find.text('Select date'),
      matching: find.byType(AppTextField),
    );
    expect(dateField, findsOneWidget);
    expect(tester.widget<AppTextField>(dateField).floatingLabel, isTrue);
    expect(tester.widget<AppTextField>(dateField).labelText, 'Date');

    // The photo picker carries a floating label too.
    expect(find.text('Photo'), findsOneWidget);

    // Tap through the field's own area: the inner TextField is wrapped in an
    // AbsorbPointer, so the gesture belongs to the wrapper around it.
    await tester.tapAt(tester.getCenter(dateField));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
