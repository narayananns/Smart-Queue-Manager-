import 'package:flutter/material.dart';

import 'package:koku/screens/queue_management/queue_details_screen.dart';
import 'package:uuid/uuid.dart';

class CreateQueueScreen extends StatefulWidget {
  final bool isEditing;
  final String? initialQueueName;
  final String? initialCategory;
  final String? initialOtherCategory;
  final String? initialAddress;
  final String? initialDescription;
  final String? initialProcessTime;
  final String? queueId;

  const CreateQueueScreen({
    super.key,
    this.isEditing = false,
    this.initialQueueName,
    this.initialCategory,
    this.initialOtherCategory,
    this.initialAddress,
    this.initialDescription,
    this.initialProcessTime,
    this.queueId,
  });

  @override
  State<CreateQueueScreen> createState() => _CreateQueueScreenState();
}

class _CreateQueueScreenState extends State<CreateQueueScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _queueNameController;
  late final TextEditingController _otherCategoryController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _processTimeController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _queueNameController = TextEditingController(text: widget.initialQueueName);
    _otherCategoryController = TextEditingController(
      text: widget.initialOtherCategory,
    );
    _addressController = TextEditingController(text: widget.initialAddress);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _processTimeController = TextEditingController(
      text: widget.initialProcessTime,
    );

    // Set selected category if it exists in the list, otherwise handle logic
    if (widget.initialCategory != null) {
      if (_categoryIcons.containsKey(widget.initialCategory)) {
        _selectedCategory = widget.initialCategory;
      } else {
        // If it's a custom category, we might want to set "Other" and fill the other controller
        // Logic depends on how you stored "Other" vs "Real Category".
        // Assuming simple mapping:
        _selectedCategory = "Other";
        _otherCategoryController.text = widget.initialCategory!;
      }
    }
  }

  final Map<String, IconData> _categoryIcons = {
    "Men's Hair Salon": Icons.face,
    "Women's Hair Salon": Icons.face_3,
    "Unisex Hair Salon": Icons.content_cut,
    "Spa and Wellness": Icons.spa,
    "Medical or Dental Clinic": Icons.medical_services,
    "Pharmacy": Icons.local_pharmacy,
    "Hospital": Icons.local_hospital,
    "Restaurant": Icons.restaurant,
    "Fast Food": Icons.fastfood,
    "Coffee Shop": Icons.coffee,
    "Bank": Icons.account_balance,
    "Administrative or Government Service": Icons.assured_workload,
    "Garage or Car Service": Icons.car_repair,
    "Event or Concert": Icons.event,
    "Gym or Fitness Club": Icons.fitness_center,
    "Amusement or Water Park": Icons.attractions,
    "Supermarket or Hypermarket": Icons.shopping_cart,
    "School or University": Icons.school,
    "Tech Support or Customer Service": Icons.support_agent,
    "Cinema": Icons.movie,
    "Other": Icons.category,
  };

  List<String> get _categories => _categoryIcons.keys.toList();

  @override
  void dispose() {
    _queueNameController.dispose();
    _otherCategoryController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _processTimeController.dispose();
    super.dispose();
  }

  void _handleCreateQueue() {
    if (_formKey.currentState!.validate()) {
      // Logic to create queue
      String category = _selectedCategory == "Other"
          ? _otherCategoryController.text.trim()
          : _selectedCategory!;

      if (widget.isEditing) {
        // Return updated data
        Navigator.pop(context, {
          'queueName': _queueNameController.text.trim(),
          'category': category,
          'address': _addressController.text.trim(),
          'description': _descriptionController.text.trim(),
          'processTime': _processTimeController.text.trim(),
        });
        return;
      }

      // Generate a unique ID
      var uuid = const Uuid();
      String queueId = uuid
          .v4()
          .substring(0, 8)
          .toUpperCase(); // Short ID for easier copying

      // Navigate to the new queue details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QueueDetailsScreen(
            queueName: _queueNameController.text.trim(),
            queueId: queueId,
            category: category,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Edit Queue" : "Create a Queue",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.isEditing ? "Edit your queue" : "Set up your queue",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: h * 0.03),

                  // Queue Name
                  TextFormField(
                    controller: _queueNameController,
                    decoration: const InputDecoration(
                      labelText: "Queue Name",
                      hintText: "e.g. Downtown Barber Shop",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a queue name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: h * 0.02),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcons[category],
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Please select a category" : null,
                  ),
                  SizedBox(height: h * 0.02),

                  // Other Category Input (Conditional)
                  if (_selectedCategory == "Other") ...[
                    TextFormField(
                      controller: _otherCategoryController,
                      decoration: const InputDecoration(
                        labelText: "Specify Category",
                        hintText: "e.g. Pet Grooming",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (_selectedCategory == "Other" &&
                            (value == null || value.trim().isEmpty)) {
                          return "Please specify the category";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.02),
                  ],

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      hintText: "e.g. 123 Main St, New York",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter an address";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: h * 0.02),

                  // Process Time
                  TextFormField(
                    controller: _processTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Process time per client (minutes)",
                      hintText: "e.g. 15 Mins",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter process time";
                      }
                      if (int.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: h * 0.02),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Describe your service...",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a description";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: h * 0.03),

                  // Create Queue Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _handleCreateQueue,
                    child: Text(
                      widget.isEditing ? "Update Queue" : "Create Queue",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
