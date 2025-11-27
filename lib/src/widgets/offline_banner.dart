import 'package:flutter/material.dart';

/// A banner widget that displays when the map is in offline mode.
///
/// This widget provides visual feedback to users when map tiles cannot be loaded
/// due to network connectivity issues. It offers options to retry connection
/// and can be dismissed by the user.
class MapOfflineBanner extends StatelessWidget {
  const MapOfflineBanner({
    super.key,
    this.backgroundColor,
    this.onRetry,
    this.isDismissible = false,
    this.onDismiss,
  });

  final Color? backgroundColor;
  final VoidCallback? onRetry;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: backgroundColor ?? Colors.red.withOpacity(0.8),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          const Expanded(
            child: Text(
              'Map is offline. Check your internet connection.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isDismissible && onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20.0,
              ),
            ),
        ],
      ),
    );
  }
}