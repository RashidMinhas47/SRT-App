import 'dart:io';

import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/presentation_layer/bloc/petty_cash_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../main/presentation_layer/components/components.dart';

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
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _vendorController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickBills(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 50);
    if (result.isNotEmpty) {
      context.read<PettyCashBloc>().add(
            AddBillPhotoEvent(result.map((e) => File(e.path)).toList()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petty Cash'),
      ),
      body: BlocConsumer<PettyCashBloc, PettyCashState>(
        listener: (context, state) {
          if (state is SubmitPettyCashSuccessState) {
            defaultToast(msg: 'Submitted');
            Navigator.pop(context);
          } else if (state is SubmitPettyCashErrorState) {
            errorToast(msg: state.message);
          }
        },
        builder: (context, state) {
          final billPhotos = state is BillPhotosChangedState
              ? state.photos
              : <File>[];
          return Padding(
            padding: EdgeInsets.all(16.sp),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultFormField(
                      label: 'Vendor Name',
                      controller: _vendorController,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? '' : null,
                    ),
                    SizedBox(height: 2.h),
                    defaultFormField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLength: 4,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? '' : null,
                    ),
                    SizedBox(height: 2.h),
                    defaultFormField(
                      label: 'Amount',
                      controller: _amountController,
                      type: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? '' : null,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedDate.toLocal()}'.split(' ')[0],
                            style: TextStyle(
                              color: ColorManager.secondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        defaultButton(
                          onPressed: () => _pickBills(context),
                          text: 'Add Bills',
                          width: 40.w,
                          height: 6.h,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(billPhotos.length, (i) {
                              return Stack(
                                children: [
                                  Image.file(
                                    billPhotos[i],
                                    height: 12.h,
                                    width: 12.h,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: InkWell(
                                      onTap: () => context
                                          .read<PettyCashBloc>()
                                          .add(RemoveBillPhotoEvent(i)),
                                      child: Container(
                                        color: Colors.black54,
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
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
                    SizedBox(height: 4.h),
                    state is SubmitPettyCashLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : defaultButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final amount =
                                    double.tryParse(_amountController.text) ?? 0;
                                context.read<PettyCashBloc>().add(
                                      SubmitPettyCashEvent(
                                        vendorName: _vendorController.text,
                                        description: _descriptionController.text,
                                        amount: amount,
                                        date: _selectedDate,
                                      ),
                                    );
                              }
                            },
                            text: 'Submit',
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

