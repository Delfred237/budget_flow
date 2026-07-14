import 'package:budget_flow/feature/transactions/presentation/add_transaction_dialog.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_atm':
        return Icons.local_atm;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'medical':
        return Icons.medical_services;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'alcohol':
        return Icons.local_drink;
      case 'other':
        return Icons.other_houses;
      default:
        return Icons.other_houses;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionControllerProvider);

    // Formatteur de devises (ex: 2 500 € ou F CFA)
    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'F CFA',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Transactions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTransactionDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Transactions"),
      ),
      body: transactionsState.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text("Aucune transaction enregistrée !"),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: ((context, index) {
              final item = list[index];
              final isExpense = item.transaction.type == 'expense';
              final categoryColor = Color(item.category.colorValue);

              return Dismissible(
                key: Key(item.transaction.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref
                      .read(transactionControllerProvider.notifier)
                      .removeTransaction(item.transaction.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction supprimée !')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoryColor.withValues(alpha: 0.2),
                      foregroundColor: categoryColor,
                      child: Icon(_getIconData(item.category.icon)),
                    ),
                    title: Text(
                      (item.transaction.comment != null &&
                              item.transaction.comment!.isNotEmpty)
                          ? item.transaction.comment!
                          : item.category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy',
                        'fr_FR',
                      ).format(item.transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      "${isExpense ? '-' : '+'}${currencyFormatter.format(item.transaction.amount)}",
                      style: TextStyle(
                        color: isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) => Center(child: Text("Erreur : $err")),
      ),
    );
  }
}
