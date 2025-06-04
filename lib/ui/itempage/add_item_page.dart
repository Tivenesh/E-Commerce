import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './view_model/add_item_viewmodel.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Item Name',
                errorText: vm.nameError,
              ),
              onChanged: vm.updateName,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: vm.updateDescription,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Quantity',
                errorText: vm.quantityError,
              ),
              keyboardType: TextInputType.number,
              onChanged: vm.updateQuantity,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Pic (string)'),
              onChanged: vm.updatePic,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Price',
                errorText: vm.priceError,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: vm.updatePrice,
            ),
            const SizedBox(height: 24),
            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      final success = await vm.submit();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item added!')),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to add item')),
                        );
                      }
                    },
                    child: const Text('Add Item'),
                  ),
          ],
        ),
      ),
    );
  }
}
