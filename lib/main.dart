import 'package:flutter/material.dart';
import 'package:k3tab_2023/repository/item_repository.dart';
import 'package:k3tab_2023/repository/shipping_repository.dart';
import 'package:provider/provider.dart';
import 'package:k3tab_2023/view/home_screen.dart';
import 'package:k3tab_2023/view/splash_screen.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ListenableProvider<ShippingRepository>(create: (_) => ShippingRepository(),),
      ListenableProvider<ItemRepository>(create: (_) => ItemRepository()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final shippingRepository = Provider.of<ShippingRepository>(context);
    final itemRepository = Provider.of<ItemRepository>(context);

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      // home: const HomeScreen(),
      routes: {
        "/": (ctx) => const SplashScreen(),
        "/home": (ctx) => HomeScreen(shippingRepo: shippingRepository, itemRepo: itemRepository,),
      },
    );
  }
}
