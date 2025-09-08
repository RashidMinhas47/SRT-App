import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/job_card/controllers/job_card_controller.dart';
import 'package:bayanat/modules/job_card/models/job_card_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobCardFormScreen extends StatefulWidget {
  const JobCardFormScreen({Key? key}) : super(key: key);

  @override
  State<JobCardFormScreen> createState() => _JobCardFormScreenState();
}

class _JobCardFormScreenState extends State<JobCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerDisplayController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _customerBuildingController = TextEditingController();
  final _customerHouseFlatController = TextEditingController();
  final _complaintNumberController = TextEditingController();
  final _workDescriptionController = TextEditingController();

  String? _selectedHighlight;
  final _controller = Get.put(JobCardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'New Job Card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ColorManager.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C248A)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading form data...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: ColorManager.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Card Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the required information to create a new job card',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Selection (searchable)
                FormField<int>(
                  validator: (v) => _controller.selectedCustomerId.value == 0
                      ? 'Please select a customer'
                      : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _openCustomerSearchDialog,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Select Customer *',
                                labelStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                helperText:
                                    'Tap to search and select a customer',
                                helperStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: ColorManager.kPrimary, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                suffixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                              ),
                              controller: _customerDisplayController,
                              readOnly: true,
                            ),
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              state.errorText ?? '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                // Customer Mobile Number
                TextFormField(
                  controller: _customerMobileController,
                  decoration: InputDecoration(
                    labelText: 'Customer Mobile Number *',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Enter the customer\'s mobile number',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: const Icon(Icons.phone, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.isEmpty ?? true) {
                      return 'Mobile number is required';
                    }
                    if (!_controller.isValidMobileNumber(v!)) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location (optional)
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Enter the job location',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon:
                        const Icon(Icons.location_on, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Assigned User Selection (optional)
                DropdownButtonFormField<int>(
                  icon:
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  value: _controller.selectedUserId.value == 0
                      ? null
                      : _controller.selectedUserId.value,
                  decoration: InputDecoration(
                    labelText: 'Assigned User',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Select the user assigned to this job',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: _controller.users
                      .map((user) => DropdownMenuItem<int>(
                            value: user['id'] as int,
                            child: Text(
                              user['name'] as String,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (int? value) {
                    _controller.selectedUserId.value = value ?? 0;
                  },
                ),
                const SizedBox(height: 20),

                // Customer Building Name/Number
                TextFormField(
                  controller: _customerBuildingController,
                  decoration: InputDecoration(
                    labelText: 'Building Name/Number',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Enter the building name or number',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: const Icon(Icons.business, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Customer House/Flat Number
                TextFormField(
                  controller: _customerHouseFlatController,
                  decoration: InputDecoration(
                    labelText: 'House/Flat Number',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Enter the house or flat number',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: const Icon(Icons.home_work, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Complaint Number
                TextFormField(
                  controller: _complaintNumberController,
                  decoration: InputDecoration(
                    labelText: 'Complaint Number',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Enter the complaint reference number',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon:
                        const Icon(Icons.receipt_long, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Work Description (optional)
                TextFormField(
                  controller: _workDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Work Description',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Describe the work to be performed',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon:
                        const Icon(Icons.description, color: Colors.grey),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Highlight Selection (optional)
                DropdownButtonFormField<String>(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  value: _selectedHighlight,
                  decoration: InputDecoration(
                    labelText: 'Highlight',
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    helperText: 'Select whether this job should be highlighted',
                    helperStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: ColorManager.kPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: _controller.highlightOptions
                      .map((option) => DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(
                              option['label']!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedHighlight = value;
                    });
                    _controller.selectedHighlight.value = value ?? '';
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.kPrimary.withOpacity(0.8),
                        ColorManager.kPrimary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _controller.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _controller.isSubmitting.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Submit Job Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Display
                _controller.error.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _controller.error.value,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final jobCard = JobCardModel(
        customerName: _customerNameController.text,
        customerMobileNumber: _customerMobileController.text,
        location: _locationController.text,
        assignedUserId: _controller.selectedUserId.value,
        customerBuildingName: _customerBuildingController.text.isNotEmpty
            ? _customerBuildingController.text
            : null,
        customerHouseFlatNumber: _customerHouseFlatController.text.isNotEmpty
            ? _customerHouseFlatController.text
            : null,
        complaintNumber: _complaintNumberController.text.isNotEmpty
            ? _complaintNumberController.text
            : null,
        workDescription: _workDescriptionController.text,
        highlight: _selectedHighlight ?? 'no',
      );

      await _controller.submitJobCard(jobCard);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerDisplayController.dispose();
    _customerMobileController.dispose();
    _locationController.dispose();
    _customerBuildingController.dispose();
    _customerHouseFlatController.dispose();
    _complaintNumberController.dispose();
    _workDescriptionController.dispose();
    super.dispose();
  }

  void _openCustomerSearchDialog() async {
    final List<Map<String, dynamic>> allCustomers =
        List<Map<String, dynamic>>.from(_controller.customers);
    String query = '';
    final TextEditingController searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> filtered =
            List<Map<String, dynamic>>.from(allCustomers);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void applyFilter(String q) {
              setStateDialog(() {
                query = q;
                filtered = allCustomers
                    .where((c) => (c['translated_display_name']
                                ?.toString()
                                .toLowerCase() ??
                            '')
                        .contains(query.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text('Select Customer'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search customer...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: applyFilter,
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No results'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final customer = filtered[index];
                                final customerName =
                                    customer['translated_display_name']
                                            ?.toString() ??
                                        '';
                                return ListTile(
                                  title: Text(customerName),
                                  onTap: () {
                                    final int id = customer['id'] as int;
                                    _controller.selectedCustomerId.value = id;
                                    _customerNameController.text = customerName;
                                    _customerDisplayController.text =
                                        customerName;
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
