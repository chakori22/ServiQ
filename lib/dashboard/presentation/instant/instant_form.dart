import 'package:flutter/material.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/components/textfield.dart';

class InstantForm extends StatefulWidget {
  const InstantForm({super.key});

  @override
  State<InstantForm> createState() => _InstantFormState();
}

class _InstantFormState extends State<InstantForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.neutralGreyColor60,
      appBar: AppBar(
        elevation: 4,
        animateColor: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Instant Service',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColor.neutralGreyColor700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  labelText: 'Description',
                  floatingLabel: true,
                  controller: _titleController,
                  hintText: 'Enter description',
                  prefixText: '',
                  keyboardType: TextInputType.text,
                  maxLines: 4,
                  maxLength: 200,
                  enabledLabelColor: AppColor.indicativeBlueColor700,

                  borderColor: AppColor.neutralGreyColor300,
                  onChanged: (value) {
                    //context.read<LoginBloc>().add(MobileNumberChanged(value));
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  labelText: 'Budget',
                  floatingLabel: true,
                  controller: _budgetController,
                  hintText: 'Enter budget',
                  prefixText: '₹',
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  maxLength: 20,
                  enabledLabelColor: AppColor.indicativeBlueColor700,

                  borderColor: AppColor.neutralGreyColor300,
                  onChanged: (value) {
                    //context.read<LoginBloc>().add(MobileNumberChanged(value));
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Service Required',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
