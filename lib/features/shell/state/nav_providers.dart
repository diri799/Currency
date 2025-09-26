// Riverpod v3 core import for state (non-widget file)
import 'package:riverpod/riverpod.dart';

/// Current tab index for bottom navigation
final navIndexProvider = StateProvider<int>((_) => 0);
