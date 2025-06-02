import 'package:flutter/material.dart';
import 'package:ornaguide/results.dart';

class buildHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool isArabic;
  final BuildContext context; // Pass context from parent

  const buildHistoryItem({
    required this.data,
    required this.docId,
    required this.isArabic,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              plantInfo: data.cast<String, String>(),
              isArabic: isArabic,
              docId: docId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.green),
    SizedBox(width: 10),
    Expanded( // ← Critical for containing text
      child: Text(
        isArabic ? data['name_ar'] ?? 'نبات' : data['common_name'] ?? 'Plant',
        style: TextStyle(fontSize: 16),
        overflow: TextOverflow.ellipsis, // ← Handles overflow
        maxLines: 1, // ← Single line with ellipsis
      ),
    ),
          ],
        ),
      ),
    );
  }
}