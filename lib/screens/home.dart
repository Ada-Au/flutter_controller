import 'package:flutter/material.dart';
import 'package:flutter_controller/components/joystick.dart';
import 'dart:async';
import 'dart:convert' show utf8;
import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:flutter_blue/flutter_blue.dart';

//class Home extends StatelessWidget {
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //getting every data for conencting BLE server ready
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32 GET NOTI FROM DEVICE";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;

  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  int isDancing = 0;
  int isRotating = 0;
  int isBalancing = 0;
  int isBarking = 0;
  int power = 0;
  int turnVal = 0;
  Offset position = Offset(0, 0);
  String connectionText = "";
  String output =
      "*x20y20e1111"; // protocol for transmiting x,y,isDancing, isRotating, isBalancing, haven't defined yet
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      //listen to stream of event
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice(); // connect to the desired device after found it
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription.cancel();
    //scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            writeData("Hi there, ESP32!!");
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        });
      }
    });
  }

  writeData(String data) async {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    await targetCharacteristic.write(bytes);
  }

  String createCmd(Offset value) {
    int x = (value.dx * 10).toInt() + 10; // range from 20 to 0 now
    int y = (value.dy * 10).toInt() + 10;
    // String cmd = "x" +
    //     x.toString() +
    //     "y" +
    //     y.toString() +
    //     "p" +
    //     power.toString() +
    //     "t" +
    //     turnVal.toString();
    String cmd = "*x" +
        x.toString() +
        "y" +
        y.toString() +
        "e" +
        isDancing.toString() +
        isRotating.toString() +
        isBalancing.toString() +
        isBarking.toString();
    return cmd;
  }

  void handleChange(Offset value) {
    //print(value.toString());
    position = value;
    String cmd = createCmd(position);
    writeData(cmd);
    position = Offset(0, 0);
  }

  void buttonListner(int index) {
    switch (index) {
      case 0:
        isDancing = isDancing == 0 ? 1 : 0; //toggle 1 and 0
        break;
      case 1:
        isRotating = isRotating == 0 ? 1 : 0;
        break;
      case 2:
        isBalancing = isBalancing == 0 ? 1 : 0;
        break;
      case 3:
        isBarking = isBarking == 0 ? 1 : 0;
        break;
      default:
    }
  }

  PadButtonPressedCallback padBUttonPressedCallback(
      int buttonIndex, Gestures gesture) {
    String data = "buttonIndex : ${buttonIndex}";
    buttonListner(buttonIndex);
    String cmd = createCmd(position);
    writeData(cmd);
    throw '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Doggie Controller'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/images/image1.jpg"), fit: BoxFit.cover),
          ),
          child: !connectionText.contains("All Ready with")
              ? Center(
                  child: Text(
                  "waiting...",
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Joystick(onChange: handleChange),
                    ),
                    PadButtonsView(
                      padButtonPressedCallback: padBUttonPressedCallback,
                    ),
                  ],
                ),
        ));
  }
}
