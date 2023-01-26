import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


class TotalPercentProximateAnalysisCubit extends Cubit<double> {
  TotalPercentProximateAnalysisCubit(double initialState) : super(initialState);

  @override
  void onChange(Change<double> change) {
    super.onChange(change);
    print(change);
  }

  // Temporary algorithm, as this is costly. Create alternative.
  // tecs = TextEditingControllers
  void update(Map<int, Map<String, dynamic>> tecs) {
    double totalIngredientPercent = 0;
    for(var item in tecs.keys) {
      TextEditingController tec = tecs[item]?["text_editing_controller"];
      double crudeProtein = tecs[item]?["crude_protein"];
      totalIngredientPercent += crudeProtein * double.parse(tec.text != "" ? tec.text : "0");
    }
    totalIngredientPercent = double.parse((totalIngredientPercent).toStringAsFixed(3));

    emit(totalIngredientPercent);
  }
}