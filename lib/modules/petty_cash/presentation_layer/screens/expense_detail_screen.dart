import 'package:flutter/material.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final HrExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile('Status', (expense.state ?? 'draft').toUpperCase()),
          _buildTile('Description', expense.name ?? '-'),
          _buildTile('Employee', expense.employeeId?.toString() ?? '-'),
          _buildTile('Amount', expense.amount?.toStringAsFixed(2) ?? '0.00'),
          _buildTile('Date', _formatDateTime(expense.date)),
          _buildTile('Company', expense.companyId ?? '-'),
          _buildTile('Payment Mode', expense.paymentMode ?? '-'),
          _buildTile('Reference', expense.reference ?? '-'),
          _buildTile(
              'Category (product_id)', expense.productId?.toString() ?? '-'),
          _buildTile('Taxes', expense.taxIds?.join(', ') ?? '-'),
        ],
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
