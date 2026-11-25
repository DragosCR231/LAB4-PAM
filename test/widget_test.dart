import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_api_v4/features/learning/presentation/cubit/learning_cubit.dart';
import 'package:learning_api_v4/features/learning/presentation/learning_app.dart';
import 'package:learning_api_v4/injection.dart';

import 'helpers.dart';

void main() {
  testWidgets('shows API data on home, course overview and lesson details', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // În teste, Image.network primește 400, deci imaginile nu se pot încărca.
    final reportError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is! NetworkImageLoadException) reportError?.call(details);
    };

    final cubit = createLearningCubit(httpClient: fakeApi());
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: const LearningApp()));
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.runAsync(cubit.load);
    await tester.pumpAndSettle();

    expect(cubit.state.homeStatus, LoadStatus.success, reason: cubit.state.homeError);
    expect(find.text('Hi, Kristin'), findsOneWidget);
    expect(find.text('React Front To back'), findsOneWidget);

    await tester.tap(find.text('React Front To back'));
    await tester.pumpAndSettle();
    expect(find.text('Course Overview'), findsOneWidget);

    await tester.tap(find.text('Understanding React'));
    await tester.pumpAndSettle();
    expect(find.text('LESSON 2 OF 4'), findsOneWidget);

    await tester.tap(find.text('Mark as completed'));
    await tester.pump();
    expect(cubit.state.completedIds, contains('lesson-2'));
    FlutterError.onError = reportError;
  });

  testWidgets('shows an error with retry when the server fails', (tester) async {
    final cubit = createLearningCubit(httpClient: fakeApi(feedStatus: 500));
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: const LearningApp()));
    await tester.runAsync(cubit.load);
    await tester.pumpAndSettle();

    expect(find.text('Could not load your learning data'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
