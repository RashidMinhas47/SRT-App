import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/color_manager.dart';
import '../../../../core/utils/constance_manager.dart';
import '../../domain/entities/petty_cash_bill.dart';
import '../bloc/petty_cash_bloc.dart';
import '../bloc/petty_cash_event.dart';
import '../bloc/petty_cash_state.dart';

class PettyCashFormPage extends StatefulWidget {
  const PettyCashFormPage({super.key});

  @override
  State<PettyCashFormPage> createState() => _PettyCashFormPageState();
}

class _PettyCashFormPageState extends State<PettyCashFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _billNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _customerProjectController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();
  final _advancePurposeController = TextEditingController();
  final _expectedAmountController = TextEditingController();

  BillType? _selectedBillType;
  DateTime _selectedDate = DateTime.now();
  File? _selectedPhoto;
  String? _uploadedPhotoUrl;

  final List<BillType> _billTypes = [
    BillType.materialPurchase,
    BillType.foodMeals,
    BillType.transportFuel,
    BillType.miscellaneous,
    BillType.advanceRequest,
  ];

  @override
  void dispose() {
    _billNumberController.dispose();
    _vendorNameController.dispose();
    _customerProjectController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _commentsController.dispose();
    _advancePurposeController.dispose();
    _expectedAmountController.dispose();
    super.dispose();
  }

  String _getBillTypeDisplayName(BillType type) {
    switch (type) {
      case BillType.materialPurchase:
        return 'Material Purchase';
      case BillType.foodMeals:
        return 'Food/Meals';
      case BillType.transportFuel:
        return 'Transport/Fuel';
      case BillType.miscellaneous:
        return 'Miscellaneous';
      case BillType.advanceRequest:
        return 'Advance Request';
    }
  }

  bool get _isAdvanceRequest => _selectedBillType == BillType.advanceRequest;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });

        // Upload photo
        if (mounted) {
          context.read<PettyCashBloc>().add(UploadPhotoEvent(_selectedPhoto!));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAdvanceRequest && _selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload a photo for non-advance bills')),
      );
      return;
    }

    final bill = PettyCashBill(
      billType: _selectedBillType!,
      billNumber: _billNumberController.text.isNotEmpty
          ? _billNumberController.text
          : null,
      vendorName: _vendorNameController.text.isNotEmpty
          ? _vendorNameController.text
          : null,
      customerProjectName: _customerProjectController.text.isNotEmpty
          ? _customerProjectController.text
          : null,
      location: _locationController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      expenseDate: _selectedDate,
      comments: _commentsController.text,
      photoUrl: _uploadedPhotoUrl ?? _selectedPhoto?.path ?? '',
      status: BillStatus.pending,
      userId: (ConstanceManager.userId ?? 'unknown').toString(),
      createdAt: DateTime.now(),
      isAdvancePayment: _isAdvanceRequest,
      advancePurpose: _isAdvanceRequest ? _advancePurposeController.text : null,
      expectedAmount: _isAdvanceRequest
          ? double.tryParse(_expectedAmountController.text)
          : null,
    );

    context.read<PettyCashBloc>().add(SubmitBillEvent(bill));
  }

  void _clearPhoto() {
    setState(() {
      _selectedPhoto = null;
      _uploadedPhotoUrl = null;
    });
    context.read<PettyCashBloc>().add(const ClearPhotoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Petty Cash Bill'),
        backgroundColor: ColorManager.primary,
        foregroundColor: ColorManager.white,
      ),
      body: BlocListener<PettyCashBloc, PettyCashState>(
        listener: (context, state) {
          if (state is BillSubmittedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bill submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is PettyCashError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PhotoUploaded) {
            setState(() {
              _uploadedPhotoUrl = state.photoUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<PettyCashBloc, PettyCashState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    DropdownButtonFormField<BillType>(
                      value: _selectedBillType,
                      decoration: InputDecoration(
                        labelText: 'Select Bill Type',
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
                      items: _billTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getBillTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBillType = value;
                        });
                        if (value != null) {
                          context
                              .read<PettyCashBloc>()
                              .add(SelectBillTypeEvent(value));
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a bill type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Customer/Project Name field (optional)
                    TextFormField(
                      controller: _customerProjectController,
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

                    // Location field (required, text input)
                    TextFormField(
                      controller: _locationController,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Amount field (required for non-advance, number input with currency symbol)
                    if (!_isAdvanceRequest) ...[
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: ColorManager.black,
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount *',
                          labelStyle: TextStyle(
                            color: ColorManager.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixText: '\$ ',
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
                            borderSide: BorderSide(
                                color: ColorManager.primary, width: 2),
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the amount';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Date picker for expense date (required, default to today, max date is today)
                    Text(
                      'Expense Date *',
                      style: TextStyle(
                        color: ColorManager.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.all(16.sp),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorManager.grey2),
                          borderRadius: BorderRadius.circular(10.sp),
                          color: ColorManager.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: ColorManager.primary),
                            SizedBox(width: 2.w),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: ColorManager.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Comments/Purpose text area (required, multiline)
                    TextFormField(
                      controller: _commentsController,
                      maxLines: 4,
                      style: TextStyle(
                        color: ColorManager.black,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Comments/Purpose *',
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter comments or purpose';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Photo upload section (required for non-advance bills)
                    if (!_isAdvanceRequest) ...[
                      Text(
                        'Photo Upload *',
                        style: TextStyle(
                          color: ColorManager.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      if (_selectedPhoto != null) ...[
                        // Photo Preview
                        Container(
                          width: double.infinity,
                          height: 20.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorManager.grey2),
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.sp),
                                child: Image.file(
                                  _selectedPhoto!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: _clearPhoto,
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                      ],

                      // Photo Upload Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primary,
                                foregroundColor: ColorManager.white,
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.sp),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.secondary,
                                foregroundColor: ColorManager.white,
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.sp),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Conditional fields based on bill type
                    if (_selectedBillType != null && !_isAdvanceRequest) ...[
                      // If NOT advance: Bill Number (optional), Vendor Name (optional)
                      TextFormField(
                        controller: _billNumberController,
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
                            borderSide: BorderSide(
                                color: ColorManager.primary, width: 2),
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

                      TextFormField(
                        controller: _vendorNameController,
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
                            borderSide: BorderSide(
                                color: ColorManager.primary, width: 2),
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

                    if (_isAdvanceRequest) ...[
                      // If advance: Purpose of Advance (required), Expected Amount (required)
                      TextFormField(
                        controller: _advancePurposeController,
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
                            borderSide: BorderSide(
                                color: ColorManager.primary, width: 2),
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the purpose of advance';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),

                      TextFormField(
                        controller: _expectedAmountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: ColorManager.black,
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Expected Amount *',
                          labelStyle: TextStyle(
                            color: ColorManager.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixText: '\$ ',
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
                            borderSide: BorderSide(
                                color: ColorManager.primary, width: 2),
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter expected amount';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            state is PettyCashLoading ? null : _submitForm,
                        icon: state is PettyCashLoading
                            ? SizedBox(
                                height: 20.sp,
                                width: 20.sp,
                                child: CircularProgressIndicator(
                                  color: ColorManager.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: ColorManager.white,
                                size: 20.sp,
                              ),
                        label: Text(
                          state is PettyCashLoading
                              ? 'Submitting...'
                              : (_isAdvanceRequest
                                  ? 'Request Advance'
                                  : 'Submit Bill'),
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
            );
          },
        ),
      ),
    );
  }
}
