import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherPage extends StatefulWidget {
  final String email; // Kullanıcının mail adresi

  const TeacherPage({super.key, required this.email});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  String name = 'Yükleniyor...';
  String role = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Veritabanından kullanıcı bilgilerini çekme
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        setState(() {
          name = userData['name'] ?? 'Kullanıcı';
          role = userData['role'] ?? 'Rol belirtilmedi';
        });
      } else {
        setState(() {
          name = 'Kullanıcı';
          role = 'Rol belirtilmedi';
        });
      }
    } catch (e) {
      setState(() {
        name = 'Hata';
        role = 'Hata';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Öğretmen Sayfası',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hoş geldiniz mesajı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hoş geldiniz! $role $name',
                style: const TextStyle(fontSize: 20, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // İşlev butonları
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProgramViewPage(email: widget.email),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today), // İkon
                        label: const Text('Program Gör'), // Metin
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentInfoPage(email: widget.email),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person), // İkon
                        label: const Text('Öğrenci Bilgisi'), // Metin
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // InfoPage'e email parametresini gönderme
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InfoPage(email: widget.email),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info), // İkon
                        label: const Text(
                          'Bilgilendirme',
                          style:
                              TextStyle(fontSize: 13), // Metin boyutunu küçült
                        ),
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WeeklyTopicPage(email: widget.email),
                            ),
                          );
                        },
                        icon: const Icon(Icons.book), // İkon
                        label: const Text('Haftalık Konu'), // Metin
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final String email; // Öğretmenin e-posta adresi

  const ProgramViewPage({Key? key, required this.email}) : super(key: key);

  @override
  _ProgramViewPageState createState() => _ProgramViewPageState();
}

