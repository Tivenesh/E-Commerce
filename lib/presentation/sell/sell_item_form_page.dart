// File: lib/presentation/sell/sell_item_form_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart'; // Import the SellItemVM

class SellItemFormPage extends StatelessWidget {
  final String? itemIdToEdit; // Optional: Pass item ID for editing

  const SellItemFormPage({super.key, this.itemIdToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellItemVM(), // Create a new VM instance for the form
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
  // Add controllers for text fields to pre-fill data if editing
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  late SellItemVM _vm; // Declare _vm

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = Provider.of<SellItemVM>(context, listen: false);
      if (widget.itemIdToEdit != null) {
        // If editing an existing item
        _vm.loadItemForEdit(widget.itemIdToEdit!).then((_) {
          // Load item data
          // Pre-fill controllers after item data is loaded into the VM's formState
          _titleController.text = _vm.formState.title;
          _descriptionController.text = _vm.formState.description;
          _priceController.text = _vm.formState.price;
          _categoryController.text = _vm.formState.category;
          if (_vm.formState.itemType == 'Product') {
            _quantityController.text = _vm.formState.quantity ?? '';
          } else if (_vm.formState.itemType == 'Service') {
            _durationController.text = _vm.formState.duration ?? '';
          }
          setState(
            () {},
          ); // Rebuild the widget to reflect changes in dropdown/conditional fields
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _vm = Provider.of<SellItemVM>(
      context,
    ); // Access VM here for reactive updates

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemIdToEdit != null
              ? 'Edit Listing'
              : 'List Item/Service', // Change title based on edit mode
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _vm.formState.itemType, // Use _vm here
              onChanged: (v) {
                _vm.setItemType(v!); // Use _vm here
                // Clear the other field when item type changes
                if (v == 'Product') {
                  _durationController.clear();
                  _vm.updateField('duration', '');
                } else {
                  _quantityController.clear();
                  _vm.updateField('quantity', '');
                }
              },
              items:
                  ['Product', 'Service']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (v) => _vm.updateField('title', v),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: (v) => _vm.updateField('description', v),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _vm.updateField('price', v),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (v) => _vm.updateField('category', v),
            ),
            if (_vm.formState.itemType == 'Product') // Use _vm here
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _vm.updateField('quantity', v),
              ),
            if (_vm.formState.itemType == 'Service') // Use _vm here
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 1 hour)',
                ),
                onChanged: (v) => _vm.updateField('duration', v),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You must be logged in to list items."),
                    ),
                  );
                  return;
                }

                // Call submitForm from VM, passing itemIdToEdit for update
                await _vm.submitForm(currentUser.uid, widget.itemIdToEdit);
                if (context.mounted) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Pop with true to indicate success for refresh
                }
              },
              child: Text(
                widget.itemIdToEdit != null
                    ? 'Update Listing'
                    : 'Submit Listing',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
