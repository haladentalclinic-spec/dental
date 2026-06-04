import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../utils/theme.dart';
import '../widgets/app_header.dart';

class WorkDetailScreen extends StatelessWidget {
  final Work work;

  const WorkDetailScreen({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppHeader(title: 'Work Details'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (work.workType != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              work.workType!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (work.teeth != null && work.teeth!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.grid_view_rounded,
                      label: 'Teeth',
                      value: work.teethDisplay,
                    ),
                  if (work.teethColor != null && work.teethColor!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.palette_outlined,
                      label: 'Teeth Color',
                      value: work.teethColor!,
                    ),
                  if (work.doctorName != null)
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Doctor',
                      value: work.doctorName!,
                    ),
                  if (work.patientName != null)
                    _DetailRow(
                      icon: Icons.person_rounded,
                      label: 'Patient',
                      value: work.patientName!,
                    ),
                  if (work.formattedStartDate.isNotEmpty)
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Start Date',
                      value: work.formattedStartDate,
                    ),
                  if (work.formattedDeliveryDate.isNotEmpty)
                    _DetailRow(
                      icon: Icons.event_available_rounded,
                      label: 'Delivery Date',
                      value: work.formattedDeliveryDate,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Note card
          if (work.note != null && work.note!.isNotEmpty)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Note',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      work.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
