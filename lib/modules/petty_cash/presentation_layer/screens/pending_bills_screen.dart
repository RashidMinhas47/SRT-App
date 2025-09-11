import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:bayanat/modules/petty_cash/presentation_layer/screens/expense_detail_screen.dart';
import 'dart:convert';

class PendingBillsScreen extends StatefulWidget {
  const PendingBillsScreen({super.key});

  @override
  State<PendingBillsScreen> createState() => _PendingBillsScreenState();
}

class _PendingBillsScreenState extends State<PendingBillsScreen> {
  final HrExpenseController _controller = Get.find<HrExpenseController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      await _controller.fetchExpenses();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Petty Cash Bills',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: ColorManager.primary,
        elevation: 0.5,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadExpenses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final List<HrExpenseModel> items = _controller.expenses;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 2.h),
                      const Text('No expenses found'),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2.2.h,
                    crossAxisSpacing: 3.w,
                    // Make cards taller to avoid overflow
                    childAspectRatio: 0.78,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
                    return InkWell(
                      onTap: () =>
                          Get.to(() => ExpenseDetailScreen(expense: e)),
                      borderRadius: BorderRadius.circular(12),
                      child: _ExpenseCard(expense: e),
                    );
                  },
                ),
              );
            }),
    );
  }
}

class _ExpenseCard extends StatefulWidget {
  final HrExpenseModel expense;
  const _ExpenseCard({required this.expense});

  @override
  State<_ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<_ExpenseCard> {
  String? _employeeName;

  @override
  void initState() {
    super.initState();
    final ctr = Get.find<HrExpenseController>();
    final empId = widget.expense.employeeId;
    if (empId != null) {
      ctr.getEmployeeNameById(empId).then((name) {
        if (!mounted) return;
        setState(() => _employeeName = name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String _formatDate(DateTime? dt) {
      if (dt == null) return '-';
      final d = dt.toLocal();
      String two(int n) => n < 10 ? '0$n' : '$n';
      return '${two(d.day)}/${two(d.month)}/${d.year}';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill photo thumbnail (with overlays)
            _buildBillThumbnail(),
            const SizedBox(height: 8),
            Text(
              widget.expense.name ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.expense.employeeId != null
                        ? 'Emp: ${_employeeName ?? widget.expense.employeeId}'
                        : 'No employee',
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(widget.expense.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.expense.amount != null
                        ? widget.expense.amount!.toStringAsFixed(2)
                        : '0.00',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasBillImage() {
    final v = widget.expense.billImage?.trim();
    return v != null && v.isNotEmpty;
  }

  Widget _buildBillThumbnail() {
    if (!_hasBillImage()) {
      return Stack(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          _buildOverlays(),
        ],
      );
    }

    final raw = widget.expense.billImage!.trim();
    final data = raw.contains(',') ? raw.split(',').last : raw;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.memory(
                base64Decode(data),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        _buildOverlays(),
      ],
    );
  }

  Widget _buildOverlays() {
    return Positioned(
      top: 4,
      left: 4,
      right: 4,
      child: Row(
        children: [
          // Status chip (left)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              (widget.expense.state ?? 'draft').toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          // Number chip (right)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '#${widget.expense.id ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
