import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_ai_service.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../core/utils/validators.dart';
import '../core/utils/date_utils.dart' as AppDateUtils;
import '../widgets/common/custom_text_field.dart';

/// Multi-step profile setup page for collecting user information after login
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _hasInitialized = false;

  // Photo upload
  bool _isUploadingPhoto = false;
  String? _photoUrl;
  Uint8List? _photoBytes;

  // AI summary generation
  bool _isGeneratingSummary = false;
  late final FirebaseAIService _aiService = FirebaseAIService();

  // Step 1: Basic Info + Contact & Summary
  final _step1FormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _currentDesignationController = TextEditingController();
  final _linkedInUrlController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _summaryController = TextEditingController();

  // Step 2: Professional Details (Optional)
  final List<Education> _educationList = [];
  final List<Experience> _experienceList = [];
  final List<String> _skillsList = [];
  final List<Project> _projectsList = [];
  final List<Certification> _certificationsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  void _initializeFormData() {
    if (_hasInitialized) return;

    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      _phoneController.text = user.phone ?? '';
      _locationController.text = user.location ?? '';
      _currentDesignationController.text = user.currentDesignation ?? '';
      _linkedInUrlController.text = user.linkedInUrl ?? '';
      _portfolioUrlController.text = user.portfolioUrl ?? '';
      _githubUrlController.text = user.githubUrl ?? '';
      _summaryController.text = user.summary ?? '';
      _photoUrl = user.photoUrl;
      
      // Convert entities to models for Step 2
      _educationList.addAll((user.education).map((e) => Education(
        institution: e.institution,
        degree: e.degree,
        fieldOfStudy: e.fieldOfStudy,
        startDate: e.startDate,
        endDate: e.endDate,
        description: e.description,
        gpa: e.gpa,
      )));
      _experienceList.addAll((user.experience).map((e) => Experience(
        company: e.company,
        position: e.position,
        startDate: e.startDate,
        endDate: e.endDate,
        responsibilities: e.responsibilities,
        location: e.location,
        isCurrentRole: e.isCurrentRole,
      )));
      _skillsList.addAll(user.skills);
      _projectsList.addAll((user.projects).map((p) => Project(
        name: p.name,
        description: p.description,
        technologies: p.technologies,
        url: p.url,
        startDate: p.startDate,
        endDate: p.endDate,
      )));
      _certificationsList.addAll((user.certifications).map((c) => Certification(
        name: c.name,
        issuer: c.issuer,
        issueDate: c.issueDate,
        expiryDate: c.expiryDate,
        credentialId: c.credentialId,
        url: c.url,
      )));
      _hasInitialized = true;
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto || _isSubmitting) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to upload a photo.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      setState(() => _isUploadingPhoto = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final file = result.files.first;
      final maxBytes = 5 * 1024 * 1024;
      if (file.size > maxBytes) {
        setState(() => _isUploadingPhoto = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Max file size is 5MB.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _isUploadingPhoto = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read selected image. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final ext = (file.extension ?? 'jpg').toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid)
          .child('photo_${DateTime.now().millisecondsSinceEpoch}.$ext');

      final task = storageRef.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      await task;
      final url = await storageRef.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        _photoBytes = bytes;
        _isUploadingPhoto = false;
      });

      // Web can be slow to reflect newly uploaded images; bytes preview helps.
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _currentDesignationController.dispose();
    _linkedInUrlController.dispose();
    _portfolioUrlController.dispose();
    _githubUrlController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_currentStep == 0) {
      // Validate Step 1 (Required fields, but validate URLs if provided)
      if (!_step1FormKey.currentState!.validate()) {
        return;
      }
      // Move to next step
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      // Submit profile with all data
      await _submitProfile();
    }
  }

  Future<void> _skipStep() async {
    if (_currentStep == 1) {
      // Skip step 2 and submit with only basic info
      await _submitProfile();
    }
  }

  Future<void> _generateSummaryWithAI() async {
    if (_isSubmitting || _isGeneratingSummary) return;

    final designation = _currentDesignationController.text.trim();
    if (designation.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your current designation first.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      setState(() => _isGeneratingSummary = true);

      final prompt = '''
You are an expert resume writer.

Write a professional resume summary for the following role:
Current designation: "$designation"

Requirements:
- 2 to 3 sentences
- 50 to 80 words
- Professional tone, ATS-friendly keywords
- No bullet points, no emojis, no markdown, no quotes
- Do not invent specific numbers/metrics

Return only the summary text.
''';

      final generated = await _aiService.generateText(
        prompt: prompt,
        temperature: 0.6,
        maxOutputTokens: 220,
      );

      var text = generated.trim();
      // Remove accidental code fences/quotes if present.
      if (text.startsWith('```')) {
        text = text.replaceAll(RegExp(r'^```[a-zA-Z]*\s*'), '');
        text = text.replaceAll(RegExp(r'```$'), '');
        text = text.trim();
      }
      if ((text.startsWith('"') && text.endsWith('"')) ||
          (text.startsWith("'") && text.endsWith("'"))) {
        text = text.substring(1, text.length - 1).trim();
      }

      _summaryController.text = text;
      _summaryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _summaryController.text.length),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI summary failed: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingSummary = false);
    }
  }

  Future<void> _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _fullNameController.text.trim(),
          photoUrl: _photoUrl,
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          currentDesignation: _currentDesignationController.text.trim(),
          linkedInUrl: _linkedInUrlController.text.trim().isEmpty
              ? null
              : _linkedInUrlController.text.trim(),
          portfolioUrl: _portfolioUrlController.text.trim().isEmpty
              ? null
              : _portfolioUrlController.text.trim(),
          githubUrl: _githubUrlController.text.trim().isEmpty
              ? null
              : _githubUrlController.text.trim(),
          summary: _summaryController.text.trim().isEmpty
              ? null
              : _summaryController.text.trim(),
          education: _educationList.isEmpty ? null : _educationList,
          experience: _experienceList.isEmpty ? null : _experienceList,
          skills: _skillsList.isEmpty ? null : _skillsList,
          projects: _projectsList.isEmpty ? null : _projectsList,
          certifications: _certificationsList.isEmpty ? null : _certificationsList,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      final error = ref.read(authNotifierProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndSignOutToLogin() async {
    if (_isSubmitting) return;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go back to login?'),
        content: const Text(
          'You will be signed out so you can sign in with another account. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;
    if (!mounted) return;

    await ref.read(authNotifierProvider.notifier).signOut();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);

    if (uri == null ||
        (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: baseTheme.iconTheme.copyWith(color: Colors.white70),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x552563EB),
        selectionHandleColor: Color(0xFF2563EB),
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF1B2236),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2C3757)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
      ),
    );

    // If profile becomes complete, this page will be replaced by AuthWrapper
    if (authState.user != null && _isProfileComplete(authState.user!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: const Color(0xFF101322),
        appBar: AppBar(
          title: const Text('Complete Your Profile'),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF101322),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_currentStep == 1) {
                      setState(() => _currentStep = 0);
                    } else {
                      await _confirmAndSignOutToLogin();
                    }
                  },
          ),
        ),
        body: Column(
          children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: AppTheme.surfaceColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentStep + 1} / 2',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF101322),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentStep == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _isSubmitting ? null : _skipStep,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.85),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "I'll add these information later",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() => _currentStep = 0),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _saveAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              disabledBackgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.55),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Complete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          disabledBackgroundColor:
                              AppTheme.primaryColor.withOpacity(0.55),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the following required information',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          // Photo upload
          InkWell(
            onTap: (_isUploadingPhoto || _isSubmitting) ? null : _pickAndUploadPhoto,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827).withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                children: [
                  // Avatar + edit badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1B2236),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: ClipOval(
                          child: _photoBytes != null
                              ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                              : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                  ? Image.network(_photoUrl!, fit: BoxFit.cover)
                                  : const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white70,
                                      size: 22,
                                    ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF101322),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_isUploadingPhoto)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.35),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Photo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'JPG or PNG, max 5MB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.65),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: Validators.name,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.phoneNumber,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location *',
              hintText: 'Enter your city or location',
              prefixIcon: Icon(Icons.location_on),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.required(value, fieldName: 'Location'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentDesignationController,
            decoration: const InputDecoration(
              labelText: 'Current Designation *',
              hintText: 'e.g., Software Engineer',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                Validators.required(value, fieldName: 'Current Designation'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 32),
          Text(
            'Contact & Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your professional links and summary (optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _linkedInUrlController,
            decoration: const InputDecoration(
              labelText: 'LinkedIn URL',
              hintText: 'https://linkedin.com/in/yourprofile',
              prefixIcon: Icon(Icons.business),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _portfolioUrlController,
            decoration: const InputDecoration(
              labelText: 'Portfolio URL',
              hintText: 'https://yourportfolio.com',
              prefixIcon: Icon(Icons.public),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _githubUrlController,
            decoration: const InputDecoration(
              labelText: 'GitHub URL',
              hintText: 'https://github.com/yourusername',
              prefixIcon: Icon(Icons.code),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            decoration: InputDecoration(
              labelText: 'Professional Summary',
              hintText: 'Briefly describe your professional background...',
              alignLabelWithHint: true,
              suffixIcon: _isGeneratingSummary
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: (_isSubmitting) ? null : _generateSummaryWithAI,
                      icon: const Icon(Icons.auto_awesome),
                    ),
            ),
            maxLines: 5,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 24),
          Text(
            '* Required fields',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.work_outline, size: 64, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Professional Details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your education, experience, skills, projects, and certifications (optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Education Section
        _buildSectionHeader('Education', Icons.school, () => _showAddEducationDialog()),
        const SizedBox(height: 12),
        if (_educationList.isEmpty)
          _buildEmptyState('No education entries yet. Tap "Add Education" to add one.')
        else
          ..._educationList.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
            return _buildEducationCard(education, index);
          }),
        const SizedBox(height: 24),

        // Experience Section
        _buildSectionHeader('Experience', Icons.work, () => _showAddExperienceDialog()),
        const SizedBox(height: 12),
        if (_experienceList.isEmpty)
          _buildEmptyState('No experience entries yet. Tap "Add Experience" to add one.')
        else
          ..._experienceList.asMap().entries.map((entry) {
            final index = entry.key;
            final experience = entry.value;
            return _buildExperienceCard(experience, index);
          }),
        const SizedBox(height: 24),

        // Skills Section
        _buildSectionHeader('Skills', Icons.star, () => _showAddSkillDialog()),
        const SizedBox(height: 12),
        if (_skillsList.isEmpty)
          _buildEmptyState('No skills yet. Tap "Add Skill" to add one.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillsList.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return Chip(
                label: Text(skill),
                onDeleted: () => setState(() => _skillsList.removeAt(index)),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),

        // Projects Section
        _buildSectionHeader('Projects', Icons.code, () => _showAddProjectDialog()),
        const SizedBox(height: 12),
        if (_projectsList.isEmpty)
          _buildEmptyState('No projects yet. Tap "Add Project" to add one.')
        else
          ..._projectsList.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return _buildProjectCard(project, index);
          }),
        const SizedBox(height: 24),

        // Certifications Section
        _buildSectionHeader('Certifications', Icons.verified, () => _showAddCertificationDialog()),
        const SizedBox(height: 12),
        if (_certificationsList.isEmpty)
          _buildEmptyState('No certifications yet. Tap "Add Certification" to add one.')
        else
          ..._certificationsList.asMap().entries.map((entry) {
            final index = entry.key;
            final certification = entry.value;
            return _buildCertificationCard(certification, index);
          }),
        const SizedBox(height: 24),

        Text(
          'You can skip this step and add these details later',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEducationCard(Education education, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.school, color: AppTheme.primaryColor),
        title: Text(education.degree),
        subtitle: Text(
          '${education.institution}${education.fieldOfStudy != null ? ' - ${education.fieldOfStudy}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _educationList.removeAt(index)),
        ),
        onTap: () => _showEditEducationDialog(index),
      ),
    );
  }

  Widget _buildExperienceCard(Experience experience, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.work, color: AppTheme.primaryColor),
        title: Text(experience.position),
        subtitle: Text(
          '${experience.company}${experience.location != null ? ' - ${experience.location}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _experienceList.removeAt(index)),
        ),
        onTap: () => _showEditExperienceDialog(index),
      ),
    );
  }

  Widget _buildProjectCard(Project project, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.code, color: AppTheme.primaryColor),
        title: Text(project.name),
        subtitle: Text(project.description ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _projectsList.removeAt(index)),
        ),
        onTap: () => _showEditProjectDialog(index),
      ),
    );
  }

  Widget _buildCertificationCard(Certification certification, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.verified, color: AppTheme.primaryColor),
        title: Text(certification.name),
        subtitle: Text(certification.issuer ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _certificationsList.removeAt(index)),
        ),
        onTap: () => _showEditCertificationDialog(index),
      ),
    );
  }

  // Dialog methods
  void _showAddEducationDialog() => _showEducationDialog();
  void _showEditEducationDialog(int index) => _showEducationDialog(index: index);

  void _showEducationDialog({int? index}) {
    final institutionController = TextEditingController(
      text: index != null ? _educationList[index].institution : '',
    );
    final degreeController = TextEditingController(
      text: index != null ? _educationList[index].degree : '',
    );
    final fieldController = TextEditingController(
      text: index != null ? _educationList[index].fieldOfStudy ?? '' : '',
    );
    final descriptionController = TextEditingController(
      text: index != null ? _educationList[index].description ?? '' : '',
    );
    DateTime? startDate = index != null ? _educationList[index].startDate : null;
    DateTime? endDate = index != null ? _educationList[index].endDate : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Education' : 'Add Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: institutionController,
                  label: 'Institution *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: degreeController,
                  label: 'Degree *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fieldController,
                  label: 'Field of Study',
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate != null
                        ? AppDateUtils.DateUtils.formatDate(startDate, format: 'MMM yyyy')
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => startDate = date);
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate != null
                        ? AppDateUtils.DateUtils.formatDate(endDate, format: 'MMM yyyy')
                        : 'Select date (optional)',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => endDate = date);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (institutionController.text.trim().isEmpty ||
                    degreeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                setState(() {
                  final education = Education(
                    institution: institutionController.text.trim(),
                    degree: degreeController.text.trim(),
                    fieldOfStudy: fieldController.text.trim().isEmpty
                        ? null
                        : fieldController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  if (index != null) {
                    _educationList[index] = education;
                  } else {
                    _educationList.add(education);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceDialog() => _showExperienceDialog();
  void _showEditExperienceDialog(int index) => _showExperienceDialog(index: index);

  void _showExperienceDialog({int? index}) {
    final companyController = TextEditingController(
      text: index != null ? _experienceList[index].company : '',
    );
    final positionController = TextEditingController(
      text: index != null ? _experienceList[index].position : '',
    );
    final locationController = TextEditingController(
      text: index != null ? _experienceList[index].location ?? '' : '',
    );
    final responsibilitiesController = TextEditingController(
      text: index != null ? _experienceList[index].responsibilities.join('\n') : '',
    );
    final descriptionController = TextEditingController(
      text: index != null ? _experienceList[index].description ?? '' : '',
    );
    DateTime? startDate = index != null ? _experienceList[index].startDate : null;
    DateTime? endDate = index != null ? _experienceList[index].endDate : null;
    bool isCurrent = index != null ? (_experienceList[index].isCurrentRole ?? false) : false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Experience' : 'Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: companyController,
                  label: 'Company *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: positionController,
                  label: 'Position *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: locationController,
                  label: 'Location',
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Current Role'),
                  value: isCurrent,
                  onChanged: (value) =>
                      setDialogState(() => isCurrent = value ?? false),
                ),
                if (!isCurrent) ...[
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      startDate != null
                          ? AppDateUtils.DateUtils.formatDate(startDate, format: 'MMM yyyy')
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setDialogState(() => startDate = date);
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      endDate != null
                          ? AppDateUtils.DateUtils.formatDate(endDate, format: 'MMM yyyy')
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setDialogState(() => endDate = date);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  controller: responsibilitiesController,
                  label: 'Responsibilities (one per line)',
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (companyController.text.trim().isEmpty ||
                    positionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                setState(() {
                  final experience = Experience(
                    company: companyController.text.trim(),
                    position: positionController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? null
                        : locationController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    startDate: startDate,
                    endDate: isCurrent ? null : endDate,
                    isCurrentRole: isCurrent,
                    responsibilities: responsibilitiesController.text
                        .trim()
                        .split('\n')
                        .where((r) => r.trim().isNotEmpty)
                        .toList(),
                  );
                  if (index != null) {
                    _experienceList[index] = experience;
                  } else {
                    _experienceList.add(experience);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: CustomTextField(
          controller: controller,
          label: 'Skill',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _skillsList.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() => _showProjectDialog();
  void _showEditProjectDialog(int index) => _showProjectDialog(index: index);

  void _showProjectDialog({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? _projectsList[index].name : '',
    );
    final descController = TextEditingController(
      text: index != null ? _projectsList[index].description ?? '' : '',
    );
    final techController = TextEditingController(
      text: index != null ? _projectsList[index].technologies ?? '' : '',
    );
    final urlController = TextEditingController(
      text: index != null ? _projectsList[index].url ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index != null ? 'Edit Project' : 'Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Project Name *',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: techController,
                label: 'Technologies',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: urlController,
                label: 'URL',
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(() {
                final project = Project(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  technologies: techController.text.trim().isEmpty
                      ? null
                      : techController.text.trim(),
                  url: urlController.text.trim().isEmpty
                      ? null
                      : urlController.text.trim(),
                );
                if (index != null) {
                  _projectsList[index] = project;
                } else {
                  _projectsList.add(project);
                }
              });
              Navigator.pop(context);
            },
            child: Text(index != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCertificationDialog() => _showCertificationDialog();
  void _showEditCertificationDialog(int index) => _showCertificationDialog(index: index);

  void _showCertificationDialog({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? _certificationsList[index].name : '',
    );
    final issuerController = TextEditingController(
      text: index != null ? _certificationsList[index].issuer ?? '' : '',
    );
    DateTime? issueDate = index != null ? _certificationsList[index].issueDate : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Certification' : 'Add Certification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Certification Name *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: issuerController,
                  label: 'Issuing Organization',
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Issue Date'),
                  subtitle: Text(
                    issueDate != null
                        ? AppDateUtils.DateUtils.formatDate(issueDate, format: 'MMM yyyy')
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: issueDate ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => issueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                setState(() {
                  final certification = Certification(
                    name: nameController.text.trim(),
                    issuer: issuerController.text.trim().isEmpty
                        ? null
                        : issuerController.text.trim(),
                    issueDate: issueDate,
                  );
                  if (index != null) {
                    _certificationsList[index] = certification;
                  } else {
                    _certificationsList.add(certification);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isProfileComplete(UserModel user) {
    return user.displayName != null &&
        user.displayName!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.location != null &&
        user.location!.isNotEmpty &&
        user.currentDesignation != null &&
        user.currentDesignation!.isNotEmpty;
  }
}
