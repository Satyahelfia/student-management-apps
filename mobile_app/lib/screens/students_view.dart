import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  // Search & Pagination state
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 5;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 1; // Reset to page 1 on search
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    final students = await ApiService.getStudents();
    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
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

  Future<void> _deleteStudent(int id, String name) async {
    bool confirm = await _showConfirmDialog(
      context: context,
      title: 'Confirm Delete Student',
      message: 'Apakah Anda yakin ingin menghapus siswa "$name" ini?',
      confirmText: 'Delete',
      confirmColor: AppTheme.error,
    );
    
    if (confirm) {
      bool success = await ApiService.deleteStudent(id);
      if (success) {
        _fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully'), backgroundColor: AppTheme.secondary),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete student'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final avgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Add Student', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avgCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Average Score',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final avg = double.tryParse(avgCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  
                  bool confirm = await _showConfirmDialog(
                    context: context,
                    title: 'Confirm Add Student',
                    message: 'Apakah Anda yakin ingin menambahkan siswa baru "$name" ini?',
                    confirmText: 'Add',
                    confirmColor: AppTheme.tertiary,
                  );
                  
                  if (confirm) {
                    bool success = await ApiService.createStudent(name, avg);
                    if (success) {
                      _fetchStudents();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Student added successfully'), backgroundColor: AppTheme.secondary),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to add student'), backgroundColor: AppTheme.error),
                        );
                      }
                    }
                  }
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final nameCtrl = TextEditingController(text: student['name']);
    final avgCtrl = TextEditingController(text: (student['average'] ?? 0.0).toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Edit Student', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avgCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Average Score',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final avg = double.tryParse(avgCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  
                  bool confirm = await _showConfirmDialog(
                    context: context,
                    title: 'Confirm Save Changes',
                    message: 'Apakah Anda yakin ingin menyimpan perubahan data siswa ini?',
                    confirmText: 'Save',
                    confirmColor: AppTheme.tertiary,
                  );
                  
                  if (confirm) {
                    bool success = await ApiService.updateStudent(student['id'], name, avg);
                    if (success) {
                      _fetchStudents();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Student updated successfully'), backgroundColor: AppTheme.secondary),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update student'), backgroundColor: AppTheme.error),
                        );
                      }
                    }
                  }
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Get filtered list of students
  List<dynamic> get _filteredStudents {
    if (_searchQuery.trim().isEmpty) {
      return _students;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _students.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final id = (s['id'] ?? '').toString().toLowerCase();
      final avg = (s['average'] ?? '').toString().toLowerCase();
      return name.contains(query) || id.contains(query) || avg.contains(query);
    }).toList();
  }

  // Get current page list of students
  List<dynamic> get _paginatedStudents {
    final filtered = _filteredStudents;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= filtered.length) return [];
    final endIndex = startIndex + _pageSize;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  int get _totalPages {
    final len = _filteredStudents.length;
    if (len == 0) return 1;
    return (len / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    // Stats overview should show calculated stats for all active students (or filtered ones)
    final totalStudents = _students.length;
    double totalScore = 0;
    for (var s in _students) {
      totalScore += (s['average'] ?? 0.0);
    }
    final avgClassScore = totalStudents > 0 ? (totalScore / totalStudents).toStringAsFixed(1) : '0.0';

    final paginated = _paginatedStudents;
    final totalPagesCount = _totalPages;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or average...',
                    hintStyle: const TextStyle(color: AppTheme.outline),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.outline),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Overview
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL STUDENTS',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant, // Readable and premium Slate 500
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalStudents',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVG. CLASS SCORE',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant, // Readable and premium Slate 500
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avgClassScore,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          const Text(
            'ACTIVE STUDENTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          else if (_filteredStudents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No students found.', style: TextStyle(color: AppTheme.outlineVariant)),
              ),
            )
          else ...[
            ...paginated.map((student) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildStudentCard(
                  id: student['id'].toString(),
                  name: student['name'] ?? 'Unknown',
                  score: (student['average'] ?? 0.0).toString(),
                  avatarChar: (student['name'] ?? 'U')[0].toUpperCase(),
                  avatarColor: AppTheme.primary,
                  onEdit: () => _showEditStudentDialog(student),
                  onDelete: () => _deleteStudent(student['id'], student['name'] ?? ''),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 16),
            
            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.onSurface),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  'Page $_currentPage of $totalPagesCount',
                  style: const TextStyle(color: AppTheme.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.onSurface),
                  onPressed: _currentPage < totalPagesCount
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard({
    required String id,
    required String name,
    required String score,
    required String avatarChar,
    required Color avatarColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final double numScore = double.tryParse(score) ?? 0.0;
    final Color badgeBg;
    final Color badgeText;
    if (numScore >= 7.0) {
      badgeBg = AppTheme.secondaryContainer; // Pastel Teal
      badgeText = AppTheme.secondary;        // Teal 600
    } else if (numScore >= 5.0) {
      badgeBg = const Color(0xFFFEF3C7);     // Soft Amber
      badgeText = const Color(0xFFD97706);    // Amber 600
    } else {
      badgeBg = AppTheme.errorContainer;     // Soft Rose
      badgeText = AppTheme.error;            // Rose 600
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryContainer, // Indigo 50
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Text(
              avatarChar,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.tertiary, // Indigo 600
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: $id',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant, // High contrast and readable
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: badgeText.withOpacity(0.15)),
            ),
            child: Text(
              score,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppTheme.tertiary,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            color: AppTheme.error.withOpacity(0.8),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
