import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<User> _patients = [];
  List<User> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _patients.where((p) => p.fullName.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _patients = await SupabaseService.instance.fetchPatients();
      _filtered = List.from(_patients);
    } catch (e) {
      _error = 'Failed to load patients: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isAdmin && !AuthService.instance.isDoctor) {
      return Scaffold(
        appBar: const AppHeader(title: 'Patients'),
        body: const Center(child: Text('Access restricted to admin/doctor only')),
      );
    }
    return Scaffold(
      appBar: const AppHeader(title: 'Patients', showBackButton: true),
      body: _loading
          ? const LoadingView(message: 'Loading patients...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Search patients...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: _filtered.isEmpty
                            ? const EmptyView(message: 'No patients found', icon: Icons.people_outline_rounded)
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) {
                                  final p = _filtered[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                        child: Text(p.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                      ),
                                      title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text('${p.patientCode ?? ''}  \u2022  ${p.phone ?? ''}'),
                                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: p.id))),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
