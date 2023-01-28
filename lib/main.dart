import 'dart:convert';
import 'package:bahug_app/cubits/required_percent_proximate_analyses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/total_percent_proximate_analysis_cubit.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TotalPercentProximateAnalysisCubit>(
          create: (_) => TotalPercentProximateAnalysisCubit(0),
        ),
        BlocProvider<RequiredPercentProximateAnalysesCubit>(
          create: (_) => RequiredPercentProximateAnalysesCubit(0),
        )
      ],
      child: MaterialApp(
        title: 'Bahug Application',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Bahug App'),
      )
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
  Map<int, Map<String, dynamic>> ingredientInputControllers = {};

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
  late List<Map<String, dynamic>> requirements;

  Future<bool> fetchBahugData() async {
    final response = await http
      .get(Uri.parse("http://localhost:3000/api/all_data"));
    if(response.statusCode == 200) {
      futureBahugData = jsonDecode(response.body);
      allData = futureBahugData["all_data"].cast<Map<String, dynamic>>();
      regions = futureBahugData["regions"].cast<String>();

      livestock = [];
      for (var e in futureBahugData["livestock"]) {
        if(e != null) {
          livestock.add(e);
        }
      }
      feedFormulas = [];
      for (var e in futureBahugData["feed_formulas"]) {
        if(e != null) {
          feedFormulas.add(e);
        }
      }

      requirements = futureBahugData["proximate_analysis_requirements"]
        .cast<Map<String, dynamic>>();
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
                            BlocBuilder<TotalPercentProximateAnalysisCubit, double>(
                                builder: (context, state) {
                                  double totalPercent = state;
                                  double requiredPercent = context.read<RequiredPercentProximateAnalysesCubit>().state;
                                  Color totalPercentColor = Colors.black;
                                  double allowedPercentage = 0.05;

                                  if(totalPercent < requiredPercent - (requiredPercent * allowedPercentage)) {
                                    totalPercentColor = Colors.red;
                                  } else if (totalPercent > requiredPercent + (requiredPercent * allowedPercentage)) {
                                    totalPercentColor = Colors.purple;
                                  } else {
                                    totalPercentColor = Colors.green;
                                  }
                                  return Text(
                                    "${state.toString()} %",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 72,
                                      color: totalPercentColor,
                                    ),
                                  );
                                }
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
                            BlocBuilder<RequiredPercentProximateAnalysesCubit, double>(
                              builder: (context, state) {
                                return Text(
                                  "$state %",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 72
                                  ),
                                );
                              },
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
                                  ingredientInputControllers.clear();
                                  context.read<TotalPercentProximateAnalysisCubit>()
                                    .update(ingredientInputControllers);
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
                                  ingredientInputControllers.clear();
                                  context.read<TotalPercentProximateAnalysisCubit>()
                                    .update(ingredientInputControllers);
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
                                    selectedFeedFormula = newValue.toString();
                                  });
                                  ingredientInputControllers.clear();
                                  context.read<TotalPercentProximateAnalysisCubit>()
                                    .update(ingredientInputControllers);

                                  // Update Required Proximate Analysis (Crude Protein) Requirement.
                                  context.read<RequiredPercentProximateAnalysesCubit>()
                                    .update(requirements, newValue.toString());
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
                return Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                                context.read<TotalPercentProximateAnalysisCubit>()
                                  .update(ingredientInputControllers);
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
