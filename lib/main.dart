import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fwd Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FwdMapExample(),
    );
  }
}

class FwdMapExample extends StatefulWidget {
  const FwdMapExample({super.key});

  @override
  State<FwdMapExample> createState() => _FwdMapExampleState();
}

class _FwdMapExampleState extends State<FwdMapExample> {
  FwdMapController? fwdMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fwd Map Example"),
      ),
      body: Center(
        child: FwdMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(59, 30),
            zoom: 3,
          ),
          trackCameraPosition: true,
          onFwdMapCreated: (controller) {
            fwdMapController = controller;
            setState(() {});
          },
          zoomPreference: MinMaxZoomPreference.unbounded,
        ),
      ),
    );
  }
}
