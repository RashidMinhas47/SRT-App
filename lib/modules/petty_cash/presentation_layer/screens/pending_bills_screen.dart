import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';

class PendingBillsScreen extends StatefulWidget {
  const PendingBillsScreen({super.key});

  @override
  State<PendingBillsScreen> createState() => _PendingBillsScreenState();
}

class _PendingBillsScreenState extends State<PendingBillsScreen> {
  final HrExpenseController _controller = Get.find<HrExpenseController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Petty Cash Bills'),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.fetchExpenses(),
          ),
        ],
      ),
      body: Obx(() {
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
          padding: EdgeInsets.all(4.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3.w,
              crossAxisSpacing: 3.w,
              childAspectRatio: 0.95,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final e = items[index];
              return _ExpenseCard(expense: e);
            },
          ),
        );
      }),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final HrExpenseModel expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (expense.state ?? 'draft').toUpperCase(),
                    style: TextStyle(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text('#${expense.id ?? ''}',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              expense.name ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    expense.employeeId != null
                        ? 'Emp: ${expense.employeeId}'
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
                Text(
                  expense.date != null
                      ? expense.date!.toLocal().toString().split('T').first
                      : '-',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  expense.amount != null
                      ? '${expense.amount!.toStringAsFixed(2)}'
                      : '0.00',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
