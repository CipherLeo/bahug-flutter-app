import 'package:flutter_bloc/flutter_bloc.dart';

class RequiredPercentProximateAnalysesCubit extends Cubit<double> {
  RequiredPercentProximateAnalysesCubit(double initialState) : super(initialState);

  @override
  void onChange(Change<double> change) {
    super.onChange(change);
    print(change);
  }

  void update(List<Map<String, dynamic>> requirements, String feedFormulaName) {
    List<Map<String, dynamic>> foundRequirement = requirements
      .where((element) => (
        element['feed_formula_name'] == feedFormulaName
        && element['proximate_analysis_name'] == "Crude Protein"
      )).toList();
    if(foundRequirement.isNotEmpty) {
      if(foundRequirement[0]['percentage'] is String) {
        emit(double.parse(foundRequirement[0]['percentage']));
      } else {
        emit(foundRequirement[0]['percentage']);
      }
    } else {
      emit(0);
    }
  }
}