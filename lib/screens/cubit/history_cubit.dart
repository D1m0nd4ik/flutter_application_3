import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/database_helper.dart';
import '../../models/calculation.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    try {
      final calculations = await DatabaseHelper.getAllCalculations();
      emit(HistoryLoaded(calculations));
    } catch (e) {
      emit(HistoryError('Ошибка загрузки истории: $e'));
    }
  }

  Future<void> addCalculation(Calculation calculation) async {
    await DatabaseHelper.insertCalculation(calculation);
    loadHistory();
  }
}