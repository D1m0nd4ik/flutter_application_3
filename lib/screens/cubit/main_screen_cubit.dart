import 'main_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenCubit extends Cubit<MainScreenState>{
  MainScreenCubit() : super(MainScreenUpdateCounterState(value: 0));

int counter = 0;

void addValue(){
  counter++;
  emit(MainScreenUpdateCounterState(value: counter));
}

void removeValue(){
  counter--;
  emit(MainScreenUpdateCounterState(value: counter));
}
}