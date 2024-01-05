import 'package:flutter/material.dart';
import 'package:mealy/providers/MealProvider.dart';
import 'package:provider/provider.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case 'mealPage':
        print('MEALPAGE');
        print(args);
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(child: Text(args.toString())),
                ));
        // return MaterialPageRoute(builder: (context) {
        //   Provider.of<MealProvider>(context).readSingleMeal(mealId).then((value) {
        //   final meal = Provider.of<MealProvider>(context).singleMeal;
        //   print(meal);
        //   // Navigator.push(
        //   //   context,
        //   //   PageRouteBuilder(
        //   //     transitionDuration: const Duration(milliseconds: 150),
        //   //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //   //       return SlideTransition(
        //   //         position: Tween<Offset>(
        //   //           begin: const Offset(1, 0),
        //   //           end: Offset.zero,
        //   //         ).animate(animation),
        //   //         child: child,
        //   //       );
        //   //     },
        //   //     pageBuilder: (context, animation, duration) => MealViewScreen(
        //   //       naziv: meal.naziv,
        //   //       opis: meal.opis,
        //   //       brOsoba: meal.brOsoba,
        //   //       vrPripreme: meal.vrPripreme,
        //   //       tezina: meal.tezina,
        //   //       imageUrl: meal.imageUrl,
        //   //       ratings: meal.ratings,
        //   //       sastojci: meal.sastojci,
        //   //       koraci: meal.koraci,
        //   //       autorId: meal.autorId,
        //   //       receptId: meal.receptId,
        //   //       favorites: meal.favorites,
        //   //       tagovi: meal.tagovi,
        //   //       createdAt: meal.createdAt,
        //   //       isAutorClick: meal.isAutorClick,
        //   //     ),
        //   //   ),
        //   // );
        // });
        // });
        break;
      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          body: Center(
            child: Text(
              'Nismo našli taj recept',
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
        );
      },
    );
  }
}
