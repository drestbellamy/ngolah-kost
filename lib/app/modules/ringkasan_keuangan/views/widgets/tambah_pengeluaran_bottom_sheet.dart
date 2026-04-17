import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Custom formatter untuk currency
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericString.isEmpty) {
      return const TextEditingValue();
    }

    // Parse and format
    final number = int.tryParse(numericString);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TambahPengeluaranBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const TambahPengeluaranBottomSheet({super.key, this.initialData});

  @override
  State<TambahPengeluaranBottomSheet> createState() =>
      _TambahPengeluaranBottomSheetState();
}

class _TambahPengeluaranBottomSheetState
    extends State<TambahPengeluaranBottomSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  late DateTime selectedDate;

  String? titleError;
  String? descriptionError;
  String? amountError;

  // Currency formatter
  final NumberFormat _currencyFormatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.initialData?['nama']?.toString() ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.initialData?['deskripsi']?.toString() ?? '',
    );
    amountController = TextEditingController(
      text: widget.initialData != null
          ? _extractAmount(widget.initialData!['jumlah'])
          : '',
    );
    selectedDate = widget.initialData != null
        ? _parseDate(widget.initialData!['tanggal'])
        : DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String _extractAmount(dynamic jumlah) {
    if (jumlah == null) return '';
    if (jumlah is int) return _currencyFormatter.format(jumlah);
    if (jumlah is double) return _currencyFormatter.format(jumlah.toInt());
    final str = jumlah.toString();
    final numOnly = str.replaceAll(RegExp(r'[^0-9]'), '');
    if (numOnly.isEmpty) return '';
    final number = int.tryParse(numOnly) ?? 0;
    return _currencyFormatter.format(number);
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    try {
      return DateTime.parse(dateValue.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  bool _validate() {
    setState(() {
      titleError = null;
      descriptionError = null;
      amountError = null;
    });

    bool isValid = true;

    if (titleController.text.trim().isEmpty) {
      setState(() => titleError = 'Judul harus diisi');
      isValid = false;
    }

    if (descriptionController.text.trim().isEmpty) {
      setState(() => descriptionError = 'Deskripsi harus diisi');
      isValid = false;
    }

    if (amountController.text.trim().isEmpty) {
      setState(() => amountError = 'Jumlah harus diisi');
      isValid = false;
    } else {
      final amount = double.tryParse(
        amountController.text.trim().replaceAll(',', ''),
      );
      if (amount == null || amount <= 0) {
        setState(
          () =>
              amountError = 'Jumlah harus berupa angka valid dan lebih dari 0',
        );
        isValid = false;
      }
    }

    return isValid;
  }

  void _submit() {
    if (_validate()) {
      Get.back(
        result: {
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'amount': amountController.text.trim(),
          'date': selectedDate,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialData == null
                          ? 'Tambah Pengeluaran'
                          : 'Edit Pengeluaran',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Form with scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Judul',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Pemeliharaan',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          errorText: titleError,
                        ),
                        onChanged: (value) {
                          if (titleError != null) {
                            setState(() => titleError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan deskripsi pengeluaran',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          errorText: descriptionError,
                        ),
                        onChanged: (value) {
                          if (descriptionError != null) {
                            setState(() => descriptionError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Amount
                      const Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        decoration: InputDecoration(
                          hintText: 'Contoh: 500,000',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixText: 'Rp ',
                          filled: true,
                          fillColor: const Color(0xFFF7F9F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          errorText: amountError,
                        ),
                        onChanged: (value) {
                          if (amountError != null) {
                            setState(() => amountError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Date
                      const Text(
                        'Tanggal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2F2F2F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B8E7A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
