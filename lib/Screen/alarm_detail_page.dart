import 'package:flutter/material.dart';
import '../Model/Model.dart';
class AlarmDetailPage extends StatelessWidget {
  final Model alarm;

  const AlarmDetailPage({Key? key, required this.alarm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'アラーム詳細',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailItem(label: '時間', value: alarm.dateTime ?? ''),
            DetailItem(label: 'タイトル', value: alarm.title ?? ''),
            DetailItem(label: '場所', value: alarm.location ?? ''),
            if (alarm.memo != null && alarm.memo!.isNotEmpty)
              DetailItem(label: 'メモ', value: alarm.memo!),
            DetailItem(label: '繰り返し', value: alarm.when ?? ''),
            if (alarm.repeatDays != null)
              DetailItem(
                label: '繰り返し曜日',
                value: alarm.repeatDays?.join(', ') ?? '',
              ),
            DetailItem(
              label: '通知音',
              value: alarm.notificationSound ?? 'デフォルト',
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const DetailItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}