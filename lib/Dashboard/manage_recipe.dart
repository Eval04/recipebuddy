import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRecipePage extends StatefulWidget {
  const ManageRecipePage({super.key});

  @override
  State<ManageRecipePage> createState() => _ManageRecipePageState();
}

class _ManageRecipePageState extends State<ManageRecipePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _servingController = TextEditingController(); // 🔹 Tambahkan controller

  void _showRecipeForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _descController.text = data['desc'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _ingredientsController.text = data['ingredients'] ?? '';
      _stepsController.text = data['steps'] ?? '';
      _servingController.text = data['serving'] ?? ''; // 🔹 Load servings
    } else {
      _titleController.clear();
      _descController.clear();
      _durationController.clear();
      _ingredientsController.clear();
      _stepsController.clear();
      _servingController.clear();
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(doc == null ? 'Tambah Resep' : 'Edit Resep'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Judul'),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Durasi'),
                  ),
                  TextField(
                    controller: _servingController,
                    decoration: const InputDecoration(labelText: 'Porsi'),
                  ), // 🔹 Tambah input servings
                  TextField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(labelText: 'Bahan-bahan'),
                  ),
                  TextField(
                    controller: _stepsController,
                    decoration: const InputDecoration(
                      labelText: 'Langkah-langkah',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final recipe = {
                    'title': _titleController.text.trim(),
                    'desc': _descController.text.trim(),
                    'duration': _durationController.text.trim(),
                    'serving':
                        _servingController.text.trim(), // 🔹 Simpan servings
                    'ingredients': _ingredientsController.text.trim(),
                    'steps': _stepsController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  };

                  if (doc == null) {
                    await FirebaseFirestore.instance
                        .collection('recipes')
                        .add(recipe);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('recipes')
                        .doc(doc.id)
                        .update(recipe);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _deleteRecipe(String id) async {
    await FirebaseFirestore.instance.collection('recipes').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Resep'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRecipeForm(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada resep.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['title'] ?? '-'),
                  subtitle: Text(
                    "Durasi: ${data['duration'] ?? '-'} | Porsi: ${data['serving'] ?? '-'}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showRecipeForm(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecipe(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
