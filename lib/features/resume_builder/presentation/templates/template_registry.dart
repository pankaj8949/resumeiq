import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import 'modern_template.dart';
import 'minimal_template.dart';
import 'executive_template.dart';
import 'developer_template.dart';
import 'creative_template.dart';
import 'graduate_template.dart';
import 'academic_template.dart';
import 'product_manager_template.dart';
import 'data_analyst_template.dart';
import 'marketing_template.dart';
import 'sales_template.dart';
import 'finance_template.dart';
import 'operations_template.dart';
import 'two_column_template.dart';
import 'compact_template.dart';
import 'classic_template.dart';
import 'tech_lead_template.dart';
import 'consultant_template.dart';
import 'executive_summary_template.dart';
import 'ats_optimized_template.dart';

/// Template metadata
class TemplateInfo {
  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.factory,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final Widget Function(ResumeEntity resume) factory;
}

/// Registry of all available resume templates
class TemplateRegistry {
  TemplateRegistry._();

  static final List<TemplateInfo> templates = [
    TemplateInfo(
      id: 'modern',
      name: 'Modern Professional',
      description: 'Clean and contemporary design',
      category: 'Professional',
      factory: (resume) => ModernTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'minimal',
      name: 'Minimal ATS-Friendly',
      description: 'Ultra-clean, text-focused design',
      category: 'ATS-Optimized',
      factory: (resume) => MinimalTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'executive',
      name: 'Corporate Executive',
      description: 'Formal and authoritative design',
      category: 'Executive',
      factory: (resume) => ExecutiveTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'developer',
      name: 'Software Developer',
      description: 'Technical-focused layout',
      category: 'Technical',
      factory: (resume) => DeveloperTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'creative',
      name: 'Designer / Creative',
      description: 'Bold and eye-catching design',
      category: 'Creative',
      factory: (resume) => CreativeTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'graduate',
      name: 'Fresh Graduate',
      description: 'Education-focused layout',
      category: 'Entry-Level',
      factory: (resume) => GraduateTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'academic',
      name: 'Academic / Research',
      description: 'Publication and research-focused',
      category: 'Academic',
      factory: (resume) => AcademicTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'product_manager',
      name: 'Product Manager',
      description: 'Impact and metrics-focused',
      category: 'Business',
      factory: (resume) => ProductManagerTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'data_analyst',
      name: 'Data Analyst',
      description: 'Technical and analytical skills emphasized',
      category: 'Technical',
      factory: (resume) => DataAnalystTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'marketing',
      name: 'Marketing Professional',
      description: 'Campaign and results-focused',
      category: 'Business',
      factory: (resume) => MarketingTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'sales',
      name: 'Sales Professional',
      description: 'Results and achievements-focused',
      category: 'Business',
      factory: (resume) => SalesTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'finance',
      name: 'Finance / Accounting',
      description: 'Professional and detail-oriented',
      category: 'Business',
      factory: (resume) => FinanceTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'operations',
      name: 'Operations / Admin',
      description: 'Process and efficiency-focused',
      category: 'Professional',
      factory: (resume) => OperationsTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'two_column',
      name: 'Two-Column Layout',
      description: 'Sidebar with skills and main content',
      category: 'Layout',
      factory: (resume) => TwoColumnTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'compact',
      name: 'One-Page Compact',
      description: 'Condensed layout for one-page resumes',
      category: 'Layout',
      factory: (resume) => CompactTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'classic',
      name: 'Classic',
      description: 'Traditional and formal layout',
      category: 'Professional',
      factory: (resume) => ClassicTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'tech_lead',
      name: 'Tech Lead',
      description: 'Leadership and technical expertise combined',
      category: 'Technical',
      factory: (resume) => TechLeadTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'consultant',
      name: 'Consultant',
      description: 'Client-focused and results-oriented',
      category: 'Business',
      factory: (resume) => ConsultantTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'executive_summary',
      name: 'Executive Summary',
      description: 'High-level overview focused',
      category: 'Executive',
      factory: (resume) => ExecutiveSummaryTemplate(resume: resume),
    ),
    TemplateInfo(
      id: 'ats_optimized',
      name: 'ATS Optimized',
      description: 'Maximum ATS compatibility',
      category: 'ATS-Optimized',
      factory: (resume) => AtsOptimizedTemplate(resume: resume),
    ),
  ];

  /// Get template by ID
  static TemplateInfo? getTemplateById(String id) {
    try {
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get templates by category
  static List<TemplateInfo> getTemplatesByCategory(String category) {
    return templates.where((template) => template.category == category).toList();
  }

  /// Get all unique categories
  static List<String> getCategories() {
    return templates.map((t) => t.category).toSet().toList()..sort();
  }

  /// Get default template (Modern Professional)
  static TemplateInfo getDefaultTemplate() {
    return templates.first;
  }
}
