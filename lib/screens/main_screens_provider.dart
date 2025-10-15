import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/main_screen_cubit.dart';
import 'main_screen.dart';

class MainScreensProvider extends StatelessWidget{
@override
Widget build(BuildContext content){
  return BlocProvider<MainScreenCubit>(
    create: (content) => MainScreenCubit(),
    child: MainScreen(),
    );
  }
}