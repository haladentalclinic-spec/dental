import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';
import 'work_detail_screen.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  List<Work> _works = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = AuthService.instance;
      if (auth.isPatient && auth.currentUserId != null) {
        _works = await SupabaseService.instance
            .fetchWorksWithDetails(patientId: auth.currentUserId);
      } else {
        _works = await SupabaseService.instance.fetchWorksWithDetails();
      }
    } catch (e) {
      _error = 'Failed to load clinics: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Clinics', showBackButton: false),
      body: _loading
          ? const LoadingView(message: 'Loading clinics...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _works.isEmpty
                  ? const EmptyView(
                      message: 'No clinics found',
                      icon: Icons.location_on_rounded,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _works.length,
                        itemBuilder: (context, index) {
                          final w = _works[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkDetailScreen(work: w),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            w.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (w.workType != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              w.workType!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (w.doctorName != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_rounded,
                                            size: 14,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            w.doctorName!,
                                            style: const TextStyle(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (w.formattedStartDate.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            w.formattedStartDate,
                                            style: const TextStyle(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
