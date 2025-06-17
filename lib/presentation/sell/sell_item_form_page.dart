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
    final vm = Provider.of<SellItemVM>(context);

    // Initial load/pre-fill for editing (You'll need to fetch data in VM)
    // For now, we'll keep it simple for new items.
    // If you implement editing, you'd load item data into vm.formState here
    // and then update the controllers.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemIdToEdit != null ? 'Edit Listing' : 'List Item/Service',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: vm.formState.itemType,
              onChanged: (v) => vm.setItemType(v!),
              items:
                  ['Product', 'Service']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (v) => vm.updateField('title', v),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: (v) => vm.updateField('description', v),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.updateField('price', v),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (v) => vm.updateField('category', v),
            ),
            if (vm.formState.itemType == 'Product')
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (v) => vm.updateField('quantity', v),
              ),
            if (vm.formState.itemType == 'Service')
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 1 hour)',
                ),
                onChanged: (v) => vm.updateField('duration', v),
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

                // Call submitForm from VM
                await vm.submitForm(currentUser.uid);
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
