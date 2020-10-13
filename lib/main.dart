import 'package:agenda_de_contatos_app/ui/home_page.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda de Contatos',
      theme: ThemeData(
        // We set Poppins as our default font
        primaryColor: kPrimaryColor,
        /*textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),*/
        accentColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
