import 'package:flutter/material.dart';

/// Tarjeta expandible reutilizable para cada bloque del día.
class DaySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const DaySectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(title, style: theme.textTheme.titleMedium),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [child],
        ),
      ),
    );
  }
}
