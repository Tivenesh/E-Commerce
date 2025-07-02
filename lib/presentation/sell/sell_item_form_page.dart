// lib/presentation/sell/sell_item_form_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellItemFormPage extends StatelessWidget {
  final String? itemIdToEdit;

  const SellItemFormPage({super.key, this.itemIdToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final vm = SellItemVM();
        if (itemIdToEdit != null) {
          vm.loadItemForEdit(itemIdToEdit!);
        }
        return vm;
      },
      child: _SellItemForm(itemIdToEdit: itemIdToEdit),
    );
  }
}

class _SellItemForm extends StatefulWidget {
  final String? itemIdToEdit;

  const _SellItemForm({this.itemIdToEdit});

  @override
  State<_SellItemForm> createState() => _SellItemFormStateInternal();
}

class _SellItemFormStateInternal extends State<_SellItemForm> {
  late SellItemVM _vm;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<SellItemVM>(context, listen: false);
    _vm.addListener(_onVmChanged);
    _setControllers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() {
    if (!mounted) return;
    if (_titleController.text != _vm.formState.title) {
      _titleController.text = _vm.formState.title;
    }
    if (_descriptionController.text != _vm.formState.description) {
      _descriptionController.text = _vm.formState.description;
    }
    if (_priceController.text != _vm.formState.price) {
      _priceController.text = _vm.formState.price;
    }
    if (_categoryController.text != _vm.formState.category) {
      _categoryController.text = _vm.formState.category;
    }
    if (_vm.formState.itemType == 'Product' && _quantityController.text != (_vm.formState.quantity ?? '')) {
      _quantityController.text = _vm.formState.quantity ?? '';
    }
    if (_vm.formState.itemType == 'Service' && _durationController.text != (_vm.formState.duration ?? '')) {
      _durationController.text = _vm.formState.duration ?? '';
    }
  }

  void _setControllers() {
    _titleController.text = _vm.formState.title;
    _descriptionController.text = _vm.formState.description;
    _priceController.text = _vm.formState.price;
    _categoryController.text = _vm.formState.category;
    _quantityController.text = _vm.formState.quantity ?? '';
    _durationController.text = _vm.formState.duration ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UPDATED: Consistent AppBar styling
      appBar: AppBar(
        title: Text(
          widget.itemIdToEdit != null ? 'Edit Listing' : 'Add New Listing',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 120, 205), Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // UPDATED: Consistent background gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<SellItemVM>(
          builder: (context, vm, child) {
            if (vm.isLoading && widget.itemIdToEdit != null && vm.formState.title.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UPDATED: Styled Dropdown
                  _buildDropdownField(vm),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    icon: Icons.title,
                    onChanged: (v) => vm.updateField('title', v),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    onChanged: (v) => vm.updateField('description', v),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price (RM)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => vm.updateField('price', v),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Category',
                    icon: Icons.category,
                    onChanged: (v) => vm.updateField('category', v),
                  ),
                  const SizedBox(height: 16),
                  if (vm.formState.itemType == 'Product')
                    _buildTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      icon: Icons.inventory_2,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => vm.updateField('quantity', v),
                    ),
                  if (vm.formState.itemType == 'Service')
                    _buildTextField(
                      controller: _durationController,
                      label: 'Duration (e.g., 1 hour)',
                      icon: Icons.timer,
                      onChanged: (v) => vm.updateField('duration', v),
                    ),
                  const SizedBox(height: 24),
                  // UPDATED: Styled Image Picking Section
                  _buildImagePicker(vm),
                  const SizedBox(height: 32),
                  // UPDATED: Styled Submit Button
                  _buildSubmitButton(vm),
                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Center(
                        child: Text(
                          'Error: ${vm.errorMessage!}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // NEW: Helper method for styled TextFields for consistency
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }

  // NEW: Helper method for styled Dropdown
  Widget _buildDropdownField(SellItemVM vm) {
    return DropdownButtonFormField<String>(
      value: vm.formState.itemType,
      decoration: InputDecoration(
        labelText: 'Item Type',
        prefixIcon: Icon(Icons.sell, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Product', child: Text('Product')),
        DropdownMenuItem(value: 'Service', child: Text('Service')),
      ],
      onChanged: (value) {
        if (value != null) {
          vm.setItemType(value);
        }
      },
    );
  }

  // NEW: Helper method for styled Image Picker section
  Widget _buildImagePicker(SellItemVM vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Column(
            children: [
              // Display selected images
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: vm.selectedImages.map((image) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: image is XFile
                              ? Image.file(File(image.path), fit: BoxFit.cover)
                              : Image.network(image as String, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: InkWell(
                          onTap: () => vm.removeImage(image),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Add Images Button
              OutlinedButton.icon(
                onPressed: vm.pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Images'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NEW: Helper method for styled Submit button
  Widget _buildSubmitButton(SellItemVM vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: vm.isLoading ? null : () async {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You must be logged in to list items.")),
            );
            return;
          }
          try {
            await vm.submitForm(currentUser.uid, widget.itemIdToEdit);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.itemIdToEdit != null ? 'Listing updated successfully!' : 'Listing added successfully!')),
              );
              Navigator.pop(context, true);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${vm.errorMessage ?? e.toString()}')),
              );
            }
          }
        },
        icon: vm.isLoading
            ? Container()
            : Icon(widget.itemIdToEdit != null ? Icons.check_circle : Icons.add_circle),
        label: vm.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(widget.itemIdToEdit != null ? 'Update Listing' : 'Submit Listing'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrangeAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}