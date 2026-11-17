import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibe_up/screens/project/assistance_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_up/services/api_service.dart';

class ProjectDimensionsScreen extends StatefulWidget {
  final Map<String, dynamic>? projectData;
  const ProjectDimensionsScreen({super.key, this.projectData});

  @override
  State<ProjectDimensionsScreen> createState() => _ProjectDimensionsScreenState();
}

class _ProjectDimensionsScreenState extends State<ProjectDimensionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectData != null) {
      _titleController.text = widget.projectData!['name'] ?? '';
      _heightController.text = (widget.projectData!['room_height'] ?? '').toString();
      _widthController.text = (widget.projectData!['room_width'] ?? '').toString();
      _lengthController.text = (widget.projectData!['room_length'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';

      final projectData = {
        if (widget.projectData != null) 'project_id': widget.projectData!['id'],
        'user_id': userId,
        'title': _titleController.text.trim(),
        'dimensions': {
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'width': double.tryParse(_widthController.text) ?? 0.0,
          'length': double.tryParse(_lengthController.text) ?? 0.0,
        }
      };

      final result = widget.projectData == null 
        ? await ApiService.createProject(projectData)
        : await ApiService.updateProject(projectData);

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['status'] == 'success') {
          final projectId = widget.projectData != null 
              ? widget.projectData!['id'].toString() 
              : result['project_id'].toString();
              
          final updatedProjectData = widget.projectData == null 
              ? <String, dynamic>{}
              : Map<String, dynamic>.from(widget.projectData!);
              
          updatedProjectData['room_height'] = double.tryParse(_heightController.text);
          updatedProjectData['room_width'] = double.tryParse(_widthController.text);
          updatedProjectData['room_length'] = double.tryParse(_lengthController.text);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssistanceSelectionScreen(
                projectId: projectId,
                projectName: _titleController.text.trim(),
                projectData: updatedProjectData,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to create project')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error connecting to server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectData == null ? 'New Project' : 'Update Project'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Project Details',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your space to get the best design recommendations.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ).animate().fade(delay: 200.ms).slideX(begin: -0.2),
                const SizedBox(height: 32),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title (e.g., Living Room)',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                Text(
                  'Room Dimensions (ft)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 16),

                // Dimensions row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _widthController,
                        decoration: InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lengthController,
                        decoration: InputDecoration(
                          labelText: 'Length',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ).animate().fade(delay: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Next'),
                ).animate().fade(delay: 600.ms).scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
