import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:wedding_services_app/search_location_screen.dart';
import 'package:wedding_services_app/utils.dart';

import 'component/location_list_tile.dart';
import 'component/network_utiliti.dart';
import 'model/autocomplete_prediction.dart';
import 'model/place_auto_complete_response.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => TrackingScreenState();
}

class TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(24.8477, 67.0375);

  static const LatLng destination = LatLng(24.8974, 67.0228);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) => currentLocation = location);
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              zoom: 10.5,
              // target: LatLng(newLoc.latitude!, newLoc.longitude!)
              target: LatLng(
                24.8477,
                67.0375,
              ))));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_source.png')
        .then((icon) => sourceIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Pin_destination.png')
        .then((icon) => destinationIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/Badge.png')
        .then((icon) => currentLocationIcon = icon);
  }

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> _polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  @override
  void initState() {
    setCustomMarkerIcon();
    getCurrentLocation();
    getPolyPoints();
    super.initState();
    _setMarker(LatLng(24.8974, 67.0228));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: _polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent));
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(Polyline(
      polylineId: PolylineId(polylineIdVal),
      width: 2,
      color: Colors.blue,
      points: points
          .map(
            (point) => LatLng(point.latitude, point.longitude),
          )
          .toList(),
    ));
  }

  TextEditingController textController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  List<AutocompletePrediction> placePrediction = [];

  void placeAutocomplete(String query) async {
    Uri uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': query,
      'key': apiKey,
    });

    String? response = await NetworkUtilitiy.fetchUrl(uri);
    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePrediction = result.predictions!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Center(child: Text('loading'))
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(24.8974, 67.0228),
                      // target: LatLng(currentLocation!.latitude!,
                      //     currentLocation!.longitude!),
                      zoom: 10.5,
                    ),
                    polygons: _polygons,
                    polylines: _polylines,

                    // {
                    //   Polyline(
                    //       polylineId: PolylineId('route'),
                    //       points: polylineCoordinates,
                    //       color: Colors.blue,
                    //       endCap: Cap.roundCap,
                    //       width: 6)
                    // },
                    markers: _markers,
                    // {
                    //   Marker(
                    //     markerId: MarkerId('currentLocation'),
                    //     icon: currentLocationIcon,
                    //     position: LatLng(currentLocation!.latitude!,
                    //         currentLocation!.longitude!),
                    //   ),
                    //   Marker(
                    //     markerId: MarkerId('sourse'),
                    //     position: sourceLocation,
                    //     icon: sourceIcon,
                    //   ),
                    //   Marker(
                    //     markerId: MarkerId('destination'),
                    //     icon: destinationIcon,
                    //     position: destination,
                    //   )
                    // },
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                    },
                    onTap: (point) {
                      setState(() {
                        _polygonLatLngs.add(point);
                        _setPolygon();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Form(
                          child: TextFormField(
                            controller: textController,
                            onChanged: (value) {
                              placeAutocomplete(value);
                            },
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  // var place = await LocationService()
                                  //     .getPlace(textController.text);
                                  // _goToPlace(place);
                                },
                                icon: Icon(Icons.search),
                              ),
                              hintText: "Origin",
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: SvgPicture.asset(
                                  "assets/location_pin.svg",
                                  color: secondaryColor40LightTheme,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Form(
                          child: TextFormField(
                            controller: destinationController,
                            onChanged: (value) {
                              placeAutocomplete(value);
                            },
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  var directions = await LocationService()
                                      .getDirections(destinationController.text,
                                          textController.text);
                                  _goToPlace(
                                      directions['start_location']['lat'],
                                      directions['start_location']['lng']);

                                  _setPolyline(directions['polyline_decoded']);
                                },
                                icon: Icon(Icons.search),
                              ),
                              hintText: "Destination",
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: SvgPicture.asset(
                                  "assets/location_pin.svg",
                                  color: secondaryColor40LightTheme,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: placePrediction.length,
                              itemBuilder: (context, index) => LocationListTile(
                                  press: () {},
                                  location:
                                      placePrediction[index].description!)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _goToPlace(
    // Map<String, dynamic> place
    double lat,
    double lng,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']["lng"];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12),
    ));
    _setMarker(LatLng(lat, lng));
  }
}
