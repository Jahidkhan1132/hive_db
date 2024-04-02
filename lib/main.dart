
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_db/homePage.dart';
import 'package:hive_db/homePageProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  var directory= await getApplicationDocumentsDirectory();

  Hive.init(directory.path);

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomePageProvider(),)
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
