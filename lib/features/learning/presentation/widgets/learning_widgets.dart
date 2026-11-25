import 'package:flutter/material.dart';

const ink = Color(0xFF202823);
const muted = Color(0xFF7C837E);
const orange = Color(0xFFED713E);
const paleGreen = Color(0xFFE9F0E7);

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, this.action, this.onAction, super.key});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink)),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: orange),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({required this.url, this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE8ECE7),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, color: muted),
        ),
      );
}

class LoadingView extends StatelessWidget {
  const LoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: orange),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: const TextStyle(color: muted, fontSize: 13)),
            ],
          ],
        ),
      );
}

/// Eroare compactă pentru o secțiune a ecranului (nu tot ecranul).
class InlineError extends StatelessWidget {
  const InlineError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12)),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: orange),
              child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.title,
    required this.message,
    this.icon = Icons.cloud_off_outlined,
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: muted),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink)),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.45)),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ],
          ),
        ),
      );
}
