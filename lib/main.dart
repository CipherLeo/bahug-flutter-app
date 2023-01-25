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
  Map<int, Map<String, dynamic>> ingredientInputControllers = {};

  // Temporary algorithm, as this is costly. Create alternative.
  void updateTotalIngredientPercent() {
    totalIngredientPercent = 0;
    for(var item in ingredientInputControllers.keys) {
      TextEditingController tec = ingredientInputControllers[item]?["text_editing_controller"];
      double crudeProtein = ingredientInputControllers[item]?["crude_protein"];
      totalIngredientPercent += crudeProtein * double.parse(tec.text != "" ? tec.text : "0");
      // if(tec.text != "") {
      //   totalIngredientPercent += crudeProtein * double.parse(tec.text);
      // }
    }
    totalIngredientPercent = double.parse((totalIngredientPercent).toStringAsFixed(3));
  }
  @override
  void dispose() {
    for(var item in ingredientInputControllers.keys) {
      if(ingredientInputControllers[item]?["text_editing_controller"] != null) {
        ingredientInputControllers[item]?["text_editing_controller"].dispose();
      }
    }
    super.dispose();
  }

  // Fetch network data.
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Dashboard
          Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                    const SizedBox(height: 20,),
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
                    const SizedBox(height: 20,),
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
                                    selectedFeedFormula = "";
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
                    const SizedBox(height: 20,),
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
                              return DropdownButton(
                                items: allData
                                    .where((Map<String, dynamic> e) => (
                                    e["livestockname"] == selectedLivestock
                                        && e["region"] == selectedRegion
                                )
                                )
                                    .map((Map<String, dynamic> e) => e["feedname"]).toSet()
                                    .map((dynamic e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                )).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedFeedFormula = newValue.toString()!;
                                    ingredientInputControllers.clear();
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

                  ],
                ),
              ),
            ),
          ),
          // Ingredients List
          FutureBuilder(
            future: fetchBahugData(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    children: allData
                      .where((element) => (
                        element["region"] == selectedRegion
                          && element["livestockname"] == selectedLivestock
                          && element["feedname"] == selectedFeedFormula
                          && element["proxname"] == "Crude Protein"
                      ))
                      .map((e) {
                        // Assign TextEditingController and Crude Protein.
                        int index = allData.indexOf(e);
                        TextEditingController tec = TextEditingController();
                        ingredientInputControllers[index] = {
                          "crude_protein": e["percentage"],
                          "text_editing_controller": tec
                        };
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: TextFormField(
                            controller: tec,
                            onChanged: (e) {
                              // setState(() {});
                              updateTotalIngredientPercent();
                            },
                            decoration: InputDecoration(
                              labelText: e["ingredientsname"] + " — "
                                + e["munname"] + " ("
                                + e["percentage"].toString() + ")",
                              // labelText: ingredientInputControllers[index]?["text_editing_controller"].toString(),
                              hintText: "Weight in kg"
                            ),
                          ),
                        );
                      }).toList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        tooltip: 'Ingredients',
        child: const Icon(Icons.info_outline_rounded),
      ),
    );
  }
}
