import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/learning/presentation/learning_app.dart';
import 'injection.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => createLearningCubit()..load(),
      child: const LearningApp(),
    ),
  );
}
