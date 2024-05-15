part of 'splash_import.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLogged') ?? false;
    final userId = prefs.getInt('userId');
    if (isLoggedIn) {
      // If logged in, navigate to the Home screen
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage(userId: userId!)));
    } else {
      // If not logged in, navigate to the OnBoarding screen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const OnBoard()));
    }
  }

  moveToOnBoard() async {
    await Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const OnBoard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      body: Center(
        child: FadedScaleAnimation(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.mainLogo,
              scale: 4,
              color: Colors.indigo.shade900,
            ),
            const Text(
              'GGNotes',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
