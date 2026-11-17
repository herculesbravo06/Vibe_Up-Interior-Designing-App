import 'package:flutter/material.dart';
import 'package:vibe_up/screens/project/project_options_screen.dart';

class NewProjectWizard extends StatefulWidget {
  final Map<String, dynamic>? projectData;
  const NewProjectWizard({super.key, this.projectData});

  @override
  State<NewProjectWizard> createState() => _NewProjectWizardState();
}

class _NewProjectWizardState extends State<NewProjectWizard> {
  final _titleController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Room Details', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text('Enter the dimensions of your space to get started.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Project Title', hintText: 'e.g., Master Bedroom'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: TextField(controller: _heightController, decoration: const InputDecoration(labelText: 'Height (ft)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _widthController, decoration: const InputDecoration(labelText: 'Width (ft)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _depthController,
              decoration: const InputDecoration(labelText: 'Breadth / Depth (ft)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectOptionsScreen(projectData: widget.projectData)));
            },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Step', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
