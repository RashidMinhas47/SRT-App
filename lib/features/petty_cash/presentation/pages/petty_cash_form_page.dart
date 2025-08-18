import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../bloc/petty_cash_bloc.dart';

class PettyCashFormPage extends StatefulWidget {
  const PettyCashFormPage({super.key});

  @override
  State<PettyCashFormPage> createState() => _PettyCashFormPageState();
}

class _PettyCashFormPageState extends State<PettyCashFormPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _billTypes = const [
    'Material Purchase',
    'Food/Meals',
    'Transport/Fuel',
    'Miscellaneous',
    'Advance Request',
  ];

  String? _selectedType;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _billNumberController = TextEditingController();
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _customerProjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _selectedDate;
  List<File> _photos = [];

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _commentsController.dispose();
    _billNumberController.dispose();
    _vendorNameController.dispose();
    _customerProjectController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickPhotos(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 60);
    if (result.isNotEmpty) {
      final files = result.map((e) => File(e.path)).toList();
      context.read<PettyCashBloc>().add(UploadImageEvent(files));
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one photo')),
        );
        return;
      }
      context.read<PettyCashBloc>().add(
            SubmitPettyCashEvent(
              billType: _selectedType!,
              amount: double.tryParse(_amountController.text) ?? 0,
              date: _selectedDate!,
              comments: _commentsController.text,
              billNumber: _billNumberController.text,
              vendorName: _vendorNameController.text,
              customerProjectName: _customerProjectController.text,
              location: _locationController.text,
              photos: _photos,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PettyCashBloc(),
      child: BlocConsumer<PettyCashBloc, PettyCashState>(
        listener: (context, state) {
          if (state is PettyCashSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Petty cash submitted')),
            );
            Navigator.pop(context);
          } else if (state is PettyCashError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ImageUploaded) {
            setState(() => _photos = state.photos);
          }
        },
        builder: (context, state) {
          final isLoading = state is PettyCashLoading || state is ImageUploading;
          return Scaffold(
            appBar: AppBar(title: const Text('Petty Cash')),
            body: AbsorbPointer(
              absorbing: isLoading,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.sp),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // a) Bill Type dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: _billTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedType = v);
                          context.read<PettyCashBloc>().add(BillTypeChangedEvent(v));
                        },
                        decoration: const InputDecoration(labelText: 'Bill Type'),
                        validator: (v) => v == null || v.isEmpty ? '' : null,
                      ),
                      SizedBox(height: 2.h),

                      // b) Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        validator: (v) => (v == null || v.isEmpty) ? '' : null,
                      ),
                      SizedBox(height: 2.h),

                      // c) Date picker
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(labelText: 'Date'),
                        validator: (v) => (v == null || v.isEmpty) ? '' : null,
                      ),
                      SizedBox(height: 2.h),

                      // d) Photo upload (mandatory)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _pickPhotos(context),
                            child: const Text('Upload Photos'),
                          ),
                          SizedBox(width: 3.w),
                          if (_photos.isNotEmpty)
                            Text('${_photos.length} selected'),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      if (_photos.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _photos
                              .map((f) => Image.file(f, width: 18.w, height: 18.w, fit: BoxFit.cover))
                              .toList(),
                        ),
                      SizedBox(height: 2.h),

                      // e) Comments field
                      TextFormField(
                        controller: _commentsController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Comments'),
                      ),
                      SizedBox(height: 2.h),

                      // f) Bill Number (optional)
                      TextFormField(
                        controller: _billNumberController,
                        decoration: const InputDecoration(labelText: 'Bill Number (optional)'),
                      ),
                      SizedBox(height: 2.h),

                      // g) Vendor Name
                      TextFormField(
                        controller: _vendorNameController,
                        decoration: const InputDecoration(labelText: 'Vendor Name'),
                      ),
                      SizedBox(height: 2.h),

                      // h) Customer/Project Name
                      TextFormField(
                        controller: _customerProjectController,
                        decoration: const InputDecoration(labelText: 'Customer/Project Name'),
                      ),
                      SizedBox(height: 2.h),

                      // i) Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                      SizedBox(height: 4.h),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submit(context),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

