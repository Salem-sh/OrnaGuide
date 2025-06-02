// results.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, String> plantInfo;
  final bool isArabic;
  final String docId;

  const ResultsPage({
    super.key,
    required this.plantInfo,
    required this.isArabic,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantInfo['common_name'] ?? 'Plant Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Plant Family', plantInfo['plant_family']),
            _buildInfoItem('Description', plantInfo['description']),
            _buildInfoItem('Ornamental Type', plantInfo['ornamental_type']),
            _buildInfoItem('Diseases/Pests', plantInfo['diseases']),
            SizedBox(height: 20),
            Text('Care Schedule:',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            MarkdownBody(
              data: plantInfo['care_schedule'] ?? '',
              styleSheet: MarkdownStyleSheet(
              tableBorder: TableBorder.all(color: Colors.grey),
              tableHead: TextStyle(fontWeight: FontWeight.bold),
              tableBody: TextStyle(color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),
            Text('Weekly Watering Schedule:',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            MarkdownBody(
              data: plantInfo['weekly_watering'] ?? '',
              styleSheet: MarkdownStyleSheet(
                tableBorder: TableBorder.all(color: Colors.blue),
                tableHead: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]
                ),
                tableBody: TextStyle(color: Colors.grey[700]),
              ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حذف النبتة' : 'Delete Plant'),
        content: Text(isArabic ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              _deletePlant(context); // Then delete and navigate
            },
            child: Text(isArabic ? 'حذف' : 'Delete', 
              style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePlant(BuildContext context) async {
    try {
      // First navigate back to home page
      Navigator.pop(context);
      
      // Then delete the plant document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('history')
          .doc(docId)
          .delete();
      
      // Show success message on the home page context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم حذف النبتة بنجاح' : 'Plant deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If we're still in a valid context, show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'فشل حذف النبتة' : 'Failed to delete plant'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoItem(String title, String? content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
          SizedBox(height: 4),
          Text(content ?? 'No information available'),
          Divider(height: 20),
        ],
      ),
    );
  }
}