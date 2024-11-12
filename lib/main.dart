import 'dart:async';
import 'package:alarm_project/Model/Model.dart';
import 'package:alarm_project/Provider/Provider.dart';
import 'package:alarm_project/Screen/Add_Alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io' show Platform;
import 'package:another_flushbar/flushbar.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // プラットフォームに応じた通知許可のリクエスト
  if (Platform.isAndroid){
  //   AndroidではrequestPermissionは不要なので削除
  //   Android向けの初期化などを行う
  } else if (Platform.isIOS) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  runApp(ChangeNotifierProvider(
    create: (context) => alarmprovider(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    context.read<alarmprovider>().Inituilize(context);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    context.read<alarmprovider>().GetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEFF5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        actions: const [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          )
        ],
        title: const Text(
          'Alarm Clock ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)
                ),
            ),
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
                child: Text(
                  DateFormat.yMEd().add_jms().format(DateTime.now(),),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white
                  ),
                ),
            ),
          ),
          // アラーム設定部分
          Consumer<alarmprovider>(
              builder: (context, alarm, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                  itemCount: alarm.modelist.length,
                  itemBuilder: (BuildContext, index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          alarm.modelist[index].dateTime!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("| + ${alarm.modelist[index].label}"),
                                        ),
                                      ],
                                    ),
                                    CupertinoSwitch(
                                        value:(alarm.modelist[index].milliseconds! < DateTime.now().millisecondsSinceEpoch)? false:alarm.modelist[index].check,
                                        onChanged: (v) {
                                          alarm.EditSwitch(index, v);
                                          alarm.CancelNotification(alarm.modelist[index].id!);
                                        }),
                                  ],
                                ),
                                Text(alarm.modelist[index].when!)
                              ],
                            ),
                          ),
                        ));
                  }),
            );
              }),
          // フッター
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Colors.deepPurpleAccent),
            // プラスボタン
            child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddAlarm()));
                  },
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.add),
                      )),
                )),
          ),
        ],
      ),
    );
  }
}
