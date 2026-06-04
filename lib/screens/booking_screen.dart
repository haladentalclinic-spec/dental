import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/app_header.dart';

class BookingScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  const BookingScreen({super.key, required this.doctorId, required this.doctorName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _loading = false;

  final _morningSlots = ['09:00', '10:00', '11:00'];
  final _afternoonSlots = ['13:00', '14:00', '15:00', '16:00'];

  List<DateTime> get _dates {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  Future<void> _confirm() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.instance.createWork({
        'title': 'Appointment with Dr. ${widget.doctorName}',
        'doctor_id': widget.doctorId,
        'patient_id': AuthService.instance.currentUserId,
        'start_date': _selectedDate.toIso8601String().split('T').first,
        'work_type': 'appointment',
        'created_by': AuthService.instance.currentUserId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book: $e')),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Book Appointment'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Doctor: ${widget.doctorName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                final d = _dates[index];
                final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                final isToday = d.day == DateTime.now().day;
                final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = d),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(weekdays[d.weekday - 1], style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.onSurfaceVariant)),
                        Text('${d.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.onSurface)),
                        if (isToday)
                          Text('Today', style: TextStyle(fontSize: 9, color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Morning', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _morningSlots.map((t) => _timeChip(t)).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Afternoon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _afternoonSlots.map((t) => _timeChip(t)).toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Appointment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String time) {
    final isSelected = _selectedTime == time;
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (v) => setState(() => _selectedTime = v ? time : null),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
