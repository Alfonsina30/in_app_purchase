import 'package:app_pubblicita_monetizazione/datasource/in_app_purchase_controller.dart';
import 'package:app_pubblicita_monetizazione/cubit/handle_monetization_cubit.dart';
import 'package:app_pubblicita_monetizazione/screen/monetizzazione_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HandleMonetizationCubit(InAppPurchaseController()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: MonetizzazioneScreen(),
      ),
    );
  }
}
