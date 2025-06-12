import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profilevm.dart';

class SellerRegistrationDialog extends StatefulWidget {
  final bool isUpdate;
  final String? initialBusinessName;
  final String? initialBusinessAddress;
  final String? initialBusinessContactEmail;
  final String? initialBusinessPhoneNumber;
  final String? initialBusinessDescription;

  const SellerRegistrationDialog({
    Key? key,
    this.isUpdate = false,
    this.initialBusinessName,
    this.initialBusinessAddress,
    this.initialBusinessContactEmail,
    this.initialBusinessPhoneNumber,
    this.initialBusinessDescription,
  }) : super(key: key);

  @override
  State<SellerRegistrationDialog> createState() => _SellerRegistrationDialogState();
}

class _SellerRegistrationDialogState extends State<SellerRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if updating
    if (widget.isUpdate) {
      _businessNameController.text = widget.initialBusinessName ?? '';
      _businessAddressController.text = widget.initialBusinessAddress ?? '';
      _businessEmailController.text = widget.initialBusinessContactEmail ?? '';
      _businessPhoneController.text = widget.initialBusinessPhoneNumber ?? '';
      _businessDescriptionController.text = widget.initialBusinessDescription ?? '';
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isUpdate ? 'Update Business Information' : 'Register as Seller'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isUpdate
                      ? 'Update your business information below:'
                      : 'Fill in your business information to become a seller:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                // Business Name
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name *',
                    hintText: 'Enter your business name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Business name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Address
                TextFormField(
                  controller: _businessAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Business Address *',
                    hintText: 'Enter your business address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Email
                TextFormField(
                  controller: _businessEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Business Email *',
                    hintText: 'Enter your business email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Phone
                TextFormField(
                  controller: _businessPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Business Phone *',
                    hintText: 'Enter your business phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business phone is required';
                    }
                    if (value.trim().length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Description (optional)
                TextFormField(
                  controller: _businessDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Business Description',
                    hintText: 'Describe your business (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '* Required fields',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.isUpdate ? 'Update' : 'Register'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<ProfileViewModel>();
      bool success;

      if (widget.isUpdate) {
        success = await viewModel.updateSellerInfo(
          businessName: _businessNameController.text.trim(),
          businessAddress: _businessAddressController.text.trim(),
          businessContactEmail: _businessEmailController.text.trim(),
          businessPhoneNumber: _businessPhoneController.text.trim(),
          businessDescription: _businessDescriptionController.text.trim().isEmpty
              ? null
              : _businessDescriptionController.text.trim(),
        );
      } else {
        success = await viewModel.registerAsSeller(
          businessName: _businessNameController.text.trim(),
          businessAddress: _businessAddressController.text.trim(),
          businessContactEmail: _businessEmailController.text.trim(),
          businessPhoneNumber: _businessPhoneController.text.trim(),
          businessDescription: _businessDescriptionController.text.trim().isEmpty
              ? null
              : _businessDescriptionController.text.trim(),
        );
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isUpdate
                    ? 'Business information updated successfully!'
                    : 'Successfully registered as a seller!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                viewModel.errorMessage ?? 
                (widget.isUpdate 
                    ? 'Failed to update business information' 
                    : 'Failed to register as seller'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}