import 'package:flutter/material.dart';
import 'keyboard_dismissible.dart';

/// Template untuk halaman dengan form
/// 
/// Gunakan template ini sebagai referensi untuk membuat halaman baru
/// yang memiliki form input agar keyboard handling sudah benar
class FormPageTemplate extends StatelessWidget {
  const FormPageTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        // PENTING: gunakan true agar layout menyesuaikan keyboard
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Form Page'),
        ),
        body: SingleChildScrollView(
          // PENTING: tambahkan ini agar keyboard tertutup saat scroll
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Form fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email',
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                onPressed: () {
                  // PENTING: tutup keyboard sebelum submit
                  FocusManager.instance.primaryFocus?.unfocus();
                  
                  // Proses submit form
                  _submitForm();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Implementasi submit form
  }
}
