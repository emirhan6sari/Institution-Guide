import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPage extends StatefulWidget {
  final String email;

  const StudentPage({super.key, required this.email});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  String? studentName;

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();
    if (doc.docs.isNotEmpty) {
      setState(() {
        studentName = doc.docs.first['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Sayfası'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              studentName != null
                  ? 'Hoş geldiniz, Öğrenci $studentName!'
                  : 'Yükleniyor...',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureButton(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Program Gör',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramPage(
                              email: widget
                                  .email), // Email parametresi aktarılıyor
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildFeatureButton(
                      context,
                      icon: Icons.book,
                      label: 'Haftalık Konu Gör',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeeklyTopicPage(
                              email: widget
                                  .email), // email parametresi aktarılıyor
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFeatureButton(
                  context,
                  icon: Icons.info,
                  label: 'Bilgilendirme Gör',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoPage(
                          email: widget.email), // Email parametresi aktarılıyor
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class ProgramPage extends StatefulWidget {
  final String email;

  const ProgramPage({super.key, required this.email});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  String? selectedDay;
  String? schoolNumber;
  String? gradeBranch;
  List<dynamic>? lessons;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Kullanıcının bilgilerini al
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();

    if (doc.docs.isNotEmpty) {
      final userData = doc.docs.first.data();
      final grade = userData['grade']; // Sınıf
      final branch = userData['branch']; // Şube
      final no = userData['schoolNumber']; // Okul numarası

      setState(() {
        gradeBranch = '$grade$branch';
        schoolNumber = no;
      });
    }
  }

  Future<void> _fetchLessons() async {
    if (selectedDay == null || gradeBranch == null || schoolNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lütfen gün seçin ve bilgilerin yüklenmesini bekleyin.')),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('programs')
        .where('class', isEqualTo: gradeBranch)
        .where('day', isEqualTo: selectedDay)
        .where('schoolNumber', isEqualTo: schoolNumber)
        .get();

    if (doc.docs.isNotEmpty) {
      setState(() {
        lessons = doc.docs.first['lessons'] as List<dynamic>;
      });
    } else {
      setState(() {
        lessons = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Gör'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schoolNumber != null && gradeBranch != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Okul No: $schoolNumber\nSınıf: $gradeBranch',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedDay,
              isExpanded: true,
              hint: const Text('Bir gün seçin'),
              items: const [
                DropdownMenuItem(value: '1. Gün', child: Text('1. Gün')),
                DropdownMenuItem(value: '2. Gün', child: Text('2. Gün')),
                DropdownMenuItem(value: '3. Gün', child: Text('3. Gün')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                  lessons = null; // Yeni seçimde dersleri sıfırla
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _fetchLessons,
              child: const Text('Dersleri Getir'),
            ),
          ),
          if (lessons != null)
            Expanded(
              child: lessons!.isEmpty
                  ? const Center(child: Text('Ders bulunamadı'))
                  : ListView.builder(
                      itemCount: lessons!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(lessons![index]),
                        );
                      },
                    ),
            ),
        ],
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
  String? grade;
  String? branch;
  Map<String, List<Map<String, dynamic>>> groupedTopics = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Kullanıcının bilgilerini al
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();

    if (doc.docs.isNotEmpty) {
      final userData = doc.docs.first.data();
      setState(() {
        grade = userData['grade'];
        branch = userData['branch'];
        schoolNumber = userData['schoolNumber'];
      });
      _fetchWeeklyTopics();
    }
  }

  Future<void> _fetchWeeklyTopics() async {
    if (grade == null || branch == null || schoolNumber == null) {
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('weektopic')
        .where('class', isEqualTo: grade)
        .where('sube', isEqualTo: branch)
        .where('schoolNumber', isEqualTo: schoolNumber)
        .get();

    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var doc in query.docs) {
      final data = doc.data();
      final branchName = data['branch']; // branch özelliği
      final topic = data['topic']; // topic özelliği
      final weekNo = data['weekNo']; // weekno özelliği

      if (groupedData.containsKey(branchName)) {
        groupedData[branchName]!.add({'topic': topic, 'weekNo': weekNo});
      } else {
        groupedData[branchName] = [
          {'topic': topic, 'weekNo': weekNo}
        ];
      }
    }

    setState(() {
      groupedTopics = groupedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Konu Gör'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schoolNumber != null && grade != null && branch != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Okul No: $schoolNumber\nSınıf: $grade\nŞube: $branch',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const Divider(),
          Expanded(
            child: groupedTopics.isEmpty
                ? const Center(child: Text('Haftalık konu bulunamadı.'))
                : ListView(
                    children: groupedTopics.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Branch: ${entry.key}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...entry.value.map((item) {
                                  return Text(
                                    '- Week ${item['weekNo']}: ${item['topic']}',
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class InfoPage extends StatefulWidget {
  final String email;

  const InfoPage({super.key, required this.email});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String? schoolNumber;
  String? grade;
  String? branch;
  Map<String, List<dynamic>> groupedInfos = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Kullanıcının bilgilerini al
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();

    if (doc.docs.isNotEmpty) {
      final userData = doc.docs.first.data();
      setState(() {
        grade = userData['grade'];
        branch = userData['branch'];
        schoolNumber = userData['schoolNumber'];
      });
      _fetchInfos();
    }
  }

  Future<void> _fetchInfos() async {
    if (grade == null || branch == null || schoolNumber == null) {
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('info')
        .where('class', isEqualTo: grade)
        .where('sube', isEqualTo: branch)
        .where('schoolNumber', isEqualTo: schoolNumber)
        .get();

    Map<String, List<dynamic>> groupedData = {};

    for (var doc in query.docs) {
      final data = doc.data();
      final branchName = data['branch']; // branch özelliği
      final infoText = data['info']; // info özelliği

      if (groupedData.containsKey(branchName)) {
        groupedData[branchName]!.add(infoText);
      } else {
        groupedData[branchName] = [infoText];
      }
    }

    setState(() {
      groupedInfos = groupedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilgilendirme Gör'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schoolNumber != null && grade != null && branch != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Okul No: $schoolNumber\nSınıf: $grade\nŞube: $branch',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const Divider(),
          Expanded(
            child: groupedInfos.isEmpty
                ? const Center(child: Text('Bilgilendirme bulunamadı.'))
                : ListView(
                    children: groupedInfos.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Branch: ${entry.key}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...entry.value
                                    .map((info) => Text('- $info'))
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
