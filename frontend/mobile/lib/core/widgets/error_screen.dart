import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/error_handler.dart';

class ErrorScreen extends ConsumerWidget {
  final String? message;
  final String? details;
  final VoidCallback? onRetry;
  final bool showRetry;

  const ErrorScreen({
    super.key,
    this.message,
    this.details,
    this.onRetry,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                message ?? 'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (details != null) ...[
                const SizedBox(height: 16),
                Text(
                  details!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showRetry && onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget builder(
    BuildContext context,
    Object? error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
    bool showRetry = true,
  }) {
    String? message;
    String? details;

    if (error is String) {
      message = error;
    } else if (error != null) {
      message = 'An error occurred';
      details = error.toString();
    }

    return ErrorScreen(
      message: message,
      details: details,
      onRetry: onRetry,
      showRetry: showRetry,
    );
  }
}
