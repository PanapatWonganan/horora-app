import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/thai_zodiac_service.dart';
import '../shared/widgets/gradient_button.dart';
import '../auth/widgets/auth_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  DateTime? _selectedDate;
  ThaiZodiac? _thaiZodiac; // ปีนักษัตรไทย
  bool _isLoading = true;
  bool _isSaving = false;
  final _authService = AuthService.instance;
  
  // User data
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user from auth
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // อัปเดตข้อมูลเบื้องต้นจาก auth
        _userData['email'] = currentUser.email;

        // ดึงชื่อจาก user
        if (currentUser.name.isNotEmpty) {
          _userData['full_name'] = currentUser.name;
        }

        // ดึงวันเกิดและคำนวณปีนักษัตร
        if (currentUser.birthDate != null) {
          _userData['birth_date'] = currentUser.birthDate!.toIso8601String().split('T')[0];

          // คำนวณปีนักษัตรจากวันเกิด
          final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(currentUser.birthDate!);
          _userData['thai_animal'] = thaiZodiac.animalName;
          _userData['thai_year_name'] = thaiZodiac.thaiName;
        } else if (currentUser.thaiAnimal != null) {
          _userData['thai_animal'] = currentUser.thaiAnimal;
          _userData['thai_year_name'] = currentUser.thaiYearName ?? 'ปี${currentUser.thaiAnimal}';
        }
      }
      
      // พยายามดึงข้อมูลจากฐานข้อมูล
      try {
        final profile = await _authService.getUserProfile();
        
        if (profile != null) {
          // อัปเดตข้อมูลจากฐานข้อมูล
          _userData = {
            ..._userData,
            ...profile,
          };
        }
      } catch (e) {
        debugPrint('Error fetching profile from database: $e');
      }
      
      // ตั้งค่าข้อมูลใน controllers
      _nameController.text = _userData['full_name'] ?? '';
      
      if (_userData['birth_date'] != null && _userData['birth_date'].isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(_userData['birth_date']);
          _birthDateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
          _thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(_selectedDate!);
        } catch (e) {
          debugPrint('Error parsing birth date: $e');
        }
      }
      
    } catch (e) {
      debugPrint('Error in _loadUserProfile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.lightText,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.darkSurface),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);

        // คำนวณปีนักษัตรจากวันเกิด
        _thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(picked);
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        // สร้างข้อมูลที่จะอัปเดต
        final updatedData = {
          'full_name': _nameController.text.trim(),
        };
        
        // เพิ่มวันเกิดถ้ามีการเลือก
        if (_selectedDate != null) {
          updatedData['birth_date'] = _selectedDate!.toIso8601String();
          if (_thaiZodiac != null) {
            updatedData['thai_animal'] = _thaiZodiac!.animalName;
            updatedData['thai_year_name'] = _thaiZodiac!.thaiName;
          }
        }
        
        // อัปเดตข้อมูลในฐานข้อมูล
        await _authService.updateUserProfile(updatedData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกข้อมูลสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          
          // ส่งค่า true กลับไปยังหน้าโปรไฟล์เพื่อให้รู้ว่ามีการอัปเดตข้อมูล
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        debugPrint('Error saving profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('บันทึกข้อมูลไม่สำเร็จ: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.lightText,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 32),
                        _buildEditForm(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: _userData['profile_image_url'] != null && _userData['profile_image_url'].isNotEmpty
                  ? Image.network(
                      _userData['profile_image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'อีเมล: ${_userData['email'] ?? ''}',
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _nameController,
          hintText: 'ชื่อ-นามสกุล',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอกชื่อ-นามสกุล';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _birthDateController,
          hintText: 'วันเกิด (วว/ดด/ปปปป)',
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) {
            // วันเกิดไม่จำเป็นต้องกรอก
            return null;
          },
        ),
        if (_thaiZodiac != null && _selectedDate != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _thaiZodiac!.thaiName,
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_thaiZodiac!.animalName} (${_thaiZodiac!.englishName})',
                        style: TextStyle(
                          color: AppColors.lightText.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSaveButton() {
    return GradientButton(
      text: 'บันทึกข้อมูล',
      onPressed: _saveProfile,
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      width: double.infinity,
      isLoading: _isSaving,
    );
  }
} 