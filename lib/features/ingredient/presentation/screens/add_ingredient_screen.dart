import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ingredient.dart';
import '../providers/ingredient_provider.dart';

class AddIngredientScreen extends ConsumerStatefulWidget {
  final Ingredient? ingredientToEdit;

  const AddIngredientScreen({super.key, this.ingredientToEdit});

  @override
  ConsumerState<AddIngredientScreen> createState() =>
      _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _expiryDate;
  String _selectedCategory = AppConstants.ingredientCategories.first;

  bool get _isEditing => widget.ingredientToEdit != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill form if editing an existing ingredient
    if (_isEditing) {
      _nameController.text = widget.ingredientToEdit!.name;
      _quantityController.text = widget.ingredientToEdit!.quantity;
      _expiryDate = widget.ingredientToEdit!.expiryDate;

      // ตรวจสอบว่าหมวดหมู่ที่รับมาอยู่ในรายการที่มีหรือไม่
      if (AppConstants.ingredientCategories.contains(
        widget.ingredientToEdit!.category,
      )) {
        _selectedCategory = widget.ingredientToEdit!.category;
      } else {
        // ถ้าไม่พบในรายการ ให้ใช้ค่าเริ่มต้น
        _selectedCategory = AppConstants.ingredientCategories.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  _isEditing ? 'แก้ไขวัตถุดิบ' : 'เพิ่มวัตถุดิบใหม่',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Ingredient Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อวัตถุดิบ',
                    hintText: 'เช่น ไก่, มะเขือเทศ, นม',
                  ),
                  keyboardType: TextInputType.text,
                  enableInteractiveSelection: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุชื่อวัตถุดิบ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'ปริมาณ',
                    hintText: 'เช่น 500 กรัม, 2 ชิ้น, 1 ลิตร',
                  ),
                  keyboardType: TextInputType.text,
                  enableInteractiveSelection: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุปริมาณ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expiry Date Field
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'วันหมดอายุ (ไม่บังคับ)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _expiryDate == null
                              ? 'เลือกวันที่'
                              : DateFormat('dd/MM/yyyy').format(_expiryDate!),
                          style: TextStyle(
                            color:
                                _expiryDate == null
                                    ? AppColors.grey
                                    : AppColors.textPrimary,
                          ),
                        ),
                        Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                  items:
                      AppConstants.ingredientCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null ||
                        !AppConstants.ingredientCategories.contains(value)) {
                      return 'โปรดเลือกหมวดหมู่ที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        _isEditing ? 'อัปเดตวัตถุดิบ' : 'เพิ่มวัตถุดิบ',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // ทำความสะอาดข้อมูล input ก่อน
      final trimmedName = _nameController.text.trim();

      // Create ingredient object
      final ingredient = Ingredient(
        id:
            _isEditing
                ? widget.ingredientToEdit!.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
        name: trimmedName,
        quantity: _quantityController.text.trim(),
        expiryDate: _expiryDate,
        category: _selectedCategory,
      );

      // ตรวจสอบว่ามีวัตถุดิบซ้ำหรือไม่อย่างละเอียด
      final ingredients = ref.read(ingredientProvider).asData?.value ?? [];
      final normalizedName = trimmedName.toLowerCase();

      final isDuplicate =
          !_isEditing &&
          ingredients.any((existing) {
            final existingName = existing.name.trim().toLowerCase();

            // เช็คแบบตรงๆ ก่อน
            if (existingName == normalizedName) return true;

            // เช็คแบบพิเศษสำหรับวัตถุดิบที่มักเขียนหลายแบบ
            if ((normalizedName == 'เนื้อวัว' || normalizedName == 'เนื้อ') &&
                (existingName == 'เนื้อวัว' || existingName == 'เนื้อ')) {
              return true;
            }

            if ((normalizedName == 'หมู' || normalizedName == 'เนื้อหมู') &&
                (existingName == 'หมู' || existingName == 'เนื้อหมู')) {
              return true;
            }

            if ((normalizedName == 'ไก่' || normalizedName == 'เนื้อไก่') &&
                (existingName == 'ไก่' || existingName == 'เนื้อไก่')) {
              return true;
            }

            return false;
          });

      if (isDuplicate) {
        // แสดงข้อความเตือนถ้าซ้ำ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('วัตถุดิบ "$trimmedName" มีอยู่แล้ว'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // ออกจากฟังก์ชันเลย ไม่ต้องเพิ่ม
      }

      // Save ingredient using provider
      if (_isEditing) {
        ref.read(ingredientProvider.notifier).updateIngredient(ingredient);
      } else {
        ref.read(ingredientProvider.notifier).addIngredient(ingredient);
      }

      // Close screen
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'อัปเดตวัตถุดิบแล้ว' : 'เพิ่มวัตถุดิบแล้ว',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
