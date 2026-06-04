import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/loading_view.dart';
import '../widgets/app_header.dart';
import '../models/app_models.dart';
import 'work_detail_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  User? _patient;
  List<Work> _works = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _patient = await SupabaseService.instance.getUser(widget.patientId);
      _works = await SupabaseService.instance.fetchWorksWithDetails(patientId: widget.patientId);
    } catch (e) {
      _error = 'Failed to load: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showAddWorkDialog() {
    final titleCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Treatment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
              const SizedBox(height: 12),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Work Type')),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await SupabaseService.instance.createWork({
                'title': titleCtrl.text.trim(),
                'work_type': typeCtrl.text.trim().isEmpty ? null : typeCtrl.text.trim(),
                'note': noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                'patient_id': widget.patientId,
                'created_by': AuthService.instance.currentUserId,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Patient Details'),
      body: _loading
          ? const LoadingView(message: 'Loading...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _patient == null
                  ? const EmptyView(message: 'Patient not found', icon: Icons.person_off_rounded)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(_patient!.initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(_patient!.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  if (_patient!.patientCode != null)
                                    Text('Code: ${_patient!.patientCode}', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                                  const SizedBox(height: 16),
                                  if (_patient!.phone != null) _infoRow(Icons.phone_rounded, 'Phone', _patient!.phone!),
                                  if (_patient!.gender != null) _infoRow(Icons.wc_rounded, 'Gender', _patient!.gender!),
                                  if (_patient!.age != null) _infoRow(Icons.numbers_rounded, 'Age', '${_patient!.age}'),
                                  if (_patient!.bloodType != null) _infoRow(Icons.water_drop_rounded, 'Blood Type', _patient!.bloodType!),
                                  if (_patient!.disease != null) _infoRow(Icons.healing_rounded, 'Disease', _patient!.disease!),
                                  if (_patient!.allergies != null) _infoRow(Icons.warning_rounded, 'Allergies', _patient!.allergies!),
                                  if (_patient!.address != null) _infoRow(Icons.location_on_rounded, 'Address', _patient!.address!),
                                  if (_patient!.note != null) _infoRow(Icons.note_rounded, 'Note', _patient!.note!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Treatments (${_works.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ..._works.map((w) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.medical_services_rounded, color: AppColors.primary),
                                  title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('${w.workType ?? ''} • ${w.formattedStartDate}'),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkDetailScreen(work: w))),
                                ),
                              )),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
