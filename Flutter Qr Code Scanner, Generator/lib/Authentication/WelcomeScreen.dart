import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          children: [
            buildFirstPage(context),
            // buildSecondPage(context),
            buildThirdPage(context),
          ],
        ),
      ),
    );
  }

  Widget buildFirstPage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/firstpage1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
              padding: const EdgeInsets.all(8.0), // Add padding
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Add padding
                child: TextButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSecondPage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/second2.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0), // Add padding
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  child: Text('Back'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Add padding
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  child: Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildThirdPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(70, 239, 235, 250),
      appBar: AppBar(
        title: Text('Welcome Back!'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'svg/white.svg',
              height: 24.0, // Adjust the height as needed
            ),
            onPressed: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SvgPicture.asset(
              'svg/landingPage.svg',
              height: 300.0,
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Login');
              },
              child: Text('Login'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Register');
              },
              child: Text('Register'),
            ),
            Spacer(),
            // Align(
            //   alignment: Alignment.bottomLeft,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0), // Add padding
            //     child: TextButton(
            //       onPressed: () {
            // _pageController.previousPage(
            //   duration: Duration(milliseconds: 500),
            //   curve: Curves.ease,
            //         );
            //       },
            //       child: Text('Back'),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
