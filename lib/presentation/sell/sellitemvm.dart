import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart';

class SellItemPage extends StatelessWidget {
  const SellItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellItemVM(),
      child: const _SellItemForm(),
    );
  }
}

class _SellItemForm extends StatelessWidget {
  const _SellItemForm();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SellItemVM>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('List Item/Service')),
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
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (v) => vm.updateField('title', v),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: (v) => vm.updateField('description', v),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.updateField('price', v),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (v) => vm.updateField('category', v),
            ),
            if (vm.formState.itemType == 'Product')
              TextField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (v) => vm.updateField('quantity', v),
              ),
            if (vm.formState.itemType == 'Service')
              TextField(
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

                await vm.submitForm(currentUser.uid);
                if (context.mounted) {
                  Navigator.pop(context, true); // trigger shop refresh
                }
              },
              child: const Text('Submit Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
