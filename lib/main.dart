import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sgp4_sdp4/sgp4_sdp4.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class SatelliteModel {
  String? name;
  int? noradId;
  String? id;
  SatelliteModel({required this.name, required this.noradId, required this.id});
  SatelliteModel.fromJson(Map<String, dynamic> json) {
    name = json["OBJECT_NAME"];
    id = json["OBJECT_ID"];
    noradId = json["NORAD_CAT_ID"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["OBJECT_NAME"] = name;
    data["OBJECT_ID"] = id;
    data["NORAD_CAT_ID"] = noradId;
    return data;
  }
}

Future<List<SatelliteModel>> fetchModel() async {
  final response = await http.get(Uri.parse(
      'https://celestrak.org/NORAD/elements/gp.php?GROUP=cubesat&FORMAT=json'));
  if (response.statusCode == 200) {
    final List result = json.decode(response.body);
    return result.map((e) => SatelliteModel.fromJson(e)).toList();
  } else {
    throw Exception('Error: Data Fetch Unsuccessful');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "C U B E S A T",
          style: TextStyle(
            color: Color(0xFFEC4700),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        centerTitle: true,
        leadingWidth: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1F1F1F)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded, color: Color(0xFF1F1F1F),))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white54,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_rounded,
              ),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<SatelliteModel>>(
        future: fetchModel(),
        builder: (BuildContext context,
            AsyncSnapshot<List<SatelliteModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 50,
                      mainAxisSpacing: 50,
                      ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                       decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 244, 244, 244),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.2,
                      padding: EdgeInsets.all(50),
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              snapshot.data![index].name.toString(),
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Text(
                              snapshot.data![index].id.toString(),
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF787C7D),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Text(
                              snapshot.data![index].noradId.toString(),
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.025,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFEC4700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
          }

          // Show a loading spinner while waiting for the data to load
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEC4700),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, 
        child: Icon(Icons.filter_alt_outlined),
        backgroundColor: const Color(0xFFEC4700),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
      ),
    );
  }
}
