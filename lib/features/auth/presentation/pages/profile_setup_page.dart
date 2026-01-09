import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Profile setup page for collecting basic user information after login
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInUrlController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  void _initializeFormData() {
    if (_hasInitialized) return;
    
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _fullNameController.text = user.displayName!;
      }
      if (user.phone != null && user.phone!.isNotEmpty) {
        _phoneController.text = user.phone!;
      }
      if (user.location != null && user.location!.isNotEmpty) {
        _locationController.text = user.location!;
      }
      if (user.linkedInUrl != null && user.linkedInUrl!.isNotEmpty) {
        _linkedInUrlController.text = user.linkedInUrl!;
      }
      if (user.portfolioUrl != null && user.portfolioUrl!.isNotEmpty) {
        _portfolioUrlController.text = user.portfolioUrl!;
      }
      if (user.githubUrl != null && user.githubUrl!.isNotEmpty) {
        _githubUrlController.text = user.githubUrl!;
      }
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInUrlController.dispose();
    _portfolioUrlController.dispose();
    _githubUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          linkedInUrl: _linkedInUrlController.text.trim().isEmpty
              ? null
              : _linkedInUrlController.text.trim(),
          portfolioUrl: _portfolioUrlController.text.trim().isEmpty
              ? null
              : _portfolioUrlController.text.trim(),
          githubUrl: _githubUrlController.text.trim().isEmpty
              ? null
              : _githubUrlController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Profile updated successfully, AuthWrapper will automatically navigate
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

  String? _validateUrl(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);
    
    if (uri == null || (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    // If profile becomes complete, this page will be replaced by AuthWrapper
    if (authState.user != null && _isProfileComplete(authState.user!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_add,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide some basic information to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Full Name (Required)
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),

              // Phone Number (Required)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  // Basic phone validation
                  final phoneRegex = RegExp(r'^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),

              // Location (Required)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'Enter your city or location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 24),

              // Optional URLs Section
              Text(
                'Optional Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can add these later in your profile settings',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),

              // LinkedIn URL (Optional)
              TextFormField(
                controller: _linkedInUrlController,
                decoration: const InputDecoration(
                  labelText: 'LinkedIn URL',
                  hintText: 'https://linkedin.com/in/yourprofile',
                  prefixIcon: Icon(Icons.work),
                ),
                keyboardType: TextInputType.url,
                validator: (value) => _validateUrl(value, 'LinkedIn URL'),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),

              // Portfolio URL (Optional)
              TextFormField(
                controller: _portfolioUrlController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL',
                  hintText: 'https://yourportfolio.com',
                  prefixIcon: Icon(Icons.public),
                ),
                keyboardType: TextInputType.url,
                validator: (value) => _validateUrl(value, 'Portfolio URL'),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 16),

              // GitHub URL (Optional)
              TextFormField(
                controller: _githubUrlController,
                decoration: const InputDecoration(
                  labelText: 'GitHub URL',
                  hintText: 'https://github.com/yourusername',
                  prefixIcon: Icon(Icons.code),
                ),
                keyboardType: TextInputType.url,
                validator: (value) => _validateUrl(value, 'GitHub URL'),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Helper text
              Text(
                '* Required fields',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isProfileComplete(user) {
    return user.displayName != null &&
        user.displayName!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.location != null &&
        user.location!.isNotEmpty;
  }
}

