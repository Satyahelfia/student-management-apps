import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AssignmentsView extends StatefulWidget {
  const AssignmentsView({super.key});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  List<dynamic> _students = [];
  List<dynamic> _projects = [];
  bool _isLoading = true;

  int? _selectedStudentId;
  int? _selectedProjectId;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final students = await ApiService.getStudents();
    final projects = await ApiService.getProjects();
    if (mounted) {
      setState(() {
        _students = students;
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return "$y-$m-${d}T$h:$min:$s";
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.tertiaryContainer,
              onPrimary: AppTheme.onTertiaryContainer,
              surface: AppTheme.surface,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.tertiaryContainer,
              onPrimary: AppTheme.onTertiaryContainer,
              surface: AppTheme.surface,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startDate = combined;
      } else {
        _endDate = combined;
      }
    });
  }

  Future<bool> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppTheme.tertiary,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                cancelText,
                style: const TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _assignProject() async {
    if (_selectedStudentId == null || _selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a student and a project')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set both start and end dates')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final startStr = _formatDateTime(_startDate!);
    final endStr = _formatDateTime(_endDate!);

    bool confirm = await _showConfirmDialog(
      context: context,
      title: 'Confirm Assign Project',
      message: 'Apakah Anda yakin ingin menugaskan proyek ini kepada siswa yang dipilih dari tanggal $startStr s/d $endStr?',
      confirmText: 'Assign',
      confirmColor: AppTheme.tertiary,
    );

    if (confirm) {
      bool success = await ApiService.assignProjectToStudent(
        _selectedStudentId!,
        _selectedProjectId!,
        startDate: startStr,
        endDate: endStr,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project assigned successfully!'), backgroundColor: AppTheme.secondary),
        );
        setState(() {
          _selectedStudentId = null;
          _selectedProjectId = null;
          _startDate = null;
          _endDate = null;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to assign project'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Assign Projects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manually assign a project to a student with a deadline.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SELECT STUDENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedStudentId,
                  dropdownColor: AppTheme.surfaceContainerHigh,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _students.map((s) {
                    return DropdownMenuItem<int>(
                      value: s['id'],
                      child: Text('${s['name']} (ID: ${s['id']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedStudentId = val);
                  },
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'SELECT PROJECT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedProjectId,
                  dropdownColor: AppTheme.surfaceContainerHigh,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _projects.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'],
                      child: Text('${p['name']} (ID: ${p['id']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedProjectId = val);
                  },
                ),
                const SizedBox(height: 24),

                // Start Date & Time
                const Text(
                  'START DATE & TIME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDateTime(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? _formatDateTime(_startDate!)
                              : 'Select Start Date & Time',
                          style: TextStyle(
                            color: _startDate != null ? AppTheme.onSurface : AppTheme.outline,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AppTheme.outline),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // End Date & Time (Deadline)
                const Text(
                  'END DATE & TIME (DEADLINE)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDateTime(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? _formatDateTime(_endDate!)
                              : 'Select End Date & Time',
                          style: TextStyle(
                            color: _endDate != null ? AppTheme.onSurface : AppTheme.outline,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AppTheme.outline),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                ElevatedButton.icon(
                  onPressed: _assignProject,
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Assign Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
