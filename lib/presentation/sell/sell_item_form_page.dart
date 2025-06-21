import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'dart:io'; // Import for File

class SellItemFormPage extends StatelessWidget {
  final String? itemIdToEdit;

  const SellItemFormPage({super.key, this.itemIdToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final vm = SellItemVM();
        if (itemIdToEdit != null) {
          vm.loadItemForEdit(itemIdToEdit!); // Load data if editing
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
    _setControllers(); // Set initial values for controllers
    _vm.addListener(_onVmChanged); // Listen to VM changes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vm != Provider.of<SellItemVM>(context, listen: false)) {
      _vm.removeListener(_onVmChanged);
      _vm = Provider.of<SellItemVM>(context, listen: false);
      _vm.addListener(_onVmChanged);
      _setControllers();
    }
  }

  void _onVmChanged() {
    // Update controllers only if they are not already reflecting the VM's state
    // This prevents infinite loops or incorrect cursor placement.
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
    if (_vm.formState.itemType == 'Product' &&
        _quantityController.text != (_vm.formState.quantity ?? '')) {
      _quantityController.text = _vm.formState.quantity ?? '';
    }
    if (_vm.formState.itemType == 'Service' &&
        _durationController.text != (_vm.formState.duration ?? '')) {
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    _vm.removeListener(_onVmChanged); // Remove listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemIdToEdit != null ? 'Edit Listing' : 'Add New Listing',
        ),
      ),
      body: Consumer<SellItemVM>(
        builder: (context, vm, child) {
          if (vm.isLoading &&
              widget.itemIdToEdit != null &&
              vm.formState.title.isEmpty) {
            // Show loading indicator only when initially loading for edit and form is empty
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: vm.formState.itemType,
                  decoration: const InputDecoration(labelText: 'Item Type'),
                  items: const [
                    DropdownMenuItem(value: 'Product', child: Text('Product')),
                    DropdownMenuItem(value: 'Service', child: Text('Service')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      vm.updateField('itemType', value);
                      // Clear relevant controllers when type changes
                      if (value == 'Product') {
                        _durationController.clear();
                      } else {
                        _quantityController.clear();
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (v) => vm.updateField('title', v),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (v) => vm.updateField('description', v),
                  maxLines: 3,
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price (RM)'),
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
                      labelText: 'Duration (e.g., 1 hour, 30 mins)',
                    ),
                    onChanged: (v) => vm.updateField('duration', v),
                  ),
                const SizedBox(height: 20),
                // Image Picking Section
                ElevatedButton.icon(
                  onPressed: vm.pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Images'),
                ),
                const SizedBox(height: 10),
                // Display selected images
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      vm.selectedImages.map((image) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    image is XFile
                                        ? Image.file(
                                          File(image.path),
                                          fit: BoxFit.cover,
                                        )
                                        : Image.network(
                                          image as String,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child; // Image is fully loaded
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null, // Indeterminate progress if total bytes are unknown
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                  ),
                                        ),
                              ),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => vm.removeImage(image),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                Center(
                  child:
                      vm.isLoading && widget.itemIdToEdit == null
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () async {
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              if (currentUser == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "You must be logged in to list items.",
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              try {
                                await vm.submitForm(
                                  currentUser.uid,
                                  widget.itemIdToEdit,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        widget.itemIdToEdit != null
                                            ? 'Listing updated successfully!'
                                            : 'Listing added successfully!',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error: ${vm.errorMessage ?? e.toString()}',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              widget.itemIdToEdit != null
                                  ? 'Update Listing'
                                  : 'Submit Listing',
                            ),
                          ),
                ),
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Error: ${vm.errorMessage!}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
