import 'package:example/config/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_packet_capture/flutter_packet_capture.dart';
import 'package:tip_dialog/tip_dialog.dart';

import 'app_bar/custom_app_bar.dart';
import 'network/network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '抓包测试',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '抓包测试demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Packetcapture.setConfig(schemeConfig: 'capture://',modeConfig: "debug");

    Packetcapture.initUniLinks(callBack: (hostPort){
      //设置代理
      Network.setHttpProxy(hostPort);
    });

  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: CustomAppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    TipDialogHelper.loading("Loading");
                     Network.get(Api.getModules).then((value){
                       TipDialogHelper.dismiss();
                    }).catchError((e){
                      TipDialogHelper.dismiss();
                    });
                  },
                  padding: EdgeInsets.all(10),
                  color: Colors.teal,
                  child: Text('网络请求',style: TextStyle(
                    color: Colors.white,
                  ),),
                ),
              ],
            ),
          ),
          TipDialogContainer(
              duration: const Duration(seconds: 2),
              outsideTouchable: true,
              onOutsideTouch: (Widget tipDialog) {
                if (tipDialog is TipDialog &&
                    tipDialog.type == TipDialogType.LOADING) {
                  TipDialogHelper.dismiss();
                }
              })
        ],
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
