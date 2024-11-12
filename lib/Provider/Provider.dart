import 'dart:convert';

import 'package:alarm_project/Model/Model.dart';
import 'package:alarm_project/Screen/Add_Alarm.dart';
import 'package:alarm_project/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform; //iOSとAndroidの分割に必要

// late 変数の初期化を遅らせる。 final 変数の初期値を変更できない。
// ChangeNotifierをextendsしているクラスは、インスタンスの中のメソッドが実行されるとchangeNotifierで知らせることができるようになる
// modelist Modelクラスのオブジェクトのみ格納可能
// listofstring modelistをJsonに変換し、SharedPreferencesに保存する際に使用
class alarmprovider extends ChangeNotifier{

  late SharedPreferences preferences;

  List<Model> modelist=[];

  List<String> listofstring=[];

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  late BuildContext context;

  // alarmをmodelistに追加するメゾット
  SetAlaram(String label,String dateTime,bool check,String repeat,int id,int milliseconds,String title, String location, String memo, String notificationSound, String notificationImage, List<String> repeatDays,){

    modelist.add(Model(
      label: label,
      dateTime: dateTime,
      check: check,
      when: repeat,
      id: id,
      milliseconds: milliseconds,
      title: title,
      location: location,
      memo:memo,
      notificationSound: notificationSound,
      notificationImage: notificationImage,
      repeatDays: repeatDays,
    ));
    notifyListeners();
  }


  // alarmのオンオフを切り替える(check状態)
  EditSwitch(int index,bool check){
    modelist[index].check=check;
    notifyListeners();
  }


  // SharedPreferencesを使いアプリの再起動後も保存されたアラームリストを復元
  GetData()async{

    preferences=await SharedPreferences.getInstance();

    List<String>? cominglist = await preferences.getStringList("data");

    if(cominglist == null){


    }else{

      modelist = cominglist.map((e) => Model.fromJson(json.decode(e))).toList();
      notifyListeners();
    }




  }





  SetData(){


    listofstring = modelist.map((e) => json.encode(e.toJson())).toList();
    preferences.setStringList("data", listofstring);

    notifyListeners();

  }




  Inituilize(con) async {
    context=con;
    var androidInitilize =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSinitilize = new DarwinInitializationSettings();
    var initilizationsSettings =
    InitializationSettings(android: androidInitilize, iOS: iOSinitilize);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!.initialize(initilizationsSettings,
        onDidReceiveNotificationResponse:onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => MyApp())
    );
  }




  ShowNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }






  SecduleNotification(DateTime datetim,int Randomnumber) async {

    int newtime= datetim.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    print(datetim.millisecondsSinceEpoch);
    print(DateTime.now().millisecondsSinceEpoch);
    print(newtime);
    final sound = 'sound.mp3';
    await flutterLocalNotificationsPlugin!.zonedSchedule(
        Randomnumber,
        'Alarm Clock',
        "${DateFormat().format(DateTime.now())}",
        tz.TZDateTime.now(tz.local).add( Duration(milliseconds: newtime)),

        NotificationDetails(
          iOS: DarwinNotificationDetails(
            sound: sound,
          )
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }




  CancelNotification(int notificationid)async{

    await flutterLocalNotificationsPlugin!.cancel(notificationid);


  }




}