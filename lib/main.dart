import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahug Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bahug App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double requiredCrudeProtein = 0;
  Map<String, double> feedFormula = {
    "": 0.0,
    "Broiler Starter Mash": 0.19,
    "Duck Starter Mash": 0.19,
    "Fry Mash Milk Fish": 0.31,
    "Crumble Milk Fish": 0.20,
    "Crumble Tilapia": 0.31
  };
  double totalIngredientPercent = 0;
  final List<Map<String, dynamic>> ingredientControllers = [
    {
      "name": "Sweet Potato Leaves (Tagbina)",
      "controller": TextEditingController(),
      "percent": 0.2103,
    },
    {
      "name": "Sweet Potato Leaves (Del Monte)",
      "controller": TextEditingController(),
      "percent": 0.1626,
    },
    {
      "name": "Sweet Potato Flesh Unpeeled",
      "controller": TextEditingController(),
      "percent": 0.0329,
    },
    {
      "name": "Soybean (Manchuria Var.)",
      "controller": TextEditingController(),
      "percent": 0.3964,
    },
    {
      "name": "Soybean (Tudela Var.)",
      "controller": TextEditingController(),
      "percent": 0.3863,
    },
  ];

  void updateTotalIngredientPercent() {
    totalIngredientPercent = 0;
    for(int i=0; i<ingredientControllers.length; i++) {
      if(ingredientControllers[i]["controller"].text != "") {
        totalIngredientPercent += double.parse(ingredientControllers[i]["controller"].text)
          * ingredientControllers[i]["percent"];
      }
    }
    totalIngredientPercent = double.parse((totalIngredientPercent * 100).toStringAsFixed(3));
  }
  @override
  void dispose() {
    ingredientControllers[0]["controller"].dispose();
    ingredientControllers[1]["controller"].dispose();
    ingredientControllers[2]["controller"].dispose();
    ingredientControllers[3]["controller"].dispose();
    ingredientControllers[4]["controller"].dispose();
    super.dispose();
  }

  // Fetching network data.
  late Map<String, dynamic> futureBahugData;
  late List<Map<String, dynamic>> allData;
  late List<String> regions;
  String selectedRegion = "";
  late List<String> livestock;
  String selectedLivestock = "";
  late List<String> feedFormulas;
  String selectedFeedFormula = "";

  Future<bool> fetchBahugData() async {
    final response = await http
      .get(Uri.parse("http://localhost:3000/api/all_data"));
    if(response.statusCode == 200) {
      futureBahugData = jsonDecode(response.body);
      allData = futureBahugData["all_data"].cast<Map<String, dynamic>>();
      regions = futureBahugData["regions"].cast<String>();
      livestock = futureBahugData["livestock"].cast<String>();
      feedFormulas = futureBahugData["feed_formulas"].cast<String>();

      Iterable<Map<String, dynamic>> testData = allData.where((element) => element["livestock"] == "Chicken");
      print(testData);
      return true;
    } else {
      throw Exception('Failed to load data.');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBahugData();
  }

  @override
  Widget build(BuildContext context) {
    fetchBahugData();
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.calculate),
              ),
              Tab(
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Spacer(flex: 1,),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Total Crude Protein (%)",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${totalIngredientPercent.toString()} %",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 72
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Required Crude Protein (%)",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${feedFormula[selectedFeedFormula]! * 100} %",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 72
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(flex: 2,),
                  Column(
                    children: [
                      const Text(
                        "Region",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      FutureBuilder(
                        future: fetchBahugData(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            return DropdownButton(
                              items: regions.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              )).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRegion = newValue!;
                                });
                              },
                              hint: Text(selectedRegion),
                              elevation: 16,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            );
                          } else if(snapshot.hasError) {
                            return Text("${snapshot.error} ${snapshot.connectionState}");
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                  const Spacer(flex: 1,),
                  Column(
                    children: [
                      const Text(
                        "Livestock",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      FutureBuilder(
                        future: fetchBahugData(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            return DropdownButton(
                              items: livestock.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              )).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLivestock = newValue!;
                                });
                              },
                              hint: Text(selectedLivestock),
                              elevation: 16,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            );
                          } else if(snapshot.hasError) {
                            return Text("${snapshot.error} ${snapshot.connectionState}");
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                  const Spacer(flex: 1,),
                  Column(
                    children: [
                      const Text(
                        "Feed Formula",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      FutureBuilder(
                        future: fetchBahugData(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            return Container();
                            return DropdownButton(
                              items: feedFormulas.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              )).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedFeedFormula = newValue!;
                                });
                              },
                              hint: Text(selectedFeedFormula),
                              elevation: 16,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            );
                          } else if(snapshot.hasError) {
                            return Text("${snapshot.error} ${snapshot.connectionState}");
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                  const Spacer(flex: 2,),
                ],
              )
            ),
            ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: ingredientControllers[0]["controller"],
                    onChanged: (e) {
                      setState(() {
                        updateTotalIngredientPercent();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: ingredientControllers[0]["name"],
                      hintText: "Weight in kilograms"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: ingredientControllers[1]["controller"],
                    onChanged: (e) {
                      setState(() {
                        updateTotalIngredientPercent();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: ingredientControllers[1]["name"],
                      hintText: "Weight in kilograms"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: ingredientControllers[2]["controller"],
                    onChanged: (e) {
                      setState(() {
                        updateTotalIngredientPercent();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: ingredientControllers[2]["name"],
                      hintText: "Weight in kilograms"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: ingredientControllers[3]["controller"],
                    onChanged: (e) {
                      setState(() {
                        updateTotalIngredientPercent();
                      });
                    },
                    decoration: InputDecoration(
                        labelText: ingredientControllers[3]["name"],
                        hintText: "Weight in kilograms"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: ingredientControllers[4]["controller"],
                    onChanged: (e) {
                      setState(() {
                        updateTotalIngredientPercent();
                      });
                    },
                    decoration: InputDecoration(
                        labelText: ingredientControllers[4]["name"],
                        hintText: "Weight in kilograms"
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Ingredients',
          child: const Icon(Icons.info_outline_rounded),
        ),
      ),
    );
  }
}