class _ProgramViewPageState extends State<ProgramViewPage> {
  final TextEditingController schoolNumberController = TextEditingController();
  String? selectedClassroom; // Seçilen sınıf
  List<String> classrooms = []; // Dinamik sınıf listesi
  bool isLoadingClasses = false; // Sınıf verisi yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _fetchTeacherClass();
  }

  String? teacherClass; // Öğretmenin sınıfı

  // Öğretmenin sınıf bilgisini Firestore'dan al
  Future<void> _fetchTeacherClass() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final teacherData = snapshot.docs.first.data();
        setState(() {
          teacherClass = teacherData['class'] ?? ''; // Öğretmenin sınıfını al
        });

        // Öğretmenin sınıfına göre seçenekleri belirle
        _setClassroomOptions(teacherClass!);
      } else {
        setState(() {
          teacherClass = 'Sınıf bilgisi bulunamadı'; // Eğer öğretmen bulunmazsa
        });
      }
    } catch (e) {
      setState(() {
        teacherClass = 'Hata: $e';
      });
    }
  }

  // Öğretmenin sınıfına göre sınıf seçeneklerini belirle
  void _setClassroomOptions(String teacherClass) {
    List<String> availableClassrooms = [];
    switch (teacherClass) {
      case '9':
        availableClassrooms = ['9A', '9B'];
        break;
      case '10':
        availableClassrooms = ['10A', '10B'];
        break;
      case '11':
        availableClassrooms = ['11A', '11B'];
        break;
      default:
        availableClassrooms = ['Sınıf bilgisi bulunamadı'];
    }

    setState(() {
      classrooms = availableClassrooms;
    });
  }

  // Sınıfları Firestore'dan almak için
  Future<void> fetchClassrooms(String schoolNumber) async {
    setState(() {
      isLoadingClasses = true;
      //classrooms = [];
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('programs')
          .where('schoolNumber', isEqualTo: schoolNumber)
          .get();

      final fetchedClassrooms =
          snapshot.docs.map((doc) => doc['class'] as String).toSet().toList();

      setState(() {
        //classrooms = fetchedClassrooms;
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
      // Günün programını getir
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
              //child: Text('Ders programı bulunamadı.'),
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

class StudentInfoPage extends StatefulWidget {
  final String email; // Öğretmenin emaili

  const StudentInfoPage({super.key, required this.email});

  @override
  _StudentInfoPageState createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  String? teacherClass; // Öğretmenin sınıfı
  List<Map<String, dynamic>> students = []; // Öğrenci listesi
  bool isLoading = false; // Veriler yükleniyor mu?
  final TextEditingController _schoolNoController =
      TextEditingController(); // Okul numarası girişi için controller

  @override
  void initState() {
    super.initState();
    _fetchTeacherClassAndStudents(); // Öğretmenin sınıfını ve öğrencileri getir
  }

  // Öğretmenin sınıfını ve öğrencilerini Firestore'dan al
  Future<void> _fetchTeacherClassAndStudents() async {
    setState(() {
      isLoading = true;
      students = [];
    });

    try {
      // Öğretmenin e-posta adresine göre sınıf bilgisini al
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isEqualTo: widget
                  .email) // Öğretmenin e-posta adresini burada kullanıyoruz
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final teacherData = userSnapshot.docs.first.data();
        teacherClass = teacherData['class']; // Öğretmenin sınıfını al

        // Öğrencileri öğretmenin sınıfına göre getir
        await _fetchStudentsByClass(teacherClass!);
      } else {
        setState(() {
          students = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Öğrencileri öğretmenin sınıfına göre getir
  Future<void> _fetchStudentsByClass(String className) async {
    try {
      // Okul numarasını al
      String schoolNo = _schoolNoController.text;

      // Öğrencileri öğretmenin sınıfına, branş bilgisine (A veya B) ve okul numarasına göre filtreleyin
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('grade',
              isEqualTo:
                  className) // Öğrencinin grade'i öğretmenin class'ına eşit olmalı
          .where('branch', whereIn: ['A', 'B']) // Branch A veya B olmalı
          .where('schoolNumber',
              isEqualTo: schoolNo) // Okul numarası ile eşleşmeli
          .get();

      final fetchedStudents = studentSnapshot.docs.map((doc) {
        return doc.data(); // Öğrenci verilerini al
      }).toList();

      setState(() {
        students = fetchedStudents; // Öğrencileri listeye al
      });
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
        title: const Text('Öğrenci Bilgisi'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _schoolNoController,
                    decoration: const InputDecoration(
                      labelText: 'Okul Numarası',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Okul numarasına göre öğrencileri filtrele
                    _fetchStudentsByClass(teacherClass!);
                  },
                  child: const Text('Öğrencileri Göster'),
                ),
                Expanded(
                  child: students.isEmpty
                      ? const Center(child: Text('Öğrenci bulunamadı.'))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                    '${student['name']}'), // Sadece ismi göster
                                subtitle: Text(
                                    'Sınıf: ${student['grade']} - Branş: ${student['branch']}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class InfoPage extends StatefulWidget {
  final String email; // Kullanıcının email bilgisi

  const InfoPage({super.key, required this.email});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String? schoolNumber; // Kullanıcının okul numarası
  String? userClass; // Kullanıcının sınıf bilgisi
  String? userBranch; // Kullanıcının şube bilgisi
  String? selectedClass;
  String? selectedSube; // Kullanıcının seçtiği şube
  final TextEditingController _infoController = TextEditingController();
  bool isLoading = false; // Veri yükleniyor mu?
  bool isSaving = false; // Veri kaydediliyor mu?
  bool isClassValid = true; // Sınıf geçerli mi?
  String? selectedInfoId; // Seçilen bilgilendirme ID'si

  final List<String> classes = ['9', '10', '11'];
  final List<String> branches = ['A', 'B']; // Kullanıcıdan alınacak şubeler

  List<Map<String, dynamic>> infos = []; // Bilgilendirmeler

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Kullanıcı bilgilerini çek
    _fetchInfos(); // Bilgilendirmeleri çek
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          schoolNumber = userData['schoolNumber'];
          userClass = userData['class'];
          userBranch = userData['branch']; // Kullanıcıdan alınan branch
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchInfos() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('info')
          .where('schoolNumber', isEqualTo: schoolNumber)
          .get();

      setState(() {
        infos = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgilendirmeler alınamadı: $e')),
      );
    }
  }

  Future<void> _saveInfo() async {
    if (selectedClass == null ||
        selectedSube == null ||
        _infoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurunuz.')),
      );
      return;
    }

    if (!isClassValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seçilen sınıf geçerli değil.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('info').add({
        'schoolNumber': schoolNumber,
        'class': selectedClass,
        'sube': selectedSube, // Kullanıcının seçtiği şube
        'branch': userBranch, // Kullanıcıdan alınan branch
        'info': _infoController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgilendirme başarıyla eklendi.')),
      );

      setState(() {
        selectedClass = null;
        selectedSube = null;
        _infoController.clear();
        _fetchInfos(); // Listeyi güncelle
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bilgilendirme eklenemedi: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> _deleteInfo(String id) async {
    try {
      await FirebaseFirestore.instance.collection('info').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgilendirme silindi.')),
      );
      setState(() {
        infos.removeWhere((info) => info['id'] == id);
        selectedInfoId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme işlemi başarısız: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgilendirme'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Kullanıcı Bilgileri
                    Text('Okul Numarası: $schoolNumber',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Kullanıcı Sınıfı: $userClass - $userBranch',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    // Sınıf Seçimi
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Sınıf Seçiniz',
                        border: OutlineInputBorder(),
                      ),
                      items: classes.map((classItem) {
                        return DropdownMenuItem(
                          value: classItem,
                          child: Text(classItem),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                          isClassValid = (value == userClass);
                        });
                      },
                    ),
                    if (!isClassValid)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Seçilen sınıf sizin sınıfınızla eşleşmiyor!',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Şube Seçimi
                    DropdownButtonFormField<String>(
                      value: selectedSube,
                      decoration: const InputDecoration(
                        labelText: 'Şube Seçiniz',
                        border: OutlineInputBorder(),
                      ),
                      items: branches.map((branchItem) {
                        return DropdownMenuItem(
                          value: branchItem,
                          child: Text(branchItem),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSube = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Bilgi Girişi
                    TextField(
                      controller: _infoController,
                      decoration: const InputDecoration(
                        labelText: 'Bilgi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    // Kaydet Butonu
                    ElevatedButton(
                      onPressed: isSaving || !isClassValid ? null : _saveInfo,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Kaydet'),
                    ),
                    const SizedBox(height: 16),
                    // Önceki Bilgilendirmeler
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: infos.length,
                      itemBuilder: (context, index) {
                        final info = infos[index];
                        return ListTile(
                          title: Text(info['info']),
                          subtitle: Text(
                              'Sınıf: ${info['class']}, Şube: ${info['sube']}, Branch: ${info['branch']}'),
                          selected: selectedInfoId == info['id'],
                          onTap: () {
                            setState(() {
                              selectedInfoId = info['id'];
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Silme Butonu
                    ElevatedButton(
                      onPressed: selectedInfoId == null
                          ? null
                          : () async {
                              await _deleteInfo(selectedInfoId!);
                            },
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class WeeklyTopicPage extends StatefulWidget {
  final String email;

  const WeeklyTopicPage({super.key, required this.email});

  @override
  State<WeeklyTopicPage> createState() => _WeeklyTopicPageState();
}

class _WeeklyTopicPageState extends State<WeeklyTopicPage> {
  String? schoolNumber;
  String? userClass;
  String? userBranch;
  String? selectedWeek;
  String? selectedSube;
  bool isSaving = false;
  bool isUpdating = false;

  final List<String> weeks =
      List.generate(37, (index) => (index + 1).toString());
  final List<String> subeList = ['A', 'B']; // Örnek şubeler

  List<Map<String, dynamic>> weeklyTopics = [];
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Kullanıcı bilgilerini çek
    _fetchWeeklyTopics(); // Haftalık konuları çek
  }

  // Kullanıcının email bilgisine göre okul numarası, sınıf ve branch bilgisini al
  Future<void> _fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        setState(() {
          schoolNumber = userData['schoolNumber'];
          userClass = userData['class'];
          userBranch = userData['branch']; // Kullanıcının branşı
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  // Haftalık konuları veritabanından al
  Future<void> _fetchWeeklyTopics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('weektopic')
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        weeklyTopics = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'weekNo': data['weekNo'],
            'class': data['class'],
            'schoolNumber': data['schoolNumber'],
            'sube': data['sube'],
            'branch': data['branch'],
            'topic': data['topic'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler alınırken hata oluştu: $e')),
      );
    }
  }

  // Haftalık konuyu kaydet
  Future<void> _saveWeeklyTopic() async {
    if (selectedWeek == null ||
        selectedSube == null ||
        _topicController.text.isEmpty ||
        userClass == null ||
        schoolNumber == null ||
        userBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('weektopic').add({
        'weekNo': selectedWeek,
        'class': userClass,
        'schoolNumber': schoolNumber,
        'sube': selectedSube,
        'branch': userBranch, // Kullanıcının branşı
        'topic': _topicController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haftalık konu başarıyla kaydedildi.')));

      setState(() {
        selectedWeek = null;
        selectedSube = null;
        _topicController.clear();
      });
      _fetchWeeklyTopics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  // Haftalık konuyu güncelle
  Future<void> _updateWeeklyTopic(String id) async {
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen güncellemek için bir konu yazın.')),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance.collection('weektopic').doc(id).update({
        'topic': _topicController.text, // Yeni konu metni
        'sube': selectedSube, // Güncellenmiş şube
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Haftalık konu başarıyla güncellendi.')));

      setState(() {
        _topicController.clear();
      });

      _fetchWeeklyTopics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Konular'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: schoolNumber == null || userClass == null || userBranch == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Okul Numarası: $schoolNumber'),
                  const SizedBox(height: 8),
                  Text('Sınıf: $userClass'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedWeek,
                    decoration: const InputDecoration(
                      labelText: 'Hafta No',
                      border: OutlineInputBorder(),
                    ),
                    items: weeks.map((week) {
                      return DropdownMenuItem(
                        value: week,
                        child: Text('Hafta $week'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWeek = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSube,
                    decoration: const InputDecoration(
                      labelText: 'Şube Seçiniz',
                      border: OutlineInputBorder(),
                    ),
                    items: subeList.map((sube) {
                      return DropdownMenuItem(
                        value: sube,
                        child: Text(sube),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSube = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Haftalık Konu',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: (isSaving ||
                              selectedWeek == null ||
                              selectedSube == null ||
                              _topicController.text.isEmpty)
                          ? null
                          : _saveWeeklyTopic,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Haftalık Konular: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  ...weeklyTopics.map((weeklyTopic) {
                    return ListTile(
                      title: Text(
                          'Hafta ${weeklyTopic['weekNo']} - Şube ${weeklyTopic['sube']} Konu: ${weeklyTopic['topic']}'),
                      subtitle: Text(
                          'Sınıf: ${weeklyTopic['class']} - Branş: ${weeklyTopic['branch']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _topicController.text = weeklyTopic['topic'];
                          selectedSube = weeklyTopic['sube'];
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konuyu Güncelle'),
                              content: TextField(
                                controller: _topicController,
                                decoration: const InputDecoration(
                                  labelText: 'Yeni Konu',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _updateWeeklyTopic(weeklyTopic['id']);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Güncelle'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
