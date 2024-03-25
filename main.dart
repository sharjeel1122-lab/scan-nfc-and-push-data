import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';


void main() {
  runApp(Send());
}

final String username = 'sharjeel1122';
final String feedKey = 'feed';
final String apiKey = '$key';
String nfcData = '';

Future<void> sendDataToAdafruitIO(String data) async {
  final String url =
      'https://io.adafruit.com/api/v2/$username/feeds/$feedKey/data';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-AIO-Key': apiKey,
  };

  final Map<String, dynamic> body = {
    'value': data,
  };

  final response =
  await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

  if (response.statusCode == 200) {
    print('Data sent to Adafruit IO successfully.');
  } else {
    print('Failed to send data to Adafruit IO. Error: ${response.statusCode}');
  }
}

class Send extends StatefulWidget {
  const Send({super.key});

  @override
  State<Send> createState() => _MyAppState();
}


class _MyAppState extends State<Send> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String nfcData = '';
  @override
  void initState() {
    super.initState();
    initNFC();
  }
  Future<void> initNFC() async {
    final available = await NfcManager.instance.isAvailable();
    if (available) {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async{
          setState(() {
            nfcData = tag.data.toString();
          });
        },
      );
    }
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data.toString();
      nfcData = tag.data.toString();
      print(nfcData);
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Scaffold(
        appBar: AppBar(
        leading:IconButton(onPressed: (){
      Navigator.pop(context);
    },icon: Icon(Icons.arrow_back_ios_new),),

    backgroundColor: Colors.green,
    title: Text('Send Data'),
    ),
    body: SafeArea(
    child: FutureBuilder<bool>(
    future: NfcManager.instance.isAvailable(),
    builder: (context, ss) =>
    ss.data != true
    ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
        : Flex(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    direction: Axis.vertical,
    children: [
      
      Text(nfcData,style: TextStyle(color: Colors.green, fontSize: 10),),
    Flexible(
    flex: 2,
    child: Container(
    margin: EdgeInsets.all(4),
    constraints: BoxConstraints.expand(),
    decoration: BoxDecoration(border: Border.all()),
    child: SingleChildScrollView(
    child: ValueListenableBuilder<dynamic>(
    valueListenable: result,
    builder: (context, value, _) =>
    Text('${value ?? ''}'),
    ),
    ),
    ),
    ),
    Flexible(
    flex: 3,
    child: GridView.count(
    padding: EdgeInsets.all(4),
    crossAxisCount: 2,
    childAspectRatio: 4,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
    children: [

    ElevatedButton(
    child: Text('Tag Read'), onPressed: (){
      _tagRead();

    }),
      ElevatedButton(
          child: Text('Send Data'), onPressed: ()
      {
        sendDataToAdafruitIO(nfcData);

      }),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    );
  }
}
