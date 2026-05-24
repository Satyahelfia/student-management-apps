import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  List<dynamic> _projects = [];
  bool _isLoading = true;
  final _nameController = TextEditingController();
  PlatformFile? _pickedPdf;
  PlatformFile? _pickedImage;

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedPdf = result.files.first;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedImage = result.files.first;
      });
    }
  }

  // Search & Pagination state
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 5;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProjects();
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
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    final projects = await ApiService.getProjects();
    if (mounted) {
      setState(() {
        _projects = projects;
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

  Future<void> _deleteProject(int id, String name) async {
    bool confirm = await _showConfirmDialog(
      context: context,
      title: 'Confirm Delete Project',
      message: 'Apakah Anda yakin ingin menghapus proyek "$name" ini?',
      confirmText: 'Delete',
      confirmColor: AppTheme.error,
    );

    if (confirm) {
      bool success = await ApiService.deleteProject(id);
      if (success) {
        _fetchProjects();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully'), backgroundColor: AppTheme.secondary),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete project'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  Future<void> _addProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }

    bool confirm = await _showConfirmDialog(
      context: context,
      title: 'Confirm Add Project',
      message: 'Apakah Anda yakin ingin menambahkan proyek baru "$name"?',
      confirmText: 'Add',
      confirmColor: AppTheme.tertiary,
    );

    if (confirm) {
      bool success = await ApiService.createProject(
        name: name,
        pdfFile: _pickedPdf,
        imageFile: _pickedImage,
      );
      if (success) {
        _nameController.clear();
        setState(() {
          _pickedPdf = null;
          _pickedImage = null;
        });
        _fetchProjects();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project created successfully'), backgroundColor: AppTheme.secondary),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create project'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  void _showEditProjectDialog(Map<String, dynamic> project) {
    final nameCtrl = TextEditingController(text: project['name']);
    PlatformFile? editPickedPdf;
    PlatformFile? editPickedImage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: const Text('Edit Project', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppTheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                editPickedPdf = result.files.first;
                              });
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.tertiary),
                          label: Text(
                            editPickedPdf == null ? 'Attach PDF' : 'PDF: ${editPickedPdf!.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurface),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.outlineVariant),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                editPickedImage = result.files.first;
                              });
                            }
                          },
                          icon: const Icon(Icons.image_outlined, color: AppTheme.tertiary),
                          label: Text(
                            editPickedImage == null ? 'Attach Image' : 'Img: ${editPickedImage!.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurface),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.outlineVariant),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
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
                    if (name.isNotEmpty) {
                      Navigator.pop(ctx);
                      
                      bool confirm = await _showConfirmDialog(
                        context: context,
                        title: 'Confirm Save Changes',
                        message: 'Apakah Anda yakin ingin menyimpan perubahan data proyek ini?',
                        confirmText: 'Save',
                        confirmColor: AppTheme.tertiary,
                      );
                      
                      if (confirm) {
                        bool success = await ApiService.updateProject(
                          id: project['id'],
                          name: name,
                          pdfFile: editPickedPdf,
                          imageFile: editPickedImage,
                        );
                        if (success) {
                          _fetchProjects();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Project updated successfully'), backgroundColor: AppTheme.secondary),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update project'), backgroundColor: AppTheme.error),
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
      },
    );
  }

  // Get filtered list of projects
  List<dynamic> get _filteredProjects {
    if (_searchQuery.trim().isEmpty) {
      return _projects;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _projects.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final id = (p['id'] ?? '').toString().toLowerCase();
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  // Get current page list of projects
  List<dynamic> get _paginatedProjects {
    final filtered = _filteredProjects;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= filtered.length) return [];
    final endIndex = startIndex + _pageSize;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  int get _totalPages {
    final len = _filteredProjects.length;
    if (len == 0) return 1;
    return (len / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final paginated = _paginatedProjects;
    final totalPagesCount = _totalPages;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Project List',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'A list of all available projects in the system.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
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
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROJECT REGISTRY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.outline,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${_filteredProjects.length} of ${_projects.length} projects',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          else if (_filteredProjects.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No projects found.', style: TextStyle(color: AppTheme.outlineVariant)),
              ),
            )
          else ...[
            ...paginated.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildProjectCard(
                  id: p['id'].toString(),
                  name: p['name'] ?? 'Unknown Project',
                  icon: Icons.dataset,
                  color: AppTheme.secondary,
                  bgColor: AppTheme.secondaryContainer.withOpacity(0.2),
                  onEdit: () => _showEditProjectDialog(p),
                  onDelete: () => _deleteProject(p['id'], p['name'] ?? ''),
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
          
          const SizedBox(height: 32),
          const Divider(color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          
          const Row(
            children: [
              Icon(Icons.add_box, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Add New Project',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  'PROJECT NAME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Enter project name',
                    hintStyle: const TextStyle(color: AppTheme.outline),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.tertiary),
                        label: Text(
                          _pickedPdf == null ? 'Attach PDF' : 'PDF: ${_pickedPdf!.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.onSurface),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined, color: AppTheme.tertiary),
                        label: Text(
                          _pickedImage == null ? 'Attach Image' : 'Img: ${_pickedImage!.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.onSurface),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addProject,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tertiaryContainer,
                    foregroundColor: AppTheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer, // Premium Pure White
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryContainer, // Cohesive light pastel blue/indigo
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(Icons.dataset_outlined, color: AppTheme.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ID: $id',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant, // Readable Slate 500
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
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
