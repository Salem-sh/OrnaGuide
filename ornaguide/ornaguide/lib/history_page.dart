import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ornaguide/firestore_services.dart';

class HistoryPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('السجل')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('حدث خطأ: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(data['imageUrl'], width: 50, height: 50),
                title: Text(data['name_ar'] ?? data['name_en']),
                subtitle: Text(data['description_ar'] ?? data['description_en']),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryDetailPage(data: data),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['name_ar'] ?? data['name_en'])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(data['imageUrl'], height: 200, fit: BoxFit.cover),
            SizedBox(height: 20),
            _buildDetailRow('الاسم', data['name_ar'], data['name_en']),
            _buildDetailRow('الوصف', data['description_ar'], data['description_en']),
            _buildDetailRow('النوع', data['type_ar'], data['type_en']),
            _buildDetailRow('معلومة', data['fact_ar'], data['fact_en']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? arText, String? enText) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(arText ?? enText ?? 'لا يوجد بيانات', style: TextStyle(fontSize: 16)),
          Divider(),
        ],
      ),
    );
  }
}