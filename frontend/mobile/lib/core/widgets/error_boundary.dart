import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/error_handler.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();

  static Widget builder(
    BuildContext context,
    Widget child, {
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      child: child,
    );
  }
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _error = null;
    _stackTrace = null;
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _error = null;
      _stackTrace = null;
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    // Also log the error
    if (kDebugMode) {
      print('ErrorBoundary caught error: $error');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }

      return ErrorHandler.errorWidget(
        context,
        _error!,
        stackTrace: _stackTrace,
        onRetry: () => setState(() {
          _error = null;
          _stackTrace = null;
        }),
      );
    }

    return ErrorHandler.builder(
      onError: _handleError,
      child: widget.child,
    );
  }
}

extension ErrorHandlerExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      child: this,
    );
  }
}
