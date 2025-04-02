import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/Model.dart';
class AlarmDetailPage extends StatelessWidget {
  final Model alarm;

  const AlarmDetailPage({Key? key, required this.alarm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画面サイズに基づくスケーリング
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    // アラーム時間をDateTimeに変換
    DateTime? alarmDateTime;
    if (alarm.milliseconds != null) {
      alarmDateTime = DateTime.fromMillisecondsSinceEpoch(alarm.milliseconds!);
    }

    // 時間表示のフォーマット
    String formattedTime = '';
    String formattedDate = '';
    if (alarmDateTime != null) {
      formattedTime = DateFormat('HH:mm').format(alarmDateTime);
      formattedDate = DateFormat('yyyy年MM月dd日(E)', 'ja_JP').format(alarmDateTime);
    } else if (alarm.dateTime != null) {
      formattedTime = alarm.dateTime!;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'スケジュール詳細',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24 * scalingFactor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // 編集画面に遷移する処理（必要に応じて実装）
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0 * scalingFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 時間表示部分（大きく表示）
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scalingFactor),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0 * scalingFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 32 * scalingFactor,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 12 * scalingFactor),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '時間',
                              style: TextStyle(
                                fontSize: 18 * scalingFactor,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4 * scalingFactor),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 40 * scalingFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      SizedBox(height: 8 * scalingFactor),
                      Padding(
                        padding: EdgeInsets.only(left: 44 * scalingFactor),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 18 * scalingFactor,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16 * scalingFactor),

            // タイトル
            DetailCard(
              icon: Icons.title,
              label: 'タイトル',
              value: alarm.title ?? '',
              scalingFactor: scalingFactor,
              iconColor: Colors.orange,
            ),

            // 場所
            if (alarm.location != null && alarm.location!.isNotEmpty)
              DetailCard(
                icon: Icons.location_on,
                label: '場所',
                value: alarm.location!,
                scalingFactor: scalingFactor,
                iconColor: Colors.red,
              ),

            // メモ
            if (alarm.memo != null && alarm.memo!.isNotEmpty)
              DetailCard(
                icon: Icons.note,
                label: 'メモ',
                value: alarm.memo!,
                scalingFactor: scalingFactor,
                iconColor: Colors.green,
                isMultiLine: true,
              ),

            // 繰り返し
            DetailCard(
              icon: Icons.repeat,
              label: '繰り返し',
              value: alarm.getRepeatDescription(),
              scalingFactor: scalingFactor,
              iconColor: Colors.purple,
            ),

            // 通知音
            DetailCard(
              icon: Icons.notifications_active,
              label: '通知音',
              value: alarm.notificationSound ?? 'デフォルト',
              scalingFactor: scalingFactor,
              iconColor: Colors.amber,
            ),

            // 通知画像
            DetailCard(
              icon: Icons.image,
              label: '通知画像',
              value: alarm.notificationImage ?? 'なし',
              scalingFactor: scalingFactor,
              iconColor: Colors.teal,
            ),

            SizedBox(height: 24 * scalingFactor),

            // 閉じるボタン
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 40 * scalingFactor,
                    vertical: 12 * scalingFactor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30 * scalingFactor),
                  ),
                ),
                child: Text(
                  '閉じる',
                  style: TextStyle(fontSize: 18 * scalingFactor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double scalingFactor;
  final Color iconColor;
  final bool isMultiLine;

  const DetailCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.scalingFactor,
    required this.iconColor,
    this.isMultiLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0 * scalingFactor),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scalingFactor),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0 * scalingFactor),
          child: Row(
            crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28 * scalingFactor,
                color: iconColor,
              ),
              SizedBox(width: 16 * scalingFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16 * scalingFactor,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4 * scalingFactor),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22 * scalingFactor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: isMultiLine ? null : 2,
                      overflow: isMultiLine ? null : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}