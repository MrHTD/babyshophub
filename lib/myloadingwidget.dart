import 'package:flutter/material.dart';

class MyLoadingWidget extends StatefulWidget {
  const MyLoadingWidget({Key? key}) : super(key: key);

  @override
  _MyLoadingWidgetState createState() => _MyLoadingWidgetState();
}

class _MyLoadingWidgetState extends State<MyLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  final List<Color> colors = [
    const Color.fromRGBO(172, 146, 235, 1),
    const Color.fromRGBO(255, 118, 174, 1),
    const Color.fromRGBO(87, 213, 236, 1),
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });

    animation = Tween<double>(begin: 0.0, end: colors.length.toDouble())
        .animate(controller);

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(getAnimatedColor()),
        backgroundColor: Colors.transparent,
        strokeWidth: 6.0,
        semanticsLabel: 'Loading',
        semanticsValue: null,
      ),
    );
  }

  Color getAnimatedColor() {
    int index = animation.value.floor() % colors.length;
    int nextIndex = (index + 1) % colors.length;
    double ratio = animation.value - index.toDouble();
    return Color.lerp(colors[index], colors[nextIndex], ratio)!;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyLoadingWidget(),
  ));
}
