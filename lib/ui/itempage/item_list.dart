import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../data/models/item.dart';
import '../../data/services/old_item_repository.dart';
import './view_model/viewitem_viewmodel.dart';

class ItemListPage extends StatelessWidget {
  const ItemListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemListViewModel>(
      create: (_) => ItemListViewModel(ItemRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item List (CRUD)'),
        ),
        body: const ItemListBody(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showAddEditDialog(context),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Item? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '0');
    final picController = TextEditingController(text: item?.pic ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: picController,
                    decoration: const InputDecoration(labelText: 'Pic (string)'),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;

                final newItem = Item(
                  id: item?.id ?? '',
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  quantity: int.parse(quantityController.text.trim()),
                  pic: picController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                );

                final vm = Provider.of<ItemListViewModel>(context, listen: false);
                if (item == null) {
                  await vm.addItem(newItem);
                } else {
                  await vm.updateItem(newItem);
                }

                Navigator.of(context).pop();
              },
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}

class ItemListBody extends StatelessWidget {
  const ItemListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemListViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.items.isEmpty) {
          return const Center(child: Text('No items found.'));
        }

        return ListView.builder(
          itemCount: vm.items.length,
          itemBuilder: (context, index) {
            final item = vm.items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, item),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Item item) {
    final parent = context.findAncestorWidgetOfExactType<ItemListPage>();
    if (parent != null) {
      // Call the _showAddEditDialog method of the parent
      (parent as dynamic)._showAddEditDialog(context, item: item);
    } else {
      // fallback - just rebuild dialog here
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Edit Item'),
          content: Text('Editing dialog failed to open.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final vm = Provider.of<ItemListViewModel>(context, listen: false);
              await vm.deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item List Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ItemListPage(),
    );
  }
}