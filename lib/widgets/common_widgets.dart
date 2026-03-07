import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData icon;
  final Color iconColor;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    required this.icon,
    this.iconColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const Gap(6),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
            const Gap(8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}

class ErrorWidget extends StatelessWidget {
  final String message;

  const ErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const Gap(8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
}

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const Gap(12),
            Text(message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      );
}

class AmountText extends StatelessWidget {
  final double amount;
  final bool showSign;

  const AmountText({super.key, required this.amount, this.showSign = false});

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final sign = showSign ? (isPositive ? '+' : '') : '';
    final color = showSign
        ? (isPositive ? Colors.green.shade700 : Colors.red.shade700)
        : null;

    return Text(
      '$sign${amount.toStringAsFixed(2)} ৳',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
