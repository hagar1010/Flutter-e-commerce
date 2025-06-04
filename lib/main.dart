import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home.dart';
import 'profile.dart';
import 'cart.dart';
import 'catalog.dart';
import 'orders.dart';
import 'splash.dart';
import 'login.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const FinalProject());
}

class FinalProject extends StatelessWidget {
  const FinalProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _controller;
  late Animation<Color?> _gradientStart;
  late Animation<Color?> _gradientEnd;

  final List<Widget> _screens = [
    CartScreen(),
    CategoryProductsScreen(category: "all"),
    HomeScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.shopping_cart_outlined,
    Icons.library_books_outlined,
    Icons.home_outlined,
    Icons.history,
    Icons.person_outline,
  ];

  final List<String> _labels = ['Cart', 'Catalog', 'Home', 'Orders', 'Profile'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradientStart = ColorTween(
      begin: Colors.pinkAccent.shade100,
      end: Colors.blueAccent.shade100,
    ).animate(_controller);

    _gradientEnd = ColorTween(
      begin: Colors.blueAccent.shade100,
      end: Colors.pinkAccent.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<ImageProvider?> _getProfileImage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final imagePath = prefs.getString('profile_image_path');
  //   if (imagePath != null && await File(imagePath).exists()) {
  //     return FileImage(File(imagePath));
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart.value!, _gradientEnd.value!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[300],
            showSelectedLabels: true,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(icon: Icon(_icons[0]), label: _labels[0]),
              BottomNavigationBarItem(icon: Icon(_icons[1]), label: _labels[1]),
              BottomNavigationBarItem(icon: Icon(_icons[2]), label: _labels[2]),
              BottomNavigationBarItem(icon: Icon(_icons[3]), label: _labels[3]),
              BottomNavigationBarItem(
                icon: FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final imagePath = snapshot.data!.getString(
                        'profile_image_path',
                      );
                      return CircleAvatar(
                        radius: 12,
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath))
                            : null,
                        child: imagePath == null
                            ? const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      );
                    }
                    return const Icon(Icons.person_outline);
                  },
                ),
                label: _labels[4],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'E-Commerce App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       initialRoute: '/splash',
//       routes: {
//         '/splash': (context) => SplashScreen(),
//         '/login': (context) => LoginScreen(),
//         '/register': (context) => RegisterScreen(),
//         '/home': (context) => HomeScreen(),
//         '/cart': (context) => CartScreen(),
//         '/orders': (context) => OrdersScreen(),
//         '/profile': (context) => ProfileScreen(),
//       },
//     );
//   }
// }




























// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
