import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/api_exceptions.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context, 
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
    bool showErrorDialog = true,
  }) {
    if (kDebugMode) {
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    if (!showErrorDialog) return;

    String errorMessage = 'An unexpected error occurred. Please try again.';
    String? details;

    if (error is UnauthorizedException) {
      errorMessage = 'Session expired';
      details = 'Please log in again to continue.';
      // TODO: Navigate to login screen
    } else if (error is ForbiddenException) {
      errorMessage = 'Access denied';
      details = 'You do not have permission to perform this action.';
    } else if (error is NotFoundException) {
      errorMessage = 'Not found';
      details = 'The requested resource was not found.';
    } else if (error is BadRequestException) {
      errorMessage = 'Invalid request';
      details = error.message;
    } else if (error is ServerException) {
      errorMessage = 'Server error';
      details = 'Please try again later or contact support if the problem persists.';
    } else if (error is NetworkException) {
      errorMessage = 'No internet connection';
      details = 'Please check your internet connection and try again.';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timed out';
      details = 'The request took too long. Please try again.';
    } else if (error is FormatException) {
      errorMessage = 'Invalid data format';
      details = 'There was a problem processing the data. Please try again.';
    } else if (error is String) {
      errorMessage = error;
    } else if (error is Error) {
      details = error.toString();
    }

    _showErrorDialog(
      context,
      title: errorMessage,
      message: details,
      onRetry: onRetry,
    );
  }

  static void _showErrorDialog(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Widget errorWidget(
    BuildContext context, 
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) {
    // Default error widget that can be used in FutureBuilder/StreamBuilder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'An error occurred',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error is String ? error : error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  /// Creates a widget that catches and handles errors in the widget tree.
  ///
  /// The [onError] callback is called when an error is caught.
  /// The [child] is the widget below this widget in the tree.
  static Widget builder({
    required Widget child,
    required void Function(Object, StackTrace) onError,
  }) {
    return _ErrorHandlerBuilder(
      onError: onError,
      child: child,
    );
  }
}

class _ErrorHandlerBuilder extends StatefulWidget {
  final Widget child;
  final void Function(Object, StackTrace) onError;

  const _ErrorHandlerBuilder({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorHandlerBuilder> createState() => _ErrorHandlerBuilderState();
}

class _ErrorHandlerBuilderState extends State<_ErrorHandlerBuilder> {
  final _errorCompleter = StreamController<FlutterErrorDetails>();
  final _buildErrorCompleter = StreamController<FlutterErrorDetails>();

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _errorCompleter.add(details);
    };

    _errorCompleter.stream.listen(_handleError);
    _buildErrorCompleter.stream.listen(_handleError);
  }

  @override
  void dispose() {
    _errorCompleter.close();
    _buildErrorCompleter.close();
    super.dispose();
  }

  void _handleError(FlutterErrorDetails details) {
    widget.onError(details.exception, details.stack ?? StackTrace.empty);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          if (kDebugMode) {
            print('ErrorWidget.builder: ${errorDetails.exception}');
          }
          _buildErrorCompleter.add(errorDetails);
          return ErrorWidget(errorDetails.exception);
        };

        return widget.child;
      },
    );
  }
}
