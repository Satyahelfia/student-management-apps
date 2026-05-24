import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DashboardView extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardView({super.key, required this.onNavigate});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;
  int _totalStudents = 0;
  int _totalProjects = 0;
  int _maxProjects = 3;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final students = await ApiService.getStudents();
      final projects = await ApiService.getProjects();
      final maxProj = await ApiService.getMaxProjects();
      
      if (mounted) {
        setState(() {
          _totalStudents = students.length;
          _totalProjects = projects.length;
          _maxProjects = maxProj;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.tertiary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tertiary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showMaxProjectsSettingsDialog() {
    final limitCtrl = TextEditingController(text: _maxProjects.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Configure Max Projects', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set the maximum number of projects that can be assigned to a single student.',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Maximum Projects Limit',
                  hintText: 'e.g. 3',
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
                final input = limitCtrl.text.trim();
                final limit = int.tryParse(input);
                if (limit == null || limit <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive number'), backgroundColor: AppTheme.error),
                  );
                  return;
                }
                
                Navigator.pop(ctx);
                
                bool confirm = await _showConfirmDialog(
                  title: 'Confirm Limit Change',
                  message: 'Apakah Anda yakin ingin mengubah batas maksimum proyek menjadi $limit?',
                );
                
                if (confirm) {
                  setState(() => _isLoading = true);
                  bool success = await ApiService.updateMaxProjects(limit);
                  if (success) {
                    await _loadStats();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Max projects limit updated successfully!'), backgroundColor: AppTheme.secondary),
                      );
                    }
                  } else {
                    setState(() => _isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update limit'), backgroundColor: AppTheme.error),
                      );
                    }
                  }
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Banner
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.tertiary, // Indigo 600
                    Color(0xFF312E81), // Indigo 900
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tertiary.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Here's an overview of your student management system.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.group,
                      iconColor: AppTheme.primary,
                      iconBgColor: AppTheme.primaryContainer,
                      label: 'TOTAL STUDENTS',
                      value: _totalStudents.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.account_tree,
                      iconColor: AppTheme.secondary,
                      iconBgColor: AppTheme.secondaryContainer,
                      label: 'TOTAL PROJECTS',
                      value: _totalProjects.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      iconColor: AppTheme.tertiary,
                      iconBgColor: AppTheme.tertiaryContainer,
                      label: 'AVERAGE SCORE',
                      value: '7.17', // Placeholder/hardcoded average as mock
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.tune,
                      iconColor: AppTheme.error,
                      iconBgColor: AppTheme.errorContainer,
                      label: 'MAX PROJECTS',
                      value: _maxProjects.toString(),
                      onTap: _showMaxProjectsSettingsDialog,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            
            // Quick Actions
            const Row(
              children: [
                Icon(Icons.bolt, color: AppTheme.tertiary),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.person_add,
              iconColor: AppTheme.primary,
              iconBgColor: AppTheme.primaryContainer,
              title: 'Add Student',
              subtitle: 'Register a new student',
              onTap: () => widget.onNavigate(1), // Navigate to Students tab
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.assignment,
              iconColor: AppTheme.secondary,
              iconBgColor: AppTheme.secondaryContainer,
              title: 'Manage Projects',
              subtitle: 'View and create projects',
              onTap: () => widget.onNavigate(2), // Navigate to Projects tab
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (onTap != null)
                const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.outline,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: cardContent,
      );
    }
    return cardContent;
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}
