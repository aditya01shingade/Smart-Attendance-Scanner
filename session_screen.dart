import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? department;
  String? semester;
  String? category;
  String? course;
  late String dateTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, Map<String, Map<String, List<String>>>> courseData = {
    'Information Technology': {
      'Sem-I': {
        'Major': ['Programming with C', 'Database Management Systems'],
        'Major Practical': [
          'Module-I : Programming with C Practical',
          'Module-II : Database Management Systems Practical'
        ],
        'OE': ['Elementary Statistical Techniques for Economics'],
        'VSC': ['Combinational and Sequential Design Practical'],
        'SEC': ['Office Tools for Data Management Practical'],
        'AEC': ['Introduction to Communication Skills in English I'],
        'VEC': ['Indian Constitution'],
        'IKS': ['Indian Knowledge Systems'],
        'CC': ['Introduction to Cultural Activities']
      },
      'Sem-II': {
        'Major': ['OOPs with C++', 'Web Designing'],
        'Major Practical': [
          'Module-I : Object Oriented Programming using C++ Practical',
          'Module-II : Web Designing Practical'
        ],
        'Minor': ['Statistics Minor Practical-II'],
        'OE': ['Elementary Mathematics for Economics'],
        'VSC': ['Assembly Language Programming (Practical)'],
        'SEC': ['PL-SQL (Practical)'],
        'AEC': ['हिंदी भाषा : कौशल के आधार', 'भाषिक कौशल्यांचे उपयोजन - १'],
        'VEC': ['Environmental Management & Sustainable Development-II'],
        'CC': ['Foundation and Exploration of Performing and Fine Art']
      },
      'Sem-III': {
        'Courses': [
          'Python Programming',
          'Data Structures',
          'Computer Networks',
          'Operating Systems',
          'Applied Mathematics'
        ]
      },
      'Sem-IV': {
        'Courses': [
          'Core Java',
          'Introduction to Embedded Systems',
          'Computer Oriented Statistical Techniques',
          'Software Engineering',
          'Computer Graphics & Animation'
        ]
      },
      'Sem-V': {
        'Courses': [
          'Software Project Management',
          'Internet of Things: Theory and Practice',
          'Advanced Web Development',
          'Linux Server Administration',
          'Advanced Java Technologies'
        ]
      },
      'Sem-VI': {
        'Courses': [
          'Software Testing and Quality Assurance',
          'Information Security',
          'Business Intelligence and Data Analytics',
          'Fundamentals of GIS',
          'IT Infrastructure Management'
        ]
      },
    },
    'Computer Science': {
      'Sem-I': {
        'Major': ['Digital Systems & Architecture', 'Fundamentals of Database Systems'],
        'Major Practical': [
          'Module-I : Digital Systems & Architecture Practical',
          'Module-II : Fundamentals of Database Systems Practical'
        ],
        'OE': ['Elementary Statistical Techniques for Economics'],
        'VSC': ['Introduction to Programming with Python Practical'],
        'SEC': ['LINUX Operating System Practical'],
        'AEC': ['Introduction to Communication Skills in English I'],
        'VEC': ['Indian Constitution'],
        'IKS': ['Indian Knowledge Systems'],
        'CC': ['Introduction to Cultural Activities']
      },
      'Sem-II': {
        'Major': ['Design & Analysis of Algorithms', 'Introduction to Object Oriented Programming using C++'],
        'Major Practical': [
          'Module-I : Design & Analysis of Algorithms Practical',
          'Module-II : OOPs using C++ Practical'
        ],
        'Minor': ['Statistics Minor Practical-II'],
        'OE': ['Elementary Mathematics for Economics'],
        'VSC': ['Web Designing (Practical)'],
        'SEC': ['Database Management Systems using PL/SQL – 2'],
        'AEC': ['हिंदी भाषा : कौशल के आधार', 'भाषिक कौशल्यांचे उपयोजन - १'],
        'VEC': ['Environmental Management & Sustainable Development-II'],
        'CC': ['Foundation and Exploration of Performing and Fine Arts']
      },
      'Sem-III': {
        'Courses': [
          'Principles of Operating Systems',
          'Linear Algebra',
          'Data Structures',
          'Advanced Database Concepts',
          'Java based Application Development',
          'Web Technologies',
          'Green Technologies'
        ]
      },
      'Sem-IV': {
        'Courses': [
          'Theory of Computation',
          'Computer Networks',
          'Software Engineering',
          'IoT Technologies',
          'Android Application Development',
          'Advanced Application Development',
          'Research Methodology / Management & Entrepreneurship'
        ]
      },
      'Sem-V': {
        'Courses': [
          'Artificial Intelligence',
          'Information & Network Security',
          'Software Testing & Quality Assurance',
          'Cyber Forensics',
          'Project Management'
        ]
      },
      'Sem-VI': {
        'Courses': [
          'Data Science',
          'Cloud Computing & Web Services',
          'Information Retrieval',
          'Ethical Hacking',
          'Customer Relationship Management'
        ]
      },
    }
  };

  @override
  void initState() {
    super.initState();
    dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<String> getSemesters() =>
      department != null ? courseData[department!]!.keys.toList() : [];

  List<String> getCategories() =>
      (department != null && semester != null)
          ? courseData[department!]![semester!]!.keys.toList()
          : [];

  List<String> getCourses() =>
      (department != null && semester != null && category != null)
          ? courseData[department!]![semester!]![category!]!
          : [];

  void startSession() {
    if (_formKey.currentState!.validate()) {
      if (department != null && semester != null && category != null && course != null) {
        // Add a confirmation dialog for better UX
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.confirmation_number, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Confirm Session'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Department: $department'),
                  Text('Semester: $semester'),
                  Text('Category: $category'),
                  Text('Course: $course'),
                  Text('Timestamp: $dateTime'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/scanner', arguments: {
                      'department': department!,
                      'semester': semester!,
                      'category': category!,
                      'course': course!,
                      'timestamp': dateTime,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Session'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select all fields'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Setup Session',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
              });
            },
            tooltip: 'Refresh Timestamp',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Date/Time Display Card with refresh capability
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.access_time, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Session Date/Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Session Setup Card with improved header
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[50]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.settings, color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Select Session Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your department, semester, category, and course to begin the session.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Department Dropdown with improved styling
                        _buildDropdownField(
                          value: department,
                          label: 'Department *',
                          icon: Icons.school,
                          hint: 'Select Department',
                          items: courseData.keys
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              department = value;
                              semester = null;
                              category = null;
                              course = null;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a department' : null,
                        ),
                        // Conditional Semester Dropdown
                        if (department != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: semester,
                            label: 'Semester *',
                            icon: Icons.calendar_today,
                            hint: 'Select Semester',
                            items: getSemesters()
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                semester = value;
                                category = null;
                                course = null;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a semester' : null,
                          ),
                        ],
                        // Conditional Category Dropdown
                        if (semester != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: category,
                            label: 'Category *',
                            icon: Icons.category,
                            hint: 'Select Category',
                            items: getCategories()
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                category = value;
                                course = null;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a category' : null,
                          ),
                        ],
                        // Conditional Course Dropdown
                        if (category != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: course,
                            label: 'Course *',
                            icon: Icons.book,
                            hint: 'Select Course',
                            items: getCourses()
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) => setState(() {
                              course = value;
                            }),
                            validator: (value) => value == null ? 'Please select a course' : null,
                          ),
                        ],
                        const SizedBox(height: 28),
                        // Enhanced Proceed Button with icon and animation
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: startSession,
                            icon: const Icon(Icons.qr_code_scanner, size: 24),
                            label: const Text(
                              'Proceed to Scanner',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor: Colors.blue[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey[500])),
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}