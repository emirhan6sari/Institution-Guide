import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssistantManagerPage extends StatelessWidget {
  final String name;

  const AssistantManagerPage({super.key, required this.name});

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müdür Yardımcısı Sayfası'),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Hoş geldiniz, $name!',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Öğrenci Ekleme'),
              onTap: () => _navigateToPage(context, const AddStudentForm()),
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text('Program Oluştur'),
              onTap: () => _navigateToPage(context, const ProgramCreatePage()),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Öğrenci Bilgi'),
              onTap: () => _navigateToPage(context, const OgrBilgi()),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'Hoş geldiniz, Müdür Yardımcısı $name!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 80.0), // 40 birim yukarı kaydırma
            child: Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.7, // %90 genişlik
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.account_tree,
                              size: 30, color: Colors.blueGrey),
                          title: const Text('Kurum Şeması'),
                          onTap: () => _navigateToPage(
                              context, const SchoolSchemaPage()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Daha geniş boşluk
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.visibility,
                              size: 30, color: Colors.blueGrey),
                          title: const Text('Program Gör'),
                          onTap: () =>
                              _navigateToPage(context, const ProgramViewPage()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.computer,
                              size: 30, color: Colors.blueGrey),
                          title: const Text('Bilgi İşlem'),
                          onTap: () => _navigateToPage(
                              context, const InfoProcessingPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: const Text('Öğrenci Bilgi'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Geri gitme işlemi
          },
        ),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgi İşlem'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Geri gitme işlemi
          },
        ),
      ),
      body: SingleChildScrollView(
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
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
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
      appBar: AppBar(
        title: const Text('Okul Şeması'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Geri gitme işlemi
          },
        ),
      ),
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
      appBar: AppBar(
        title: const Text('Program Görüntüleme'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Geri gitme işlemi
          },
        ),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Oluştur'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
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
      ),
    );
  }
}
