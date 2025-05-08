import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Model/Model.dart';

class AlarmDetailPage extends StatefulWidget {
  final Model alarm;

  const AlarmDetailPage({Key? key, required this.alarm}) : super(key: key);

  @override
  State<AlarmDetailPage> createState() => _AlarmDetailPageState();
}

class _AlarmDetailPageState extends State<AlarmDetailPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayingSound = false;

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // 通知音を再生
  Future<void> _playNotificationSound() async {
    if (isPlayingSound) {
      await audioPlayer.stop();
      setState(() {
        isPlayingSound = false;
      });
      return;
    }

    try {
      await audioPlayer.stop();

      if (widget.alarm.hasCustomSound()) {
        // カスタム通知音の場合
        await audioPlayer.play(DeviceFileSource(widget.alarm.notificationSound!));
      } else {
        // デフォルト通知音の場合
        String assetPath;
        switch (widget.alarm.notificationSound) {
          case 'デフォルト2':
            assetPath = 'assets/sounds/default2.mp3';
            break;
          case 'デフォルト3':
            assetPath = 'assets/sounds/default3.mp3';
            break;
          case '優しい音':
            assetPath = 'assets/sounds/gentle.mp3';
            break;
          case '穏やかな音':
            assetPath = 'assets/sounds/calm.mp3';
            break;
          default:
            assetPath = 'assets/sounds/default1.mp3';
        }
        await audioPlayer.play(AssetSource(assetPath));
      }

      setState(() {
        isPlayingSound = true;
      });

      // 再生完了後に状態を更新
      audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            isPlayingSound = false;
          });
        }
      });
    } catch (e) {
      print('Error playing notification sound: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('通知音の再生中にエラーが発生しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return Scaffold(
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
            DetailCard(
              icon: Icons.access_time,
              label: '時間',
              value: widget.alarm.dateTime ?? '',
              scalingFactor: scalingFactor,
              iconColor: Colors.blue,
              isLarge: true,
            ),

            // タイトル
            DetailCard(
              icon: Icons.title,
              label: 'タイトル',
              value: widget.alarm.title ?? '',
              scalingFactor: scalingFactor,
              iconColor: Colors.orange,
            ),

            // 場所
            if (widget.alarm.location != null && widget.alarm.location!.isNotEmpty)
              DetailCard(
                icon: Icons.location_on,
                label: '場所',
                value: widget.alarm.location!,
                scalingFactor: scalingFactor,
                iconColor: Colors.red,
              ),

            // メモ
            if (widget.alarm.memo != null && widget.alarm.memo!.isNotEmpty)
              DetailCard(
                icon: Icons.note,
                label: 'メモ',
                value: widget.alarm.memo!,
                scalingFactor: scalingFactor,
                iconColor: Colors.green,
                isMultiLine: true,
              ),

            // 繰り返し
            DetailCard(
              icon: Icons.repeat,
              label: '繰り返し',
              value: widget.alarm.getRepeatDescription(),
              scalingFactor: scalingFactor,
              iconColor: Colors.purple,
            ),

            // 通知音
            DetailCard(
              icon: Icons.notifications_active,
              label: '通知音',
              value: widget.alarm.getNotificationSoundDisplayName(),
              scalingFactor: scalingFactor,
              iconColor: Colors.amber,
              trailing: widget.alarm.notificationSound != null && widget.alarm.notificationSound != 'なし'
                  ? IconButton(
                icon: Icon(
                  isPlayingSound ? Icons.stop : Icons.play_arrow,
                  color: Colors.blue,
                  size: 28 * scalingFactor,
                ),
                onPressed: _playNotificationSound,
              )
                  : null,
            ),

            // 通知画像
            DetailCard(
              icon: Icons.image,
              label: '通知画像',
              value: widget.alarm.getNotificationImageDisplayName(),
              scalingFactor: scalingFactor,
              iconColor: Colors.teal,
              hasImage: widget.alarm.hasCustomImage(),
              imagePath: widget.alarm.hasCustomImage() ? widget.alarm.notificationImage : null,
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
  final bool isLarge;
  final Widget? trailing;
  final bool hasImage;
  final String? imagePath;

  const DetailCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.scalingFactor,
    required this.iconColor,
    this.isMultiLine = false,
    this.isLarge = false,
    this.trailing,
    this.hasImage = false,
    this.imagePath,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: isLarge ? 36 * scalingFactor : 28 * scalingFactor,
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
                            fontSize: isLarge ? 40 * scalingFactor : 22 * scalingFactor,
                            fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
                          ),
                          maxLines: isMultiLine ? null : 2,
                          overflow: isMultiLine ? null : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (hasImage && imagePath != null) ...[
                SizedBox(height: 16 * scalingFactor),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8 * scalingFactor),
                  child: Image.file(
                    File(imagePath!),
                    height: 200 * scalingFactor,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}