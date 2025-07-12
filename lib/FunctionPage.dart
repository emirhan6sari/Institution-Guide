import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:math';

class FunctionPage extends StatelessWidget {
  final String title;

  const FunctionPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    Widget _buildContent() {
      switch (title) {
        case 'Öğrenci Ekleme':
          return AddStudentForm(); // Öğrenci ekleme formunu çağırıyoruz.
        case 'İşe Al':
          return const AddEmployeeForm(); // İşe al formu.
        case 'Öğrenci Bilgi':
          return const OgrBilgi(); //
        case 'İşten Çıkar':
          return const FireEmployeeForm(); // İşten çıkar formu.
        case 'Program Oluştur':
          return const ProgramCreatePage();
        case 'Program Gör':
          return const ProgramViewPage();
        case 'Bilgi İşlem':
          return const InfoProcessingPage();
        case 'Kurum Şeması':
          return const SchoolSchemaPage();
        default:
          return const Center(
            child: Text(
              'Bilinmeyen işlev.',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildContent(),
    );
  }
}

class OgrBilgi extends StatefulWidget {
  const OgrBilgi({super.key});

  @override
  _OgrBilgiState createState() => _OgrBilgiState();
}

class _OgrBilgiState extends State<OgrBilgi> {
  final TextEditingController _schoolNumberController = TextEditingController();
  List<Map<String, String>> students = []; // Öğrenci bilgileri
  bool isLoading = false;

  // Aynı okul numarasına sahip öğrencilerin bilgilerini al
  Future<void> _fetchStudentsBySchoolNumber(String schoolNumber) async {
    setState(() {
      isLoading = true;
      students.clear();
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolNumber', isEqualTo: schoolNumber)
          .where('role', isEqualTo: 'öğrenci') // Yalnızca öğrenciler
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'Bilinmiyor';
        final grade = data['grade'] ?? 'Bilinmiyor';
        final branch = data['branch'] ?? 'Bilinmiyor';

        students.add({'name': name, 'grade': grade, 'branch': branch});
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _schoolNumberController,
                decoration: const InputDecoration(
                  labelText: 'Okul Numarası',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final schoolNumber = _schoolNumberController.text.trim();
                  if (schoolNumber.isNotEmpty) {
                    _fetchStudentsBySchoolNumber(schoolNumber);
                  }
                },
                child: const Text('Ara'),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView(
                  shrinkWrap: true, // Scroll içinde boyutlandırmayı sağlar
                  physics:
                      const NeverScrollableScrollPhysics(), // Ana kaydırmaya izin verir
                  children: [
                    if (students.isNotEmpty) ...[
                      const Text(
                        'Öğrenciler:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      ...students.map((student) => Text(
                            '${student['name']} - ${student['grade']} - ${student['branch']}',
                          )),
                    ] else
                      const Text('Bu okul numarasına ait öğrenci bulunamadı.'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SchoolSchemaPage extends StatefulWidget {
  const SchoolSchemaPage({super.key});

  @override
  _SchoolSchemaPageState createState() => _SchoolSchemaPageState();
}

class _SchoolSchemaPageState extends State<SchoolSchemaPage> {
  final TextEditingController _schoolNumberController = TextEditingController();
  List<String> managers = []; // Müdürler
  List<String> assistantManagers = []; // Müdür yardımcıları
  List<Map<String, String>> teachers = []; // Öğretmenler ve branşları
  bool isLoading = false;

  // Aynı okul numarasına sahip personel bilgilerini al
  Future<void> _fetchStaffBySchoolNumber(String schoolNumber) async {
    setState(() {
      isLoading = true;
      managers.clear();
      assistantManagers.clear();
      teachers.clear();
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolNumber', isEqualTo: schoolNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final role = data['role'];
        final name = data['name'];
        final branch = data['branch']; // Branş bilgisi (varsa)

        if (role == 'müdür') {
          managers.add(name);
        } else if (role == 'müdür yardımcısı') {
          assistantManagers.add(name);
        } else if (role == 'öğretmen') {
          teachers.add({'name': name, 'branch': branch ?? 'Bilinmiyor'});
        }
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _schoolNumberController,
              decoration: const InputDecoration(
                labelText: 'Okul Numarası',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final schoolNumber = _schoolNumberController.text.trim();
                if (schoolNumber.isNotEmpty) {
                  _fetchStaffBySchoolNumber(schoolNumber);
                }
              },
              child: const Text('Ara'),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: [
                    if (managers.isNotEmpty) ...[
                      const Text(
                        'Müdür:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(managers.join(', ')),
                      const SizedBox(height: 16),
                    ],
                    if (assistantManagers.isNotEmpty) ...[
                      const Text(
                        'Müdür Yardımcıları:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(assistantManagers.join(', ')),
                      const SizedBox(height: 16),
                    ],
                    if (teachers.isNotEmpty) ...[
                      const Text(
                        'Öğretmenler:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      ...teachers.map((teacher) => Text(
                            '${teacher['name']} - ${teacher['branch']}',
                          )),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InfoProcessingPage extends StatefulWidget {
  const InfoProcessingPage({super.key});

  @override
  State<InfoProcessingPage> createState() => _InfoProcessingPageState();
}

class _InfoProcessingPageState extends State<InfoProcessingPage> {
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? userData; // Kullanıcı bilgilerini saklamak için.

  Future<void> _fetchUserData() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir e-posta girin.')),
      );
      return;
    }

    try {
      // Firestore'daki 'users' koleksiyonunda e-posta ile sorgulama yap
      var snapshot = await FirebaseFirestore.instance
          .collection('users') // Kullanıcıların kaydedildiği koleksiyon adı.
          .where('email', isEqualTo: email) // E-posta eşleşmesi kontrolü.
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userData = snapshot.docs.first.data(); // İlk eşleşmeyi al.
        });
      } else {
        setState(() {
          userData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bu e-posta ile eşleşen kullanıcı bulunamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Sayfayı kaydırılabilir hale getirin
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta Girin'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Kullanıcı Bilgilerini Getir'),
            ),
            const SizedBox(height: 16),
            if (userData != null) ...[
              const Text(
                'Kullanıcı Bilgileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: userData!.entries.map((entry) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.value.toString()),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProgramViewPage extends StatefulWidget {
  const ProgramViewPage({Key? key}) : super(key: key);

  @override
  _ProgramViewPageState createState() => _ProgramViewPageState();
}

class _ProgramViewPageState extends State<ProgramViewPage> {
  final TextEditingController schoolNumberController = TextEditingController();
  String? selectedClassroom; // Seçilen sınıf
  List<String> classrooms = []; // Dinamik sınıf listesi
  bool isLoadingClasses = false; // Sınıf verisi yükleniyor mu?

  Future<void> fetchClassrooms(String schoolNumber) async {
    setState(() {
      isLoadingClasses = true;
      classrooms = [];
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('programs')
          .where('schoolNumber', isEqualTo: schoolNumber)
          .get();

      final fetchedClassrooms =
          snapshot.docs.map((doc) => doc['class'] as String).toSet().toList();

      setState(() {
        classrooms = fetchedClassrooms;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        isLoadingClasses = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchProgram(
      String schoolNumber, String classroom, String day) async {
    try {
      // Günün bilgisiyle birlikte docId oluşturuluyor
      String docId = "$schoolNumber-$classroom-$day";
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("programs")
          .doc(docId)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: schoolNumberController,
              decoration: const InputDecoration(labelText: 'Okul Numarası'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final schoolNumber = schoolNumberController.text.trim();
                if (schoolNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Lütfen okul numarasını girin!')),
                  );
                  return;
                }
                fetchClassrooms(schoolNumber);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text('Sınıfları Getir'),
            ),
            const SizedBox(height: 20),
            if (isLoadingClasses)
              const Center(child: CircularProgressIndicator())
            else if (classrooms.isNotEmpty)
              DropdownButton<String>(
                value: selectedClassroom,
                hint: const Text('Bir sınıf seçin'),
                items: classrooms
                    .map((classroom) => DropdownMenuItem(
                        value: classroom, child: Text(classroom)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClassroom = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            if (selectedClassroom != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProgramDay('1. Gün'),
                      _buildProgramDay('2. Gün'),
                      _buildProgramDay('3. Gün'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramDay(String day) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchProgram(
        schoolNumberController.text.trim(),
        selectedClassroom!,
        day,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Veri alınırken bir hata oluştu.'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text('Ders programı bulunamadı.'),
          );
        }

        final programData = snapshot.data!;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Ders programını listele
                ...programData['lessons'].map((lesson) => Text(
                      '- $lesson',
                      style: const TextStyle(fontSize: 16),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProgramCreatePage extends StatefulWidget {
  const ProgramCreatePage({Key? key}) : super(key: key);

  @override
  _ProgramCreatePageState createState() => _ProgramCreatePageState();
}

class _ProgramCreatePageState extends State<ProgramCreatePage> {
  bool _isLoading = false;
  TextEditingController _schoolNumberController = TextEditingController();

  Future<void> _createProgram() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<String> classes = ['9A', '9B', '10A', '10B', '11A', '11B'];
      List<String> allLessons = [
        'Matematik',
        'Matematik',
        'Matematik',
        'Matematik',
        'Fizik',
        'Fizik',
        'Kimya',
        'Kimya',
        'Biyoloji',
        'Biyoloji',
        'Türkçe',
        'Türkçe',
        'Tarih',
        'Tarih',
        'Coğrafya',
        'Coğrafya',
      ];
      List<String> days = ['1. Gün', '2. Gün', '3. Gün'];

      String schoolNumber = _schoolNumberController.text.trim();
      if (schoolNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Okul numarası girin!')),
        );
        return;
      }

      for (var classroom in classes) {
        allLessons.shuffle();

        for (int i = 0; i < days.length; i++) {
          int startIndex = i * 6;
          int endIndex = startIndex + (i == 0 ? 4 : 6);

          List<String> lessonsForDay = allLessons.sublist(
              startIndex, endIndex.clamp(0, allLessons.length));

          // Manuel olarak docId oluşturma
          String docId = "$schoolNumber-$classroom-${days[i]}";

          await FirebaseFirestore.instance
              .collection("programs")
              .doc(docId)
              .set({
            'schoolNumber': schoolNumber,
            'class': classroom,
            'day': days[i],
            'lessons': lessonsForDay,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program başarıyla oluşturuldu!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _schoolNumberController,
            decoration: const InputDecoration(labelText: 'Okul Numarası'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _createProgram,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  child: const Text('Programı Oluştur'),
                ),
        ],
      ),
    );
  }
}

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key});

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolNumberController =
      TextEditingController(); // Okul numarası için controller

  String _selectedRole = 'öğrenci';
  String _selectedGrade = ''; // Sınıf bilgisi
  String _selectedBranch = ''; // Şube bilgisi
  bool _isLoading = false;

  // Şube seçenekleri
  final List<String> branchOptions = [
    'A',
    'B',
  ];

  Future<void> _addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Authentication ile yeni kullanıcı oluşturma
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Firestore'a yeni öğrenci ekleme
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'role': _selectedRole,
          'grade': _selectedGrade,
          'branch': _selectedBranch,
          'schoolNumber': _schoolNumberController.text.trim(), // Okul numarası
          'uid': userCredential.user!.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Öğrenci başarıyla eklendi!')),
        );

        // Formu sıfırla
        _emailController.clear();
        _nameController.clear();
        _passwordController.clear();
        _schoolNumberController.clear();
        setState(() {
          _selectedRole = 'öğrenci';
          _selectedGrade = '';
          _selectedBranch = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Scrollable form
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) =>
                    value!.isEmpty ? 'E-posta boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İsim'),
                validator: (value) =>
                    value!.isEmpty ? 'İsim boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Şifre boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolNumberController,
                decoration: const InputDecoration(labelText: 'Okul Numarası'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Okul numarası boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              const Text('Sınıf Seçin', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGrade.isNotEmpty ? _selectedGrade : null,
                decoration: const InputDecoration(labelText: 'Sınıf'),
                items: [
                  '9',
                  '10',
                  '11',
                ]
                    .map(
                      (grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGrade = value ?? '';
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Sınıf seçimi zorunlu'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text('Şube Seçin', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBranch.isNotEmpty ? _selectedBranch : null,
                decoration: const InputDecoration(labelText: 'Şube'),
                items: branchOptions
                    .map(
                      (branch) => DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value ?? '';
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Şube seçimi zorunlu'
                    : null,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addStudent,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      child: const Text('Öğrenci Ekle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddEmployeeForm extends StatefulWidget {
  const AddEmployeeForm({super.key});

  @override
  _AddEmployeeFormState createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolNumberController =
      TextEditingController(); // Okul numarası için kontrolcü

  String _selectedRole = 'öğretmen';
  String _selectedBranch = '';
  String _selectedLesson = '';
  String _selectedClass = ''; // Sınıf seçimi için yeni değişken
  bool _isLoading = false;

  // Branş ve ders eşleştirmeleri
  final Map<String, List<String>> branchToLessons = {
    'biyoloji': ['Genetik', 'Ekoloji'],
    'fizik': ['Klasik Mekanik', 'Elektrik ve Manyetizma'],
    'kimya': ['Organik Kimya', 'Analitik Kimya'],
    'matematik': ['Cebir', 'Geometri'],
    'tarih': ['Osmanlı Tarihi', 'Dünya Tarihi'],
    'coğrafya': ['Fiziki Coğrafya', 'Beşeri Coğrafya'],
    'türkçe': ['Dil Bilgisi', 'Edebiyat']
  };

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Authentication ile yeni kullanıcı oluşturma
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Firestore'a yeni çalışan ekleme
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'role': _selectedRole,
          'branch': _selectedBranch,
          'lesson': _selectedLesson,
          'class': _selectedClass, // Sınıf bilgisini ekledik
          'schoolNumber': _schoolNumberController.text.trim(),
          'uid': userCredential.user!.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çalışan başarıyla eklendi!')),
        );

        // Formu sıfırla
        _emailController.clear();
        _nameController.clear();
        _passwordController.clear();
        _schoolNumberController.clear();
        setState(() {
          _selectedRole = 'öğretmen';
          _selectedBranch = '';
          _selectedLesson = '';
          _selectedClass = ''; // Sınıf seçimini sıfırladık
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Bu satırı ekliyoruz
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) =>
                    value!.isEmpty ? 'E-posta boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İsim'),
                validator: (value) =>
                    value!.isEmpty ? 'İsim boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Şifre boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolNumberController,
                decoration: const InputDecoration(labelText: 'Okul Numarası'),
                validator: (value) =>
                    value!.isEmpty ? 'Okul numarası boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              const Text('Rol Seçin', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'öğretmen';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == 'öğretmen'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('öğretmen'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'müdür yardımcısı';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == 'müdür yardımcısı'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('Müdür Yardımcısı'),
                  ),
                ],
              ),
              if (_selectedRole == 'öğretmen') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBranch.isNotEmpty ? _selectedBranch : null,
                  decoration: const InputDecoration(labelText: 'Branş Seçin'),
                  items: branchToLessons.keys
                      .map(
                        (branch) => DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranch = value ?? '';
                      _selectedLesson = ''; // Branş değişince ders sıfırlanır
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Branş seçimi zorunlu'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_selectedBranch.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedLesson.isNotEmpty ? _selectedLesson : null,
                    decoration: const InputDecoration(labelText: 'Ders Seçin'),
                    items: branchToLessons[_selectedBranch]!
                        .map(
                          (lesson) => DropdownMenuItem(
                            value: lesson,
                            child: Text(lesson),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLesson = value ?? '';
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ders seçimi zorunlu'
                        : null,
                  ),
                const SizedBox(height: 16),
                // Sınıf Seçimi
                DropdownButtonFormField<String>(
                  value: _selectedClass.isNotEmpty ? _selectedClass : null,
                  decoration: const InputDecoration(labelText: 'Sınıf Seçin'),
                  items: ['9', '10', '11']
                      .map(
                        (classItem) => DropdownMenuItem(
                          value: classItem,
                          child: Text(classItem),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value ?? '';
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Sınıf seçimi zorunlu'
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addEmployee,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      child: const Text('Çalışan Ekle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class FireEmployeeForm extends StatefulWidget {
  const FireEmployeeForm({super.key});

  @override
  _FireEmployeeFormState createState() => _FireEmployeeFormState();
}

class _FireEmployeeFormState extends State<FireEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(); // E-posta controller'ı
  final TextEditingController _okulnoController =
      TextEditingController(); // Okul numarası controller'ı
  final TextEditingController _exitDateController = TextEditingController();
  bool _isLoading = false;
  String _role = ''; // Rolü tutacak bir değişken

  Future<void> _fireEmployee() async {
    if (_formKey.currentState!.validate() && _role.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 'users' koleksiyonunda sadece e-posta ve rol ile sorgulama yapıyoruz
        var snapshot = await FirebaseFirestore.instance
            .collection('users') // Koleksiyon adı 'users'
            .where('email',
                isEqualTo:
                    _emailController.text.trim()) // E-posta ile sorgulama
            .where('role', isEqualTo: _role) // Rol ile eşleşme kontrolü
            .get();

        if (snapshot.docs.isNotEmpty) {
          var userDoc = snapshot.docs.first;
          String userUid = userDoc['uid']; // Firestore'dan uid'yi alıyoruz

          // Firestore'dan kullanıcıyı sil
          await userDoc.reference.delete();

          // Firebase Auth'tan kullanıcıyı sil
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null && user.uid == userUid) {
            await user.delete(); // Firebase Auth'tan kullanıcıyı sil
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Çalışan başarıyla işten çıkarıldı!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Çalışan bulunamadı!')),
          );
        }

        // Formu sıfırla
        _emailController.clear();
        _okulnoController.clear();
        _exitDateController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir rol seçin!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Sayfa kaydırılabilir hale getirildi
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController, // E-posta alanı
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (value) =>
                    value!.isEmpty ? 'E-posta boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _okulnoController, // Okul numarası alanı
                decoration: const InputDecoration(labelText: 'Okul Numarası'),
                validator: (value) =>
                    value!.isEmpty ? 'Okul numarası boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _role = 'öğretmen'; // Öğretmen rolünü seç
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _role == 'öğretmen' ? Colors.blue : Colors.grey,
                    ),
                    child: const Text('Öğretmen'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _role =
                            'müdür yardımcısı'; // Müdür yardımcısı rolünü seç
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _role == 'müdür yardımcısı'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('Müdür Yardımcısı'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exitDateController,
                decoration:
                    const InputDecoration(labelText: 'İşten Çıkma Tarihi'),
                validator: (value) => value!.isEmpty
                    ? 'İşten çıkma tarihi boş bırakılamaz'
                    : null,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _fireEmployee,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      child: const Text('Çalışanı İşten Çıkar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
