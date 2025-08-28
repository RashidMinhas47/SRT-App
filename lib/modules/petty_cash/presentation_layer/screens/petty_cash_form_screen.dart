import 'dart:convert';
import 'dart:io';

import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/petty_cash/controllers/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../main/presentation_layer/components/components.dart';
import '../../models/petty_cash.dart';
import 'pending_bills_screen.dart';

class PettyCashFormScreen extends StatefulWidget {
  const PettyCashFormScreen({super.key});

  @override
  State<PettyCashFormScreen> createState() => _PettyCashFormScreenState();
}

class _PettyCashFormScreenState extends State<PettyCashFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _customerProjectController = TextEditingController();
  final _locationController = TextEditingController();
  final _commentsController = TextEditingController();
  final _advancePurposeController = TextEditingController();
  final _expectedAmountController = TextEditingController();
  final _projectCustomerController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // GetX controller
  late final ExpenseController _pettyCashController;

  // Local state for bill photos
  final List<File> _billPhotos = [];
  final List<String> _billPhotosBase64 = [];

  // Bill Type state
  final List<String> _billTypes = const [
    'Material Purchase',
    'Food/Meals',
    'Transport/Fuel',
    'Miscellaneous',
    'Advance Request',
  ];
  String? _selectedBillType;

  @override
  void initState() {
    super.initState();
    // Initialize GetX controller
    _pettyCashController = Get.put(ExpenseController());
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _billNumberController.dispose();
    _customerProjectController.dispose();
    _locationController.dispose();
    _commentsController.dispose();
    _advancePurposeController.dispose();
    _expectedAmountController.dispose();
    _projectCustomerController.dispose();
    super.dispose();
  }

  String _getBillTypeFromString(String type) {
    switch (type) {
      case 'Material Purchase':
        return 'materialPurchase';
      case 'Food/Meals':
        return 'foodMeals';
      case 'Transport/Fuel':
        return 'transportFuel';
      case 'Miscellaneous':
        return 'miscellaneous';
      case 'Advance Request':
        return 'advanceRequest';
      default:
        return 'miscellaneous';
    }
  }

  Future<void> _pickBills() async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 50);

    if (result.isNotEmpty) {
      setState(() {
        for (var xFile in result) {
          final file = File(xFile.path);
          _billPhotos.add(file);

          // Convert to base64
          final bytes = file.readAsBytesSync();
          final base64String = base64Encode(bytes);
          _billPhotosBase64.add(base64String);
        }
      });
    }
  }

  void _removeBillPhoto(int index) {
    setState(() {
      _billPhotos.removeAt(index);
      _billPhotosBase64.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final bool isAdvance = _selectedBillType == 'Advance Request';

      if (_selectedBillType == null) {
        errorToast(msg: 'Please select a bill type');
        return;
      }

      if (!isAdvance && _billPhotos.isEmpty) {
        errorToast(msg: 'Please add at least one bill photo');
        return;
      }

      // Create PettyCashModel
      final pettyCashModel = PettyCashModel(
        vendorName: _vendorController.text,
        description: _commentsController.text,
        amount: amount,
        date: _selectedDate,
        billType: BillType.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              _getBillTypeFromString(_selectedBillType!),
          orElse: () => BillType.miscellaneous,
        ),
        billNumber: _billNumberController.text.isNotEmpty
            ? _billNumberController.text
            : null,
        customerProjectName: _customerProjectController.text.isNotEmpty
            ? _customerProjectController.text
            : null,
        location: _locationController.text,
        comments: _commentsController.text,
        isAdvanceRequest: isAdvance,
        advancePurpose: isAdvance && _advancePurposeController.text.isNotEmpty
            ? _advancePurposeController.text
            : null,
        expectedAmount: isAdvance ? amount : null,
        projectCustomerName:
            isAdvance && _projectCustomerController.text.isNotEmpty
                ? _projectCustomerController.text
                : null,
        userId: (ConstanceManager.userId ?? 'unknown').toString(),
        status: BillStatus.pending,
        billPhotosBase64: _billPhotosBase64,
        createdAt: DateTime.now(),
      );

      // Submit using controller
      final success = await _pettyCashController.submitPettyCash(
        pettyCash: pettyCashModel,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petty Cash Form',
            style: TextStyle(color: Colors.white)),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final isSubmitting = _pettyCashController.isSubmitting.value;

        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Petty Cash Request',
                          style: TextStyle(
                            color: ColorManager.primary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          //TODO: PendingBillScreen is paused
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         const PendingBillsScreen(),
                          //   ),
                          // );
                        },
                        icon: const Icon(Icons.pending_actions),
                        label: const Text('Pending Bills'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Please fill in the details below to submit your petty cash request',
                    style: TextStyle(
                      color: ColorManager.grey2,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Bill Type Dropdown (Required)
                  Text(
                    'Bill Type *',
                    style: TextStyle(
                      color: ColorManager.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  DropdownButtonFormField<String>(
                    value: _selectedBillType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 12.sp,
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                    ),
                    hint: const Text('Select Bill Type'),
                    items: _billTypes
                        .map((t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedBillType = v);
                    },
                    validator: (v) =>
                        v == null ? 'Please select a bill type' : null,
                  ),
                  SizedBox(height: 2.h),

                  // Bill Number (Optional)
                  TextFormField(
                    controller: _billNumberController,
                    validator: (v) => null, // Optional field
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Bill Number (Optional)',
                      labelStyle: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide:
                            BorderSide(color: ColorManager.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.error),
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Customer/Project Name (Optional)
                  TextFormField(
                    controller: _customerProjectController,
                    validator: (v) => null, // Optional field
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Customer/Project Name (Optional)',
                      labelStyle: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide:
                            BorderSide(color: ColorManager.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.error),
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Location (Required)
                  TextFormField(
                    controller: _locationController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Location is required'
                        : null,
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Location *',
                      labelStyle: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide:
                            BorderSide(color: ColorManager.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.error),
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Vendor Name (optional for non-advance)
                  if (_selectedBillType != 'Advance Request')
                    TextFormField(
                      controller: _vendorController,
                      validator: (v) => null, // Optional field
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Vendor Name (Optional)',
                        labelStyle: TextStyle(
                          color: ColorManager.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide:
                              BorderSide(color: ColorManager.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.error),
                        ),
                        filled: true,
                        fillColor: ColorManager.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 12.sp),
                      ),
                    ),
                  if (_selectedBillType != 'Advance Request')
                    SizedBox(height: 2.h),

                  // Comments/Purpose (Required)
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Comments/Purpose is required'
                        : null,
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Comments / Purpose *',
                      labelStyle: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide:
                            BorderSide(color: ColorManager.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.error),
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Amount/Expected Amount (Required)
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty)
                        ? (_selectedBillType == 'Advance Request'
                            ? 'Expected amount is required'
                            : 'Amount is required')
                        : null,
                    style: TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: _selectedBillType == 'Advance Request'
                          ? 'Expected Amount *'
                          : 'Amount *',
                      labelStyle: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.grey2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide:
                            BorderSide(color: ColorManager.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide(color: ColorManager.error),
                      ),
                      filled: true,
                      fillColor: ColorManager.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 12.sp),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Advance Request specific fields
                  if (_selectedBillType == 'Advance Request') ...[
                    // Purpose of Advance
                    TextFormField(
                      controller: _advancePurposeController,
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Purpose of advance is required'
                          : null,
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Purpose of Advance *',
                        labelStyle: TextStyle(
                          color: ColorManager.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide:
                              BorderSide(color: ColorManager.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.error),
                        ),
                        filled: true,
                        fillColor: ColorManager.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 12.sp),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Project/Customer Name for Advance
                    TextFormField(
                      controller: _projectCustomerController,
                      validator: (v) => null, // Optional field
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Project/Customer Name (Optional)',
                        labelStyle: TextStyle(
                          color: ColorManager.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide:
                              BorderSide(color: ColorManager.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                          borderSide: BorderSide(color: ColorManager.error),
                        ),
                        filled: true,
                        fillColor: ColorManager.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.sp, vertical: 12.sp),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],

                  // Date Selection
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorManager.grey2),
                      borderRadius: BorderRadius.circular(10.sp),
                      color: ColorManager.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date of Expense *',
                                style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${_selectedDate.toLocal()}'.split(' ')[0],
                                style: TextStyle(
                                  color: ColorManager.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && context.mounted) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          icon: Icon(
                            Icons.calendar_today,
                            color: ColorManager.white,
                            size: 18.sp,
                          ),
                          label: Text(
                            'Pick Date',
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            foregroundColor: ColorManager.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 8.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Photos (required only for non-advance)
                  if (_selectedBillType != 'Advance Request') ...[
                    Text(
                      'Bill Photos *',
                      style: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Upload photos of your bills for verification',
                      style: TextStyle(
                        color: ColorManager.grey2,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickBills,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: ColorManager.white,
                            size: 20.sp,
                          ),
                          label: Text(
                            'Add Bills',
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            foregroundColor: ColorManager.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 12.sp),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_billPhotos.length, (i) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ColorManager.grey2,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _billPhotos[i],
                                        height: 12.h,
                                        width: 12.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () => _removeBillPhoto(i),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade700,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 4.h),

                  // Submit Button
                  isSubmitting
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ColorManager.primary,
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(
                              Icons.send,
                              color: ColorManager.white,
                              size: 20.sp,
                            ),
                            label: Text(
                              'Submit',
                              style: TextStyle(
                                color: ColorManager.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primary,
                              foregroundColor: ColorManager.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.sp),
                              elevation: 2,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
