import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/user_dashboard/data/models/cv_request_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class CreateCvPage extends ConsumerStatefulWidget {
  const CreateCvPage({super.key});

  @override
  ConsumerState<CreateCvPage> createState() => _CreateCvPageState();
}

class _CreateCvPageState extends ConsumerState<CreateCvPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Personal
  final _fullNameCtrl = TextEditingController(text: 'John Doe');
  final _emailCtrl = TextEditingController(text: 'john.doe@example.com');
  final _phoneCtrl = TextEditingController(text: '+91 9876543210');
  final _locationCtrl = TextEditingController(text: 'Bangalore, India');
  final _linkedinCtrl = TextEditingController(text: 'linkedin.com/in/johndoe');
  final _githubCtrl = TextEditingController(text: 'github.com/johndoe');
  final _portfolioCtrl = TextEditingController(text: 'johndoe.dev');

  // Step 2: Professional
  final _positionCtrl = TextEditingController(text: 'Flutter Developer');
  final _currentTitleCtrl = TextEditingController(text: 'Software Engineer');
  final _summaryCtrl = TextEditingController(
      text: 'Passionate mobile application developer with 3+ years experience building scalable Flutter applications.');
  final _experienceCtrl = TextEditingController(text: '3 Years');
  final _objectiveCtrl = TextEditingController(
      text: 'Seeking a senior role in a high-growth tech organization to build exceptional cross-platform products.');

  // Step 3: Work Experience
  final List<WorkExperience> _experiences = [
    WorkExperience(
      id: '1',
      company: 'Acme Technologies',
      position: 'Flutter Developer',
      startDate: DateTime(2022, 1),
      responsibilities: 'Led the core mobile development team, introduced CI/CD pipelines, decreased app crash rate by 40%.',
      isCurrentlyWorking: true,
    ),
  ];
  final _expCompanyCtrl = TextEditingController();
  final _expPositionCtrl = TextEditingController();
  final _expRespCtrl = TextEditingController();
  bool _expCurrentWorking = false;

  // Step 4: Education
  final List<Education> _educationList = [
    const Education(
      id: '1',
      degree: 'B.Tech in Computer Science',
      institution: 'National Institute of Technology',
      university: 'State Technical University',
      startYear: 2018,
      endYear: 2022,
      cgpaOrPercentage: '8.8 CGPA',
    ),
  ];
  final _eduDegreeCtrl = TextEditingController();
  final _eduInstCtrl = TextEditingController();
  final _eduUnivCtrl = TextEditingController();
  final _eduStartYearCtrl = TextEditingController();
  final _eduEndYearCtrl = TextEditingController();
  final _eduCgpaCtrl = TextEditingController();

  // Step 5: Skills
  final List<String> _technicalSkills = ['Flutter', 'Dart', 'Firebase', 'RESTful APIs', 'Bloc/Riverpod', 'Git'];
  final List<String> _programmingLanguages = ['Dart', 'Kotlin', 'Java', 'Python', 'TypeScript'];
  final List<String> _frameworks = ['Flutter', 'React', 'Node.js'];
  final List<String> _tools = ['VS Code', 'Android Studio', 'Figma', 'Postman', 'GitHub Actions'];
  final List<String> _softSkills = ['Team Leadership', 'Agile/Scrum', 'Problem Solving', 'Effective Communication'];
  final _skillInputCtrl = TextEditingController();

  // Step 6: Projects
  final List<Project> _projects = [
    const Project(
      id: '1',
      name: 'OmniPay - FinTech Mobile Wallet',
      description: 'Built a secure real-time wallet application supporting QR payments and bank transfers.',
      technologies: ['Flutter', 'Firebase', 'Stripe API'],
      githubUrl: 'github.com/johndoe/omnipay',
    ),
  ];
  final _projNameCtrl = TextEditingController();
  final _projDescCtrl = TextEditingController();
  final _projTechCtrl = TextEditingController();
  final _projUrlCtrl = TextEditingController();
  final _projGithubCtrl = TextEditingController();

  // Step 7: Additional Info
  final _certificationsCtrl = TextEditingController(text: 'Google Certified Associate Cloud Engineer');
  final _achievementsCtrl = TextEditingController(text: 'Winner of National Hackathon 2023');
  final _languagesCtrl = TextEditingController(text: 'English (Fluent), Hindi (Native)');
  final _hobbiesCtrl = TextEditingController(text: 'Open Source, Tech Blogging, Chess');
  final _notesCtrl = TextEditingController(text: 'Please emphasize state management architecture and clean code.');

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _linkedinCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _positionCtrl.dispose();
    _currentTitleCtrl.dispose();
    _summaryCtrl.dispose();
    _experienceCtrl.dispose();
    _objectiveCtrl.dispose();
    _expCompanyCtrl.dispose();
    _expPositionCtrl.dispose();
    _expRespCtrl.dispose();
    _eduDegreeCtrl.dispose();
    _eduInstCtrl.dispose();
    _eduUnivCtrl.dispose();
    _eduStartYearCtrl.dispose();
    _eduEndYearCtrl.dispose();
    _eduCgpaCtrl.dispose();
    _skillInputCtrl.dispose();
    _projNameCtrl.dispose();
    _projDescCtrl.dispose();
    _projTechCtrl.dispose();
    _projUrlCtrl.dispose();
    _projGithubCtrl.dispose();
    _certificationsCtrl.dispose();
    _achievementsCtrl.dispose();
    _languagesCtrl.dispose();
    _hobbiesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveDraft() async {
    if (_isSubmitting) return;

    final user = ref.read(currentUserProvider);
    final firebaseAuthUser = firebaseConfigured ? FirebaseAuth.instance.currentUser : null;
    final userId = firebaseAuthUser?.uid ?? user?.uid ?? 'user_001';

    setState(() => _isSubmitting = true);

    final draftCv = CvRequestModel(
      id: 'cv_draft_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: '${_positionCtrl.text.trim().isEmpty ? "Untitled" : _positionCtrl.text.trim()} CV (Draft)',
      position: _positionCtrl.text.trim().isEmpty ? 'General' : _positionCtrl.text.trim(),
      status: 'DRAFT',
      isDraft: true,
      personalInfo: PersonalInfo(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        linkedIn: _linkedinCtrl.text.trim(),
        github: _githubCtrl.text.trim(),
        portfolioUrl: _portfolioCtrl.text.trim(),
      ),
      professionalInfo: ProfessionalInfo(
        applyingPosition: _positionCtrl.text.trim(),
        currentJobTitle: _currentTitleCtrl.text.trim(),
        professionalSummary: _summaryCtrl.text.trim(),
        totalExperience: _experienceCtrl.text.trim(),
        careerObjective: _objectiveCtrl.text.trim(),
      ),
      experiences: _experiences,
      education: _educationList,
      skills: SkillSet(
        technicalSkills: _technicalSkills,
        programmingLanguages: _programmingLanguages,
        frameworks: _frameworks,
        tools: _tools,
        softSkills: _softSkills,
      ),
      projects: _projects,
      createdAt: DateTime.now(),
    );

    try {
      if (firebaseConfigured && firebaseAuthUser != null) {
        await ref.read(firebaseRepositoryProvider).saveCv(draftCv);
      }
      final existingIdx = MockDataService.cvRequests.indexWhere((c) => c.id == draftCv.id);
      if (existingIdx >= 0) {
        MockDataService.cvRequests[existingIdx] = draftCv;
      } else {
        MockDataService.cvRequests.insert(0, draftCv);
      }

      if (firebaseConfigured && firebaseAuthUser == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.warning,
            content: Text('Saved locally. Sign in with a Firebase account to persist data in Firebase.'),
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryLight,
          content: Text('CV details saved as draft.'),
        ),
      );
      context.go('/dashboard/my-cvs');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(firebaseErrorMessage(e)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    if (_fullNameCtrl.text.trim().isEmpty || _positionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please provide your name and target applying position in Steps 1 & 2.'),
        ),
      );
      setState(() => _currentStep = 0);
      return;
    }

    final user = ref.read(currentUserProvider);
    final firebaseAuthUser = firebaseConfigured ? FirebaseAuth.instance.currentUser : null;
    final userId = firebaseAuthUser?.uid ?? user?.uid ?? 'user_001';

    setState(() => _isSubmitting = true);

    final newCv = CvRequestModel(
      id: 'cv_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: '${_positionCtrl.text.trim()} Professional CV',
      position: _positionCtrl.text.trim(),
      status: 'PENDING',
      isDraft: false,
      personalInfo: PersonalInfo(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        linkedIn: _linkedinCtrl.text.trim(),
        github: _githubCtrl.text.trim(),
        portfolioUrl: _portfolioCtrl.text.trim(),
      ),
      professionalInfo: ProfessionalInfo(
        applyingPosition: _positionCtrl.text.trim(),
        currentJobTitle: _currentTitleCtrl.text.trim(),
        professionalSummary: _summaryCtrl.text.trim(),
        totalExperience: _experienceCtrl.text.trim(),
        careerObjective: _objectiveCtrl.text.trim(),
      ),
      experiences: _experiences,
      education: _educationList,
      skills: SkillSet(
        technicalSkills: _technicalSkills,
        programmingLanguages: _programmingLanguages,
        frameworks: _frameworks,
        tools: _tools,
        softSkills: _softSkills,
      ),
      projects: _projects,
      additionalInfo: AdditionalInfo(
        certifications: _certificationsCtrl.text.split(',').map((s) => s.trim()).toList(),
        achievements: _achievementsCtrl.text.split(',').map((s) => s.trim()).toList(),
        languages: _languagesCtrl.text.split(',').map((s) => s.trim()).toList(),
        hobbies: _hobbiesCtrl.text.split(',').map((s) => s.trim()).toList(),
        additionalNotes: _notesCtrl.text.trim(),
      ),
      createdAt: DateTime.now(),
    );

    try {
      if (firebaseConfigured && firebaseAuthUser != null) {
        await ref.read(firebaseRepositoryProvider).saveCv(newCv);
      }
      final existingIdx = MockDataService.cvRequests.indexWhere((c) => c.id == newCv.id);
      if (existingIdx >= 0) {
        MockDataService.cvRequests[existingIdx] = newCv;
      } else {
        MockDataService.cvRequests.insert(0, newCv);
      }

      if (firebaseConfigured && firebaseAuthUser == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.warning,
            content: Text('Submitted locally. Sign in with a Firebase account to persist data in Firebase.'),
          ),
        );
      }

      if (!mounted) return;

      // Show required submission success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 54, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                Text('Request Submitted!', style: AppTextStyles.heading2, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Your CV request has been submitted successfully. Our team will review your details and start preparing your professional CV.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/dashboard/my-cvs');
                  },
                  child: const Text('Go to My CVs'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(firebaseErrorMessage(e)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Professional CV Request', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'Provide comprehensive details so our manual CV team can craft the ideal resume for you.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _saveDraft,
                  icon: _isSubmitting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Draft'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Step Indicator Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepTab(0, '1. Personal'),
                      _buildStepDivider(),
                      _buildStepTab(1, '2. Professional'),
                      _buildStepDivider(),
                      _buildStepTab(2, '3. Experience'),
                      _buildStepDivider(),
                      _buildStepTab(3, '4. Education'),
                      _buildStepDivider(),
                      _buildStepTab(4, '5. Skills'),
                      _buildStepDivider(),
                      _buildStepTab(5, '6. Projects'),
                      _buildStepDivider(),
                      _buildStepTab(6, '7. Additional'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Step Form Body
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildStep1Personal(),
                      if (_currentStep == 1) _buildStep2Professional(),
                      if (_currentStep == 2) _buildStep3Experience(),
                      if (_currentStep == 3) _buildStep4Education(),
                      if (_currentStep == 4) _buildStep5Skills(),
                      if (_currentStep == 5) _buildStep6Projects(),
                      if (_currentStep == 6) _buildStep7Additional(),
                      const SizedBox(height: 36),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Navigation Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            OutlinedButton.icon(
                              onPressed: _prevStep,
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Previous Step'),
                            )
                          else
                            const SizedBox.shrink(),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _isSubmitting ? null : _saveDraft,
                                child: const Text('Save as Draft'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _nextStep,
                                icon: _isSubmitting
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Icon(_currentStep == 6 ? Icons.check_circle_outline : Icons.arrow_forward, size: 16),
                                label: Text(_currentStep == 6 ? 'Submit CV Request' : 'Next Step'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentStep == 6 ? AppColors.success : AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return InkWell(
      onTap: () => setState(() => _currentStep = step),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isActive
                  ? AppColors.accent
                  : (isDone ? AppColors.success : AppColors.border),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 20,
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // STEP 1: PERSONAL INFORMATION
  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Personal Information', style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Text('Contact details that will appear at the top of your resume.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email_outlined)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Current Location (City, Country)', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _linkedinCtrl,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile URL', prefixIcon: Icon(Icons.link)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _githubCtrl,
                decoration: const InputDecoration(labelText: 'GitHub / GitLab Profile URL', prefixIcon: Icon(Icons.code)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _portfolioCtrl,
          decoration: const InputDecoration(labelText: 'Portfolio Website URL', prefixIcon: Icon(Icons.language)),
        ),
      ],
    );
  }

  // STEP 2: PROFESSIONAL INFORMATION
  Widget _buildStep2Professional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Professional Information', style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Text('Target career goals and professional identity.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _positionCtrl,
                decoration: const InputDecoration(labelText: 'Applying Position * (e.g. Flutter Developer)', prefixIcon: Icon(Icons.work_outline)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _currentTitleCtrl,
                decoration: const InputDecoration(labelText: 'Current Job Title', prefixIcon: Icon(Icons.badge_outlined)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienceCtrl,
          decoration: const InputDecoration(labelText: 'Total Experience (e.g. 3 Years, Fresher)', prefixIcon: Icon(Icons.timelapse)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _summaryCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Professional Summary',
            hintText: 'Brief summary highlighting your strengths, key domains, and industry experience...',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _objectiveCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Career Objective',
            hintText: 'What kind of challenges and roles are you aspiring toward?',
          ),
        ),
      ],
    );
  }

  // STEP 3: WORK EXPERIENCE
  Widget _buildStep3Experience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 3: Work Experience', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text('Add past and current employment records.', style: AppTextStyles.bodySmall),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddExperienceDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Experience'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_experiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('No work experience added yet. Click "Add Experience" above.')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _experiences.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exp = _experiences[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: AppColors.accent, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${exp.position} at ${exp.company}', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            '${exp.startDate.year} - ${exp.isCurrentlyWorking ? "Present" : exp.endDate?.year ?? ""}',
                            style: AppTextStyles.bodySmall,
                          ),
                          if (exp.responsibilities != null) ...[
                            const SizedBox(height: 6),
                            Text(exp.responsibilities!, style: AppTextStyles.bodySmall),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => setState(() => _experiences.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddExperienceDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Add Work Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _expCompanyCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
                const SizedBox(height: 12),
                TextField(controller: _expPositionCtrl, decoration: const InputDecoration(labelText: 'Job Position')),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Currently working here'),
                  value: _expCurrentWorking,
                  onChanged: (val) => setDlgState(() => _expCurrentWorking = val ?? false),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _expRespCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Key Responsibilities / Impact'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_expCompanyCtrl.text.isNotEmpty) {
                  setState(() {
                    _experiences.add(
                      WorkExperience(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        company: _expCompanyCtrl.text.trim(),
                        position: _expPositionCtrl.text.trim(),
                        startDate: DateTime.now(),
                        isCurrentlyWorking: _expCurrentWorking,
                        responsibilities: _expRespCtrl.text.trim(),
                      ),
                    );
                  });
                  _expCompanyCtrl.clear();
                  _expPositionCtrl.clear();
                  _expRespCtrl.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: EDUCATION
  Widget _buildStep4Education() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 4: Education', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text('Degrees, universities, and academic milestones.', style: AppTextStyles.bodySmall),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddEducationDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Education'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _educationList.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final edu = _educationList[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu.degree, style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Text('${edu.institution} • ${edu.startYear} - ${edu.endYear ?? "Present"}', style: AppTextStyles.bodySmall),
                        if (edu.cgpaOrPercentage != null) ...[
                          const SizedBox(height: 4),
                          Text('Score: ${edu.cgpaOrPercentage!}', style: AppTextStyles.caption),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => setState(() => _educationList.removeAt(index)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddEducationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _eduDegreeCtrl, decoration: const InputDecoration(labelText: 'Degree / Certificate')),
              const SizedBox(height: 12),
              TextField(controller: _eduInstCtrl, decoration: const InputDecoration(labelText: 'Institution / College')),
              const SizedBox(height: 12),
              TextField(controller: _eduUnivCtrl, decoration: const InputDecoration(labelText: 'University (Optional)')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _eduStartYearCtrl, decoration: const InputDecoration(labelText: 'Start Year'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _eduEndYearCtrl, decoration: const InputDecoration(labelText: 'End Year'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _eduCgpaCtrl, decoration: const InputDecoration(labelText: 'CGPA or Percentage')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_eduDegreeCtrl.text.isNotEmpty) {
                setState(() {
                  _educationList.add(
                    Education(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      degree: _eduDegreeCtrl.text.trim(),
                      institution: _eduInstCtrl.text.trim(),
                      university: _eduUnivCtrl.text.trim(),
                      startYear: int.tryParse(_eduStartYearCtrl.text) ?? 2020,
                      endYear: int.tryParse(_eduEndYearCtrl.text),
                      cgpaOrPercentage: _eduCgpaCtrl.text.trim(),
                    ),
                  );
                });
                _eduDegreeCtrl.clear();
                _eduInstCtrl.clear();
                _eduUnivCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // STEP 5: SKILLS
  Widget _buildStep5Skills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Skills & Competencies', style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Text('Categorized skills to maximize ATS keyword scoring.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 24),
        _buildSkillCategorySection('Technical Skills', _technicalSkills),
        const SizedBox(height: 20),
        _buildSkillCategorySection('Programming Languages', _programmingLanguages),
        const SizedBox(height: 20),
        _buildSkillCategorySection('Frameworks & Libraries', _frameworks),
        const SizedBox(height: 20),
        _buildSkillCategorySection('Developer Tools & Cloud', _tools),
        const SizedBox(height: 20),
        _buildSkillCategorySection('Soft Skills & Leadership', _softSkills),
      ],
    );
  }

  Widget _buildSkillCategorySection(String title, List<String> skillList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...skillList.map(
              (skill) => Chip(
                label: Text(skill),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => setState(() => skillList.remove(skill)),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              onPressed: () => _showAddSkillTagDialog(skillList, title),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSkillTagDialog(List<String> targetList, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to $category'),
        content: TextField(
          controller: _skillInputCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Skill name (e.g. Docker, GraphQL)'),
          onSubmitted: (_) {
            if (_skillInputCtrl.text.trim().isNotEmpty) {
              setState(() => targetList.add(_skillInputCtrl.text.trim()));
              _skillInputCtrl.clear();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_skillInputCtrl.text.trim().isNotEmpty) {
                setState(() => targetList.add(_skillInputCtrl.text.trim()));
                _skillInputCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // STEP 6: PROJECTS
  Widget _buildStep6Projects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 6: Featured Projects', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text('Showcase your key practical achievements and code repositories.', style: AppTextStyles.bodySmall),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddProjectDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Project'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _projects.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = _projects[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch_outlined, color: AppColors.accent, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppTextStyles.labelLarge),
                        if (p.description != null) ...[
                          const SizedBox(height: 4),
                          Text(p.description!, style: AppTextStyles.bodySmall),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: p.technologies.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10)))).toList(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => setState(() => _projects.removeAt(index)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Featured Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _projNameCtrl, decoration: const InputDecoration(labelText: 'Project Name')),
              const SizedBox(height: 12),
              TextField(controller: _projDescCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: _projTechCtrl, decoration: const InputDecoration(labelText: 'Tech Stack (comma separated)')),
              const SizedBox(height: 12),
              TextField(controller: _projGithubCtrl, decoration: const InputDecoration(labelText: 'GitHub Repository URL')),
              const SizedBox(height: 12),
              TextField(controller: _projUrlCtrl, decoration: const InputDecoration(labelText: 'Live Project Demo URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_projNameCtrl.text.isNotEmpty) {
                setState(() {
                  _projects.add(
                    Project(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _projNameCtrl.text.trim(),
                      description: _projDescCtrl.text.trim(),
                      technologies: _projTechCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
                      githubUrl: _projGithubCtrl.text.trim(),
                      projectUrl: _projUrlCtrl.text.trim(),
                    ),
                  );
                });
                _projNameCtrl.clear();
                _projDescCtrl.clear();
                _projTechCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // STEP 7: ADDITIONAL INFORMATION
  Widget _buildStep7Additional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 7: Additional Information & Review', style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Text('Certifications, honors, spoken languages, and developer instructions.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 24),
        TextFormField(
          controller: _certificationsCtrl,
          decoration: const InputDecoration(
            labelText: 'Certifications',
            hintText: 'AWS Certified, PMP, Flutter Expert (comma-separated)',
            prefixIcon: Icon(Icons.workspace_premium_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _achievementsCtrl,
          decoration: const InputDecoration(
            labelText: 'Achievements & Awards',
            hintText: 'Hackathon winner, Patent holder, Published paper',
            prefixIcon: Icon(Icons.emoji_events_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _languagesCtrl,
                decoration: const InputDecoration(labelText: 'Languages Spoken', prefixIcon: Icon(Icons.translate)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _hobbiesCtrl,
                decoration: const InputDecoration(labelText: 'Hobbies & Interests', prefixIcon: Icon(Icons.sports_esports_outlined)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Special Notes for CV Developer Team',
            hintText: 'Mention specific industries, color preferences, or sections to emphasize...',
          ),
        ),
      ],
    );
  }
}

