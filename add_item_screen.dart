import 'package:flutter/material.dart';

import '../models/item_model.dart';

const _kGradientStart = Color(0xFF4F46E5); // indigo
const _kCardBg = Colors.white;

// =========================================================================
// SCREEN 5 — FORM TAMBAH / UBAH DATA
// Tambah dan ubah data (parameter item): Admin & Super Admin.
// =========================================================================
class AddItemScreen extends StatefulWidget {
  // Bila diisi, form berjalan dalam mode ubah data.
  final ItemModel? item;

  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = kCategoryIcons.keys.toList();
  String? _selectedCategory;
  TaskStatus _selectedStatus = TaskStatus.belumSelesai;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description ?? '';
      _selectedCategory = item.category;
      _selectedStatus = item.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Nama barang/tugas tidak boleh kosong';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Silakan pilih kategori terlebih dahulu'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    final newItem = ItemModel(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      status: _selectedStatus,
      description: _descriptionController.text.trim(),
      addedBy: widget.item?.addedBy ?? AppData.currentUser!.name,
    );
    Navigator.pop(context, newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Data' : 'Tambah Data'),
        backgroundColor: _kGradientStart,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Nama Barang / Tugas',
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Buku Tulis, Laporan PKL...',
                    prefixIcon: Icon(Icons.edit_rounded),
                  ),
                  validator: _validateName,
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Kategori',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    hintText: 'Pilih kategori',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(kCategoryIcons[c],
                                    size: 18, color: _kGradientStart),
                                const SizedBox(width: 8),
                                Text(c),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Keterangan',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Catatan tambahan (opsional)...',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Status',
                child: Wrap(
                  spacing: 10,
                  children: TaskStatus.values.map((status) {
                    final bool isSelected = _selectedStatus == status;
                    final label = status == TaskStatus.selesai
                        ? 'Selesai'
                        : 'Belum Selesai';
                    final color = status == TaskStatus.selesai
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C);
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedStatus = status),
                      selectedColor: color.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: isSelected ? color : Colors.grey.shade300),
                      ),
                      backgroundColor: Colors.white,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGradientStart,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration([double radius = 18]) => BoxDecoration(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

// Pembungkus tiap bagian form
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}