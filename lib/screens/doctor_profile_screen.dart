import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  User? _doctor;
  List<Work> _works = [];
  bool _isLoading = true;
  bool _isLoadingWorks = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isLoadingWorks = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        SupabaseService.instance.getUser(widget.doctorId),
        SupabaseService.instance.fetchWorksWithDetails(
          patientId: widget.doctorId,
        ),
      ]);
      setState(() {
        _doctor = results[0] as User?;
        _works = results[1] as List<Work>;
        _isLoading = false;
        _isLoadingWorks = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingWorks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Doctor Profile'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Loading doctor...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: _loadData,
      );
    }

    if (_doctor == null) {
      return const EmptyView(
        message: 'Doctor not found',
        icon: Icons.person_off_rounded,
      );
    }

    final doctor = _doctor!;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                    child: Text(
                      doctor.initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    doctor.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      doctor.role.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact info
                  if (doctor.phone != null && doctor.phone!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      value: doctor.phone!,
                    ),
                  if (doctor.whatsapp != null && doctor.whatsapp!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.chat_rounded,
                      value: doctor.whatsapp!,
                    ),
                  if (doctor.patientCode != null && doctor.patientCode!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      value: doctor.patientCode!,
                    ),

                  const SizedBox(height: 20),

                  // Book Appointment button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _BookingScreenPlaceholder(
                              doctorId: doctor.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Book Appointment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Works section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Works (${_works.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Works list
          if (_isLoadingWorks)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_works.isEmpty)
            const EmptyView(
              message: 'No works yet',
              icon: Icons.medical_services_outlined,
            )
          else
            ..._works.map((work) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (work.workType != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                work.workType!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      if (work.formattedStartDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              work.formattedStartDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder screen for booking — delegates to the real booking screen.
/// Replace with actual import & implementation when available.
class _BookingScreenPlaceholder extends StatelessWidget {
  final String doctorId;

  const _BookingScreenPlaceholder({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    // When BookingScreen is implemented, replace this with:
    // return BookingScreen(doctorId: doctorId);
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Center(
        child: Text(
          'Booking screen for doctor $doctorId',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
