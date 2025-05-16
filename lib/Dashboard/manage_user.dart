import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showUserForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _nameController.text = data['username'] ?? '';
      _emailController.text = data['email'] ?? '';
      _passwordController.text = ''; // password tidak disimpan di Firestore
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(doc == null ? 'Tambah User' : 'Edit User'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
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
                  final username = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (doc == null) {
                    try {
                      final cred = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(cred.user!.uid)
                          .set({
                            'username': username,
                            'email': email,
                            'role': 'user',
                          });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal tambah user: $e')),
                      );
                    }
                  } else {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(doc.id)
                        .update({'username': username, 'email': email});

                    if (password.isNotEmpty) {
                      try {
                        // Tidak dapat mengubah password dari admin secara langsung
                        // butuh user login untuk update password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password hanya bisa diubah oleh user itu sendiri.',
                            ),
                          ),
                        );
                      } catch (_) {}
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(doc == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUser(String userId, String email, String password) async {
    try {
      final adminEmail = 'ADMIN_EMAIL';
      final adminPassword = 'ADMIN_PASSWORD';

      // Simpan session admin
      final adminCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      // Login sebagai user yang ingin dihapus
      final targetCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hapus akun FirebaseAuth
      await targetCred.user?.delete();

      // Login kembali sebagai admin
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminCred.user!.email!,
        password: adminPassword,
      );

      // Hapus dari Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['username'] ?? ''),
                subtitle: Text(data['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showUserForm(doc: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(
                          context,
                          doc.id,
                          data['email'],
                          _passwordController.text,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _showUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String userId,
    String email,
    String password,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Yakin ingin menghapus user ini dari Auth & Firestore?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(userId, email, password);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
