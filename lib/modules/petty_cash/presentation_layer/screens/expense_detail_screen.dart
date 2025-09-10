import 'package:flutter/material.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:get/get.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final HrExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  String? _employeeName;
  final HrExpenseController _controller = Get.find<HrExpenseController>();

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.expense.employeeId != null) {
      _controller.getEmployeeNameById(widget.expense.employeeId!).then((name) {
        if (!mounted) return;
        setState(() => _employeeName = name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Petty Cash Bill Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final List<MapEntry<String, String>> fields = [
            MapEntry('Status', (widget.expense.state ?? 'draft').toUpperCase()),
            MapEntry('Description', widget.expense.name ?? '-'),
            MapEntry(
                'Employee',
                _employeeName ??
                    (widget.expense.employeeId?.toString() ?? '-')),
            MapEntry(
                'Amount', widget.expense.amount?.toStringAsFixed(2) ?? '0.00'),
            MapEntry('Date', _formatDate(widget.expense.date)),
            MapEntry('Company', widget.expense.companyName ?? '-'),
            MapEntry(
                'Paid By',
                _controller
                    .getPaymentModeDisplayText(widget.expense.paymentMode)),
            MapEntry('Reference', widget.expense.reference ?? '-'),
            MapEntry('Category (product_id)',
                widget.expense.productId?.toString() ?? '-'),
            MapEntry('Taxes', widget.expense.taxIds?.join(', ') ?? '-'),
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
