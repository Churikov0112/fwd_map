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
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text("Dynamic Markers"),
              subtitle: const Text("as Flutter Widgets"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Static Markers"),
              subtitle: const Text("made by Flutter Widgets"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Static Markers"),
              subtitle: const Text("made by Network Images"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Static Markers"),
              subtitle: const Text("made by Asset Images"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Polyline"),
              subtitle: const Text("made by Maplibre"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Polygon"),
              subtitle: const Text("made by Maplibre"),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Fwd Map Example"),
      ),
      body: Stack(
        children: [
          FwdMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(59, 30),
              zoom: 8,
            ),
            trackCameraPosition: true,
            onFwdMapCreated: (controller) {
              fwdMapController = controller;
              setState(() {});
            },
            zoomPreference: MinMaxZoomPreference.unbounded,
          ),
          // if (fwdMapController != null) DynamicMarkers(fwdMapController: fwdMapController!),
          // if (fwdMapController != null) StaticMarkersFromWidget(fwdMapController: fwdMapController!),
          // if (fwdMapController != null) StaticMarkersFromAssetImage(fwdMapController: fwdMapController!),
          // if (fwdMapController != null) StaticMarkersFromNetworkImage(fwdMapController: fwdMapController!),
          // if (fwdMapController != null) Polylines(fwdMapController: fwdMapController!),
          // if (fwdMapController != null) Polygons(fwdMapController: fwdMapController!),
        ],
      ),
    );
  }
}
