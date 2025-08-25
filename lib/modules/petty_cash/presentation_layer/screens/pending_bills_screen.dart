import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import 'pdf_viewer_screen.dart';

import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/color_manager.dart';
import '../../../../core/utils/constance_manager.dart';
import '../../data_layer/models/petty_cash_model.dart';
import '../../domain_layer/entities/petty_cash.dart';
import '../bloc/pending_bills_bloc.dart';

class PendingBillsScreen extends StatefulWidget {
  const PendingBillsScreen({super.key});

  @override
  State<PendingBillsScreen> createState() => _PendingBillsScreenState();
}

class _PendingBillsScreenState extends State<PendingBillsScreen> {
  @override
  void initState() {
    super.initState();
    sl<PendingBillsBloc>().add(LoadPendingBillsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<PendingBillsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pending Bill Submissions'),
          backgroundColor: ColorManager.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                sl<PendingBillsBloc>().add(LoadPendingBillsEvent());
              },
            ),
          ],
        ),
        body: BlocConsumer<PendingBillsBloc, PendingBillsState>(
          listener: (context, state) {
            if (state is PendingBillsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is AdvancePaymentCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Advance payment completed successfully!')),
              );
              // Refresh the list
              sl<PendingBillsBloc>().add(LoadPendingBillsEvent());
            }
          },
          builder: (context, state) {
            if (state is PendingBillsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PendingBillsLoaded) {
              if (state.bills.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64.sp,
                        color: ColorManager.grey2,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No Pending Bills',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.grey2,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'All advance payments have been completed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ColorManager.grey2,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: state.bills.length,
                itemBuilder: (context, index) {
                  final bill = state.bills[index];
                  return _buildPendingBillCard(bill);
                },
              );
            } else if (state is PendingBillsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: ColorManager.error,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Error Loading Bills',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.error,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorManager.grey2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () {
                        sl<PendingBillsBloc>().add(LoadPendingBillsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPendingBillCard(PettyCashModel bill) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Text(
                    'Advance Request',
                    style: TextStyle(
                      color: ColorManager.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${bill.id}',
                  style: TextStyle(
                    color: ColorManager.grey2,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Purpose
            if (bill.advancePurpose != null) ...[
              _buildInfoRow('Purpose', bill.advancePurpose!),
              SizedBox(height: 1.h),
            ],

            // Expected Amount
            if (bill.expectedAmount != null) ...[
              _buildInfoRow('Expected Amount',
                  'OMR ${bill.expectedAmount!.toStringAsFixed(2)}'),
              SizedBox(height: 1.h),
            ],

            // Project/Customer Name
            if (bill.projectCustomerName != null) ...[
              _buildInfoRow('Project/Customer', bill.projectCustomerName!),
              SizedBox(height: 1.h),
            ],

            // Comments
            _buildInfoRow('Comments', bill.comments),
            SizedBox(height: 1.h),

            // Date
            _buildInfoRow('Date', bill.date.toLocal().toString().split(' ')[0]),
            SizedBox(height: 2.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteAdvanceDialog(bill),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Complete with Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.sp),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                ElevatedButton.icon(
                  onPressed: () => _viewPDF(bill),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('View PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            '$label:',
            style: TextStyle(
              color: ColorManager.grey2,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: ColorManager.black,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  void _showCompleteAdvanceDialog(PettyCashModel bill) {
    showDialog(
      context: context,
      builder: (context) => CompleteAdvanceDialog(bill: bill),
    );
  }

  void _viewPDF(PettyCashModel bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          requestId: bill.id ?? '',
          requestTitle: 'Petty Cash Request - ${bill.id}',
        ),
      ),
    );
  }
}

class CompleteAdvanceDialog extends StatefulWidget {
  final PettyCashModel bill;

  const CompleteAdvanceDialog({super.key, required this.bill});

  @override
  State<CompleteAdvanceDialog> createState() => _CompleteAdvanceDialogState();
}

class _CompleteAdvanceDialogState extends State<CompleteAdvanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vendorController = TextEditingController();
  final _amountController = TextEditingController();
  List<File> _selectedPhotos = [];

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 50);
    if (result.isNotEmpty && mounted) {
      setState(() {
        _selectedPhotos.addAll(result.map((e) => File(e.path)));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Container(
        width: 90.w,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: ColorManager.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Complete Advance Payment',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Vendor Name
                  TextFormField(
                    controller: _vendorController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vendor name is required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Vendor Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Actual Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Actual amount is required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Actual Amount Spent *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Bill Photos
                  Text(
                    'Bill Photos *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPhotos,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Photos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${_selectedPhotos.length} photos selected',
                        style: TextStyle(
                          color: ColorManager.grey2,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),

                  if (_selectedPhotos.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 20.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedPhotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 2.w),
                            child: Stack(
                              children: [
                                Image.file(
                                  _selectedPhotos[index],
                                  height: 20.h,
                                  width: 20.h,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: EdgeInsets.all(4.sp),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedPhotos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please add at least one bill photo'),
                            ),
                          );
                          return;
                        }

                        final actualAmount =
                            double.tryParse(_amountController.text) ?? 0;

                        sl<PendingBillsBloc>().add(
                          CompleteAdvancePaymentEvent(
                            advanceId: widget.bill.id!,
                            vendorName: _vendorController.text,
                            actualAmount: actualAmount,
                            billPhotos: _selectedPhotos,
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
