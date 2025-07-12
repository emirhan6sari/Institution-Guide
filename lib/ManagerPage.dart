import 'package:flutter/material.dart';
import 'FunctionPage.dart';

class ManagerPage extends StatelessWidget {
  final String name;

  const ManagerPage({super.key, required this.name});

  void _navigateToPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FunctionPage(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müdür Sayfası'),
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
                'Hoş geldiniz, Müdür $name!',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('İşe Al'),
              onTap: () => _navigateToPage(context, 'İşe Al'),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: const Text('İşten Çıkar'),
              onTap: () => _navigateToPage(context, 'İşten Çıkar'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Program Oluştur'),
              onTap: () => _navigateToPage(context, 'Program Oluştur'),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Öğrenci Ekleme'),
              onTap: () => _navigateToPage(context, 'Öğrenci Ekleme'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profil fotoğrafı ekleyelim

            const SizedBox(height: 16),
            Text(
              'Hoş geldiniz, Müdür $name!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Kartlar ekleyelim

            const SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.account_tree, color: Colors.blueGrey),
                title:
                    const Text('Kurum Şeması', style: TextStyle(fontSize: 18)),
                onTap: () => _navigateToPage(context, 'Kurum Şeması'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.schedule, color: Colors.blueGrey),
                title:
                    const Text('Program Gör', style: TextStyle(fontSize: 18)),
                onTap: () => _navigateToPage(context, 'Program Gör'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blueGrey),
                title:
                    const Text('Bilgi İşlem', style: TextStyle(fontSize: 18)),
                onTap: () => _navigateToPage(context, 'Bilgi İşlem'),
              ),
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blueGrey),
                title:
                    const Text('Öğrenci Bilgi', style: TextStyle(fontSize: 18)),
                onTap: () => _navigateToPage(context, 'Öğrenci Bilgi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
