import 'package:flutter/material.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:get/get.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'dart:convert';

class ExpenseDetailScreen extends StatefulWidget {
  final HrExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  String? _employeeName;
  String? _categoryName;
  String _taxNames = '-';
  final HrExpenseController _controller = Get.find<HrExpenseController>();
  String? _billBase64; // ensure we have the latest image

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _fetchNames();
    _initPhoto();
  }

  Future<void> _initPhoto() async {
    final String? local = widget.expense.billImage?.trim();
    if (local != null && local.isNotEmpty) {
      setState(() => _billBase64 = local);
      return;
    }
    if (widget.expense.id != null) {
      final fetched = await _controller.fetchExpensePhoto(widget.expense.id!);
      if (!mounted) return;
      if (fetched != null && fetched.isNotEmpty) {
        setState(() => _billBase64 = fetched);
      }
    }
  }

  Future<void> _fetchNames() async {
    // Fetch employee name
    if (widget.expense.employeeId != null) {
      final empName =
          await _controller.getEmployeeNameById(widget.expense.employeeId!);
      if (mounted) {
        setState(() => _employeeName = empName);
      }
    }

    // Fetch category name
    if (widget.expense.productId != null) {
      final catName =
          await _controller.getCategoryNameById(widget.expense.productId!);
      if (mounted) {
        setState(() => _categoryName = catName);
      }
    }

    // Fetch tax names
    if (widget.expense.taxIds != null && widget.expense.taxIds!.isNotEmpty) {
      final taxNames =
          await _controller.getTaxNamesByIds(widget.expense.taxIds!);
      if (mounted) {
        setState(() => _taxNames = taxNames);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            )),
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
            MapEntry(
                'Paid By',
                _controller
                    .getPaymentModeDisplayText(widget.expense.paymentMode)),
            // MapEntry('Reference', widget.expense.reference ?? '-'),
            MapEntry('Category',
                _categoryName ?? widget.expense.productId?.toString() ?? '-'),
            MapEntry('Sub Category', widget.expense.subCategory ?? '-'),
            MapEntry('Taxes', _taxNames),
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

          // Bill image section (improved UX)
          rows.addAll(_buildBillPhotoSection(context));

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

  List<Widget> _buildBillPhotoSection(BuildContext context) {
    final List<Widget> section = [];
    section.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt_long,
                  size: 18, color: ColorManager.primary),
            ),
            const SizedBox(width: 8),
            const Text(
              'Bill Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );

    final String? base64Raw = (_billBase64 ?? widget.expense.billImage)?.trim();
    if (base64Raw == null || base64Raw.isEmpty) {
      section.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.image_not_supported, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No bill photo attached',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
      return section;
    }

    final String data =
        base64Raw.contains(',') ? base64Raw.split(',').last : base64Raw;

    section.add(
      Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(12),
                backgroundColor: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        child: Image.memory(
                          base64Decode(data),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  base64Decode(data),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Tap to view',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    return section;
  }
}
