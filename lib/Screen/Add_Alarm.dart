import 'dart:math';
import 'package:alarm_project/Provider/Provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});

  @override
  State<AddAlarm> createState() => _AddAlaramState();
}

class _AddAlaramState extends State<AddAlarm> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  String? customSoundPath;
  String? customImagePath;
  bool isPlayingPreview = false;
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController memoController;
  String? dateTime;
  bool repeat = false;
  String? notificationSound = "デフォルト1";
  String? notificationImage = "なし";
  DateTime? notificationtime;
  String? name = "none";
  int? milliseconds;
  List<String> weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  List<String> selectedDays = [];

  @override
  void initState() {
    titleController = TextEditingController();
    locationController = TextEditingController();
    memoController = TextEditingController();
    context.read<alarmprovider>().GetData();
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    audioPlayer.dispose();
    titleController.dispose();
    locationController.dispose();
    memoController.dispose();
    super.dispose();
  }
  // マイク権限を確認する関数
  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  // 録音を開始する関数
  Future<void> _startRecording() async {
    try {
      if (!await _requestMicrophonePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('マイクの使用許可が必要です'), backgroundColor: Colors.red)
        );
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final savedDir = Directory('${appDir.path}/custom_sounds');
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }

      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '${savedDir.path}/$fileName';
      if (_recordingPath != null) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
            autoGain: true,
            echoCancel: true,
            noiseSuppress: true,
          ),
          path: _recordingPath!,
        );
      }
      else {
        // _recordingPathがnullの場合の処理
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('録音パスが設定されていません'), backgroundColor: Colors.red)
        );
      }

      setState(() {
        _isRecording = true;
      });

    } catch (e) {
      print('録音開始エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('録音の開始に失敗しました'), backgroundColor: Colors.red)
      );
    }
  }

  // 録音を停止する関数
  Future<void> _stopRecording(StateSetter setState) async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        this.setState(() {
          customSoundPath = path;
          notificationSound = "カスタム";
        });

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('録音が完了しました'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      print('録音停止エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('録音の停止に失敗しました'), backgroundColor: Colors.red)
      );
    }
  }


  // 共通のヘッダーウィジェット
  Widget _buildSectionHeader(String title, {IconData? icon}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;


    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16 * scalingFactor,
          vertical: 12 * scalingFactor
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.blue[700],
              size: 24 * scalingFactor,
            ),
            SizedBox(width: 8 * scalingFactor),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // 入力フィールドのカードウィジェット
  Widget _buildInputCard({
    required Widget child,
    double verticalPadding = 12.0,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(
        horizontal: 12 * scalingFactor,
        vertical: 4 * scalingFactor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scalingFactor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scalingFactor,
          vertical: verticalPadding * scalingFactor,
        ),
        child: child,
      ),
    );
  }

  // 設定項目用のリストタイル
  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = Colors.blue,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 28 * scalingFactor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18 * scalingFactor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 16 * scalingFactor,
        ),
      )
          : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        size: 24 * scalingFactor,
      ),
      onTap: onTap,
    );
  }
  // 日時選択ダイアログ
  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: notificationtime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ja', 'JP'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[700]!,
                onPrimary: Colors.white,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor: Colors.blue[700],
                hourMinuteColor: Colors.blue.shade50,
                hourMinuteTextColor: Colors.blue[700],
                dayPeriodColor: Colors.blue.shade50,
                dayPeriodTextColor: Colors.blue[700],
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          dateTime = DateFormat('MM月dd日 HH:mm').format(pickedDateTime);
          notificationtime = pickedDateTime;
          milliseconds = pickedDateTime.millisecondsSinceEpoch;
        });
      }
    }
  }

  // 繰り返し設定ダイアログ
  void _showRepeatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double scalingFactor = screenWidth / 1000;
            return AlertDialog(
              title: Text(
                '繰り返し設定',
                style: TextStyle(
                  fontSize: 22 * scalingFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 毎日/繰り返しなしの切り替え
                    SwitchListTile(
                      title: Text(
                        '繰り返し',
                        style: TextStyle(
                          fontSize: 18 * scalingFactor,
                        ),
                      ),
                      subtitle: Text(
                        repeat ? '有効' : '無効',
                        style: TextStyle(
                          fontSize: 16 * scalingFactor,
                        ),
                      ),
                      value: repeat,
                      onChanged: (bool value) {
                        setDialogState(() {
                          repeat = value;
                          if (value) {
                            name = 'Everyday';
                          } else {
                            name = 'none';
                            selectedDays.clear();
                          }
                        });
                      },
                    ),

                    if (repeat) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0 * scalingFactor),
                        child: Text(
                          '曜日を選択',
                          style: TextStyle(
                            fontSize: 18 * scalingFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8 * scalingFactor,
                        children: weekdays.map((day) {
                          final bool isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(
                              day,
                              style: TextStyle(
                                fontSize: 16 * scalingFactor,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }

                                if (selectedDays.isEmpty) {
                                  repeat = false;
                                  name = 'none';
                                } else if (selectedDays.length == 7) {
                                  name = 'Everyday';
                                } else {
                                  name = '毎週 ${selectedDays.join('・')}';
                                }
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.blue[700],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(
                    '確定',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('タイトルを入力してください'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (dateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('日時を設定してください'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Random random = Random();
                    int randomNumber = random.nextInt(100);

                    // 通知設定の保存先を決定
                    String finalNotificationSound = notificationSound!;
                    String finalNotificationImage = notificationImage!;

                    if (notificationSound == "カスタム" && customSoundPath != null) {
                      finalNotificationSound = customSoundPath!;
                    }

                    if (notificationImage == "カスタム" && customImagePath != null) {
                      finalNotificationImage = customImagePath!;
                    }

                    context.read<alarmprovider>().SetAlaram(
                      titleController.text, // label
                      dateTime!,            // dateTime
                      true,                 // check
                      name!,                // repeat
                      randomNumber,         // id
                      milliseconds!,        // milliseconds
                      titleController.text, // title
                      locationController.text, // location
                      memoController.text,  // memo
                      finalNotificationSound,   // notificationSound
                      finalNotificationImage,   // notificationImage
                      selectedDays,         // repeatDays
                    );
                    context.read<alarmprovider>().SetData();
                    context.read<alarmprovider>()
                        .SecduleNotification(notificationtime!, randomNumber);
                    Navigator.pop(context);
                    setState(() {
                      // ダイアログの状態をメインの状態に反映
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 通知音選択ダイアログ
  void _showSoundDialog() {
    final List<String> soundOptions = [
      'デフォルト1', 'デフォルト2', 'デフォルト3', '優しい音', '穏やかな音', 'カスタム'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double scalingFactor = screenWidth / 1000;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                '通知音の選択',
                style: TextStyle(
                  fontSize: 22 * scalingFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...soundOptions.map((sound) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Text(
                              sound,
                              style: TextStyle(
                                fontSize: 18 * scalingFactor,
                              ),
                            ),

                            if (sound == "カスタム" && customSoundPath != null) ...[
                              SizedBox(width: 8 * scalingFactor),
                              Text(
                                path.basename(customSoundPath!),
                                style: TextStyle(
                                  fontSize: 14 * scalingFactor,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            Spacer(),
                            if (sound != "カスタム")
                              IconButton(
                                icon: Icon(
                                  isPlayingPreview && notificationSound == sound
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                  color: Colors.blue[700],
                                ),
                                onPressed: () {
                                  _previewSound(sound, setState);
                                },
                              ),
                          ],
                        ),
                        value: sound,
                        groupValue: notificationSound,
                        onChanged: (String? value) {
                          print("選択値: $value"); // デバッグログ
                          setState(() {
                            // ダイアログ内の表示を更新
                          });

                          this.setState(() {
                            notificationSound = value;
                          });
                          if (value != "カスタム") {
                            Navigator.of(context).pop();
                          }
                        },
                        activeColor: Colors.blue[700],
                        selected: sound == notificationSound,
                      );
                    }).toList(),

                    if (notificationSound == "カスタム") ...[
                      SizedBox(height: 16 * scalingFactor),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _pickAudioFile();
                              setState(() {}); // ダイアログ状態を更新
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'ファイルから選択',
                              style: TextStyle(fontSize: 16 * scalingFactor),
                            ),
                          ),
                          SizedBox(width: 8 * scalingFactor),
                          // 録音ボタンを追加
                          ElevatedButton(
                            onPressed: _isRecording
                                ? () async {
                              await _stopRecording(setState);
                            }
                                : () async {
                              await _startRecording();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRecording ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isRecording ? Icons.stop : Icons.mic),
                                SizedBox(width: 4 * scalingFactor),
                                Text(
                                  _isRecording ? '録音停止' : '録音開始',
                                  style: TextStyle(fontSize: 16 * scalingFactor),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8 * scalingFactor),
                          if (customSoundPath != null)
                            IconButton(
                              icon: Icon(
                                isPlayingPreview ? Icons.stop : Icons.play_arrow,
                                color: Colors.blue[700],
                              ),
                              onPressed: () {
                                _previewCustomSound(setState);
                              },
                            ),
                        ],
                      ),
                      if (_isRecording) ...[
                        SizedBox(height: 12 * scalingFactor),
                        Row(
                          children: [
                            Icon(Icons.graphic_eq, color: Colors.red),
                            SizedBox(width: 8 * scalingFactor),
                            Text(
                              '録音中...',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * scalingFactor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(
                    '確定',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (notificationSound == "カスタム" && customSoundPath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('カスタム音声ファイルを選択してください'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 通知画像選択ダイアログの拡張
  void _showImageDialog() {
    final List<String> imageOptions = [
      'なし', 'デフォルト画像', '写真1', '写真2', 'カスタム'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double scalingFactor = screenWidth / 1000;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                '通知画像の選択',
                style: TextStyle(
                  fontSize: 22 * scalingFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...imageOptions.map((image) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Text(
                              image,
                              style: TextStyle(
                                fontSize: 18 * scalingFactor,
                              ),
                            ),
                            if (image == "カスタム" && customImagePath != null) ...[
                              SizedBox(width: 8 * scalingFactor),
                              Text(
                                path.basename(customImagePath!),
                                style: TextStyle(
                                  fontSize: 14 * scalingFactor,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        value: image,
                        groupValue: notificationImage,
                        onChanged: (String? value) {
                          this.setState(() {
                            notificationImage = value;
                          });
                          if (value != "カスタム") {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }).toList(),

                    if (notificationImage == "カスタム") ...[
                      SizedBox(height: 16 * scalingFactor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _pickImage(ImageSource.gallery);
                              setState(() {}); // ダイアログ状態を更新
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'ギャラリーから選択',
                              style: TextStyle(fontSize: 14 * scalingFactor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _pickImage(ImageSource.camera);
                              setState(() {}); // ダイアログ状態を更新
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'カメラで撮影',
                              style: TextStyle(fontSize: 14 * scalingFactor),
                            ),
                          ),
                        ],
                      ),

                      if (customImagePath != null) ...[
                        SizedBox(height: 16 * scalingFactor),
                        Container(
                          width: double.infinity,
                          height: 150 * scalingFactor,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8 * scalingFactor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8 * scalingFactor),
                            child: Image.file(
                              File(customImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 16 * scalingFactor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(
                    '確定',
                    style: TextStyle(fontSize: 16 * scalingFactor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (notificationImage == "カスタム" && customImagePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('カスタム画像を選択してください'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // オーディオファイルの選択と保存
  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // アプリのドキュメントディレクトリにファイルをコピー
        final appDir = await getApplicationDocumentsDirectory();
        final savedDir = Directory('${appDir.path}/custom_sounds');
        if (!await savedDir.exists()) {
          await savedDir.create(recursive: true);
        }

        final fileName = path.basename(file.path!);
        final savedPath = '${savedDir.path}/$fileName';

        // ファイルをコピー
        await File(file.path!).copy(savedPath);

        setState(() {
          customSoundPath = savedPath;
          notificationSound = "カスタム";
        });
      }
    } catch (e) {
      print('Error picking audio file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('オーディオファイルの選択中にエラーが発生しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 画像の選択と保存
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        // アプリのドキュメントディレクトリに画像を保存
        final appDir = await getApplicationDocumentsDirectory();
        final savedDir = Directory('${appDir.path}/custom_images');
        if (!await savedDir.exists()) {
          await savedDir.create(recursive: true);
        }

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${savedDir.path}/$fileName';

        // 画像をコピー
        await File(pickedImage.path).copy(savedPath);

        setState(() {
          customImagePath = savedPath;
          notificationImage = "カスタム";
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の選択中にエラーが発生しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 標準通知音のプレビュー再生
  void _previewSound(String sound, StateSetter setState) async {
    if (isPlayingPreview && notificationSound == sound) {
      await audioPlayer.stop();
      setState(() {
        isPlayingPreview = false;
      });
    } else {
      // 実際には標準通知音のパスを指定する必要がある
      // 例えば、これらはアセットとしてバンドルされていると仮定
      String soundPath;
      switch (sound) {
        case 'デフォルト1':
          soundPath = 'assets/sounds/default1.mp3';
          break;
        case 'デフォルト2':
          soundPath = 'assets/sounds/default2.mp3';
          break;
        default:
          soundPath = 'assets/sounds/default1.mp3';
      }

      try {
        await audioPlayer.stop();
        await audioPlayer.play(AssetSource(soundPath));
        setState(() {
          isPlayingPreview = true;
          notificationSound = sound;
        });

        // 再生完了後に状態を更新
        audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            isPlayingPreview = false;
          });
        });
      } catch (e) {
        print('Error playing preview: $e');
      }
    }
  }

  // カスタム通知音のプレビュー再生
  void _previewCustomSound(StateSetter setState) async {
    if (customSoundPath == null) return;

    if (isPlayingPreview) {
      await audioPlayer.stop();
      setState(() {
        isPlayingPreview = false;
      });
    } else {
      try {
        await audioPlayer.stop();
        await audioPlayer.play(DeviceFileSource(customSoundPath!));
        setState(() {
          isPlayingPreview = true;
        });

        // 再生完了後に状態を更新
        audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            isPlayingPreview = false;
          });
        });
      } catch (e) {
        print('Error playing custom preview: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget mainContent = ListView(
      children: [
        // タイトルセクション
        _buildSectionHeader('タイトル', icon: Icons.title),
        _buildInputCard(
          child: TextField(
            controller: titleController,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: 'スケジュールの内容を入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // 日時セクション
        _buildSectionHeader('開始日時', icon: Icons.calendar_today),
        _buildInputCard(
          child: InkWell(
            onTap: _selectDateTime,
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.blue[600],
                  size: 28 * scalingFactor,
                ),
                SizedBox(width: 16 * scalingFactor),
                Text(
                  dateTime ?? DateFormat('MM月dd日 HH:mm').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 22 * scalingFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.edit,
                  color: Colors.grey[600],
                  size: 24 * scalingFactor,
                ),
              ],
            ),
          ),
        ),

        // 場所セクション
        _buildSectionHeader('場所', icon: Icons.location_on),
        _buildInputCard(
          child: TextField(
            controller: locationController,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: '場所を入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // 通知設定セクション
        _buildSectionHeader('通知設定', icon: Icons.notifications_active),
        _buildInputCard(
          verticalPadding: 0,
          child: Column(
            children: [
              _buildSettingTile(
                title: '繰り返し',
                subtitle: repeat ? name : 'なし',
                icon: Icons.repeat,
                iconColor: Colors.purple,
                onTap: _showRepeatDialog,
              ),
              Divider(height: 1),
              _buildSettingTile(
                title: '通知音',
                subtitle: notificationSound,
                icon: Icons.music_note,
                iconColor: Colors.amber,
                onTap: _showSoundDialog,
              ),
              Divider(height: 1),
              _buildSettingTile(
                title: '通知画像',
                subtitle: notificationImage,
                icon: Icons.image,
                iconColor: Colors.teal,
                onTap: _showImageDialog,
              ),
            ],
          ),
        ),

        // メモセクション
        _buildSectionHeader('メモ', icon: Icons.note),
        _buildInputCard(
          verticalPadding: 16,
          child: TextField(
            controller: memoController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 18 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: 'メモを入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        SizedBox(height: 20 * scalingFactor),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          iconSize: 24 * scalingFactor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '新しいスケジュール',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scalingFactor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('タイトルを入力してください'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (dateTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('日時を設定してください'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Random random = Random();
              int randomNumber = random.nextInt(100);

              context.read<alarmprovider>().SetAlaram(
                titleController.text, // label
                dateTime!,            // dateTime
                true,                 // check
                name!,                // repeat
                randomNumber,         // id
                milliseconds!,        // milliseconds
                titleController.text, // title
                locationController.text, // location
                memoController.text,  // memo
                notificationSound!,   // notificationSound
                notificationImage!,   // notificationImage
                selectedDays,         // repeatDays
              );
              context.read<alarmprovider>().SetData();
              context.read<alarmprovider>()
                  .SecduleNotification(notificationtime!, randomNumber);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scalingFactor),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scalingFactor,
                vertical: 8 * scalingFactor,
              ),
            ),
            child: Text(
              '追加',
              style: TextStyle(
                fontSize: 18 * scalingFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8 * scalingFactor),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0 * scalingFactor),
          child: isLandscape
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(8.0 * scalingFactor),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16 * scalingFactor),
                  ),
                  padding: EdgeInsets.all(16.0 * scalingFactor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 64 * scalingFactor,
                        color: Colors.blue[700],
                      ),
                      SizedBox(height: 16 * scalingFactor),
                      Text(
                        'スケジュール\n作成',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24 * scalingFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 16 * scalingFactor),
                      Text(
                        '必要な情報を\n入力してください',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16 * scalingFactor,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: mainContent,
              ),
            ],
          )
              : mainContent,
        ),
      ),
    );
  }
}