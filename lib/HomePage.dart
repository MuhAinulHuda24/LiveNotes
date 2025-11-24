import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Asumsi Anda sudah mengimpor `firebase_core` dan menginisialisasi Firebase di main.dart

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Referensi Koleksi Firestore
  final CollectionReference _notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  // Definisi TextEditingController harus berada di dalam _HomePageState
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Menampilkan modal bottom sheet untuk menambahkan / mengedit catatan
  // Jika `document` tidak null -> mode edit
  void _showForm(BuildContext context, [DocumentSnapshot? document]) {
    // Jika edit, isi controller dengan data lama
    if (document != null) {
      _titleController.text = (document['title'] ?? '').toString();
      _contentController.text = (document['content'] ?? '').toString();
    } else {
      // new note: bersihkan
      _titleController.clear();
      _contentController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar keyboard tidak menutupi input
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          // Menambahkan padding di bawah untuk mengakomodasi keyboard
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Isi Catatan'),
              keyboardType:
                  TextInputType.multiline, // Opsional: Untuk input multi-baris
              maxLines: null, // Opsional: Memungkinkan baris tak terbatas
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String title = _titleController.text.trim();
                final String content = _contentController.text.trim();

                // Memastikan konten tidak kosong sebelum menyimpan
                if (content.isNotEmpty) {
                  if (document == null) {
                    // Tambah baru
                    await _notes.add({
                      "title": title.isEmpty ? "Tanpa Judul" : title,
                      "content": content,
                      "timestamp": FieldValue.serverTimestamp(),
                    });
                  } else {
                    // Update existing document
                    await _notes.doc(document.id).update({
                      "title": title.isEmpty ? "Tanpa Judul" : title,
                      "content": content,
                      "timestamp": FieldValue.serverTimestamp(),
                    });
                  }

                  // Bersihkan Input & Tutup Modal setelah selesai
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                document == null ? "Simpan Catatan" : "Perbarui Catatan",
              ),
            ),
            const SizedBox(
              height: 10,
            ), // Tambahkan sedikit ruang di bawah tombol
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Notes Fire")),

      // STREAMBUILDER: Bagian terpenting untuk Real-time
      body: StreamBuilder<QuerySnapshot>(
        // Mengurutkan berdasarkan 'timestamp' terbaru
        stream: _notes.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Kondisi 1: Masih Loading (Tidak ada data)
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kondisi 2: Data Kosong (Memiliki data, tetapi daftar dokumen kosong)
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada catatan."));
          }

          // Kondisi 3: Ada Data -> Tampilkan ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    document['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(document['content']),
                  // Tambah onTap untuk edit
                  onTap: () => _showForm(context, document),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Fungsi Hapus: Hapus dokumen berdasarkan ID
                      _notes.doc(document.id).delete();
                      // Tambahkan feedback ke pengguna (misalnya: SnackBar)
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
