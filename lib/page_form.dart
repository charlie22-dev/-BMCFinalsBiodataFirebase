import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final fullNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final ageController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final birthplaceController = TextEditingController();
  final nationalityController = TextEditingController();
  final religionController = TextEditingController();
  final addressController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailController = TextEditingController();

  final elementaryController = TextEditingController();
  final elementaryYearController = TextEditingController();
  final highSchoolController = TextEditingController();
  final highSchoolYearController = TextEditingController();
  final collegeController = TextEditingController();
  final courseController = TextEditingController();
  final collegeYearController = TextEditingController();


  final fatherNameController = TextEditingController();
  final fatherOccupationController = TextEditingController();
  final motherNameController = TextEditingController();
  final motherOccupationController = TextEditingController();
  final siblingsController = TextEditingController();
  final guardianNameController = TextEditingController();
  final guardianContactController = TextEditingController();


  final skillsController = TextEditingController();
  final careerObjectiveController = TextEditingController();

  
  final List<_ProjectEntry> projects = [_ProjectEntry()];

  String? gender;
  String? civilStatus;
  DateTime? dateOfBirth;
  bool isSaving = false;

  List<TextEditingController> get _controllers => [
    fullNameController,
    nicknameController,
    ageController,
    dateOfBirthController,
    birthplaceController,
    nationalityController,
    religionController,
    addressController,
    contactNumberController,
    emailController,
    elementaryController,
    elementaryYearController,
    highSchoolController,
    highSchoolYearController,
    collegeController,
    courseController,
    collegeYearController,
    fatherNameController,
    fatherOccupationController,
    motherNameController,
    motherOccupationController,
    siblingsController,
    guardianNameController,
    guardianContactController,
    skillsController,
    careerObjectiveController,
  ];

  void addProject() => setState(() => projects.add(_ProjectEntry()));

  void removeProject(int index) {
    setState(() => projects.removeAt(index).dispose());
  }

  Future<void> pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;

   
    int age = now.year - picked.year;
    if (now.month < picked.month ||
        (now.month == picked.month && now.day < picked.day)) {
      age--;
    }

    setState(() {
      dateOfBirth = picked;
      dateOfBirthController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ageController.text = age.toString();
    });
  }

  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await firestore.collection('students').add({
        'fullName': fullNameController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()),
        'dateOfBirth': dateOfBirth != null
            ? Timestamp.fromDate(dateOfBirth!)
            : null,
        'birthplace': birthplaceController.text.trim(),
        'gender': gender,
        'civilStatus': civilStatus,
        'nationality': nationalityController.text.trim(),
        'religion': religionController.text.trim(),
        'address': addressController.text.trim(),
        'contactNumber': contactNumberController.text.trim(),
        'email': emailController.text.trim(),
        'education': {
          'elementary': {
            'school': elementaryController.text.trim(),
            'yearGraduated': elementaryYearController.text.trim(),
          },
          'highSchool': {
            'school': highSchoolController.text.trim(),
            'yearGraduated': highSchoolYearController.text.trim(),
          },
          'college': {
            'school': collegeController.text.trim(),
            'course': courseController.text.trim(),
            'yearGraduated': collegeYearController.text.trim(),
          },
        },
        'familyBackground': {
          'father': {
            'name': fatherNameController.text.trim(),
            'occupation': fatherOccupationController.text.trim(),
          },
          'mother': {
            'name': motherNameController.text.trim(),
            'occupation': motherOccupationController.text.trim(),
          },
          'numberOfSiblings': int.tryParse(siblingsController.text.trim()),
          'guardian': {
            'name': guardianNameController.text.trim(),
            'contactNumber': guardianContactController.text.trim(),
          },
        },
        'skills': skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'careerObjective': careerObjectiveController.text.trim(),
        'projects': projects
            .where((p) => p.title.text.trim().isNotEmpty)
            .map(
              (p) => {
                'title': p.title.text.trim(),
                'description': p.description.text.trim(),
              },
            )
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data saved successfully')));

      _formKey.currentState!.reset();
      for (final c in _controllers) {
        c.clear();
      }
      setState(() {
        gender = null;
        civilStatus = null;
        dateOfBirth = null;
        for (final p in projects) {
          p.dispose();
        }
        projects
          ..clear()
          ..add(_ProjectEntry());
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final p in projects) {
      p.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'This field is required' : null;

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = int.tryParse(value.trim());
    return (n == null || n < 0) ? 'Enter a valid number' : null;
  }

  String? _optionalYear(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final year = int.tryParse(value.trim());
    if (year == null || year < 1900 || year > DateTime.now().year + 10) {
      return 'Enter a valid year';
    }
    return null;
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        validator: _required,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biodata Form')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Personal Information'),
              _field(fullNameController, 'Full Name', validator: _required),
              _field(nicknameController, 'Nickname'),
              _field(
                dateOfBirthController,
                'Date of Birth',
                validator: _required,
                readOnly: true,
                onTap: pickDateOfBirth,
              ),
              _field(
                ageController,
                'Age',
                validator: _required,
                keyboardType: TextInputType.number,
              ),
              _field(birthplaceController, 'Birthplace', validator: _required),
              _dropdown('Gender', gender, const [
                'Male',
                'Female',
                'Other',
              ], (v) => setState(() => gender = v)),
              _dropdown('Civil Status', civilStatus, const [
                'Single',
                'Married',
                'Widowed',
                'Separated',
              ], (v) => setState(() => civilStatus = v)),
              _field(
                nationalityController,
                'Nationality',
                validator: _required,
              ),
              _field(religionController, 'Religion'),
              _field(
                addressController,
                'Address',
                validator: _required,
                maxLines: 2,
              ),
              _field(
                contactNumberController,
                'Contact Number',
                validator: _required,
                keyboardType: TextInputType.phone,
              ),
              _field(
                emailController,
                'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (_required(v) != null) return _required(v);
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v!.trim());
                  return ok ? null : 'Enter a valid email address';
                },
              ),
              _sectionTitle('Educational Background'),
              _field(elementaryController, 'Elementary School'),
              _field(
                elementaryYearController,
                'Year Graduated (Elementary)',
                keyboardType: TextInputType.number,
                validator: _optionalYear,
              ),
              _field(highSchoolController, 'High School'),
              _field(
                highSchoolYearController,
                'Year Graduated (High School)',
                keyboardType: TextInputType.number,
                validator: _optionalYear,
              ),
              _field(collegeController, 'College / University'),
              _field(courseController, 'Course'),
              _field(
                collegeYearController,
                'Year Graduated (College)',
                keyboardType: TextInputType.number,
                validator: _optionalYear,
              ),
              _sectionTitle('Family Background'),
              _field(fatherNameController, "Father's Name"),
              _field(fatherOccupationController, "Father's Occupation"),
              _field(motherNameController, "Mother's Maiden Name"),
              _field(motherOccupationController, "Mother's Occupation"),
              _field(
                siblingsController,
                'Number of Siblings',
                keyboardType: TextInputType.number,
                validator: _optionalNumber,
              ),
              _field(guardianNameController, 'Guardian Name'),
              _field(
                guardianContactController,
                'Guardian Contact Number',
                keyboardType: TextInputType.phone,
              ),
              _sectionTitle('Skills'),
              _field(
                skillsController,
                'Skills (separate with commas)',
                maxLines: 2,
              ),
              _sectionTitle('Career Objective'),
              _field(
                careerObjectiveController,
                'Career Objective',
                maxLines: 4,
              ),
              _sectionTitle('Projects'),
              for (var i = 0; i < projects.length; i++)
                Card(
                  key: ObjectKey(projects[i]),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Project ${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (projects.length > 1)
                              IconButton(
                                tooltip: 'Remove project',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => removeProject(i),
                              ),
                          ],
                        ),
                        _field(projects[i].title, 'Project Title'),
                        _field(
                          projects[i].description,
                          'Description',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: addProject,
                icon: const Icon(Icons.add),
                label: const Text('Add Project'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSaving ? null : saveData,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save to Firebase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectEntry {
  final title = TextEditingController();
  final description = TextEditingController();

  void dispose() {
    title.dispose();
    description.dispose();
  }
}
