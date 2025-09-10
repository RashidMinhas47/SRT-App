import 'package:flutter/material.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final HrExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final List<MapEntry<String, String>> fields = [
            MapEntry('Status', (expense.state ?? 'draft').toUpperCase()),
            MapEntry('Description', expense.name ?? '-'),
            MapEntry('Employee', expense.employeeId?.toString() ?? '-'),
            MapEntry('Amount', expense.amount?.toStringAsFixed(2) ?? '0.00'),
            MapEntry('Date', _formatDate(expense.date)),
            MapEntry('Company', expense.companyId ?? '-'),
            MapEntry('Payment Mode', expense.paymentMode ?? '-'),
            MapEntry('Reference', expense.reference ?? '-'),
            MapEntry(
                'Category (product_id)', expense.productId?.toString() ?? '-'),
            MapEntry('Taxes', expense.taxIds?.join(', ') ?? '-'),
          ];

          final List<Widget> rows = [];
          List<Widget> buffer = [];

          void flushBuffer() {
            if (buffer.isEmpty) return;
            rows.add(Row(
              children: buffer
                  .map((w) => Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: w,
                      )))
                  .toList(),
            ));
            buffer = [];
          }

          for (final entry in fields) {
            final value = entry.value;
            final tile = _buildTile(entry.key, value);
            if (entry.key == 'Description' || value.length >= 15) {
              flushBuffer();
              rows.add(Padding(
                  padding: const EdgeInsets.only(bottom: 12), child: tile));
            } else {
              buffer.add(tile);
              if (buffer.length == 2) flushBuffer();
            }
          }
          flushBuffer();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: rows,
          );
        },
      ),
    );
  }

  Widget _buildTile(String label, String value) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
