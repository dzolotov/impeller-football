import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/camera.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:flutter_scene/scene.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _controller;

  late AudioPlayer _background;

  @override
  void initState() {
    super.initState();
    _background = AudioPlayer();
    _background.play(
      AssetSource('sounds/background.mp3'),
      mode: PlayerMode.mediaPlayer,
    );
    _background.onPlayerComplete.listen((event) {
      _background.seek(Duration.zero);
      _background.resume();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      lowerBound: 0,
      upperBound: 2 * pi,
    );
    _controller.repeat();
    _controller.addListener(applyPhysics);
  }

  @override
  void dispose() {
    _background.stop();
    super.dispose();
  }

  double positionX = 0.0;
  double positionZ = 4.0;
  double positionY = 0.7;
  double velocityY = 0.0;
  double velocityX = 0.0;
  double velocityZ = 0.0;

  void applyPhysics() {
    positionY -= velocityY * 0.01;
    velocityY += 9.8 * (1 / 60);
    if (positionY < -1) {
      velocityY = -6;
      AudioPlayer().play(
        AssetSource('sounds/bounce.mp3'),
        mode: PlayerMode.lowLatency,
      );
      // velocityY = -velocityY;
    }
    positionX += velocityX * 0.01;
    positionZ -= velocityZ * 0.01;
    if (positionZ < 0.5) {
      final player = AudioPlayer();
      if (positionX.abs() < 1.5 && positionY.abs() < 1) {
        player.play(
          AssetSource('sounds/wow.mp3'),
        );
      } else {
        player.play(
          AssetSource('sounds/fail.mp3'),
        );
      }
      positionZ = 0;
      positionX = 0;
      velocityX = 0;
      velocityZ = 0;
      positionZ = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (velocityZ == 0) {
          velocityX = Random().nextDouble() * 1.5 - 0.75;
          velocityZ = Random().nextDouble() + 1;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, _) => SceneBox(
          camera: Camera(
              fovRadiansY: pi / 4,
              position: Vector3(0, 0, 8),
              target: Vector3.zero(),
              up: Vector3(0, 1, 0)),
          root: Node(
            children: [
              Node.transform(
                transform: Matrix4.compose(
                  Vector3(positionX, positionY, positionZ),
                  Quaternion.axisAngle(Vector3(1, 1, 1), _controller.value),
                  Vector3.all(0.5),
                ),
                children: [
                  Node.asset('models/football.glb'),
                ],
              ),
              Node.transform(
                transform: Matrix4.compose(
                  Vector3(0, -1.9, -3),
                  Quaternion.fromRotation(Matrix3.rotationY(pi)),
                  Vector3.all(0.5),
                ),
                children: [
                  Node.asset('models/gate.glb'),
                ],
              ),
              Node.transform(
                  transform: Matrix4.compose(
                    Vector3(0, -2, 0),
                    Quaternion.identity(),
                    Vector3(2, 0.01, 2),
                  ),
                  children: [
                    Node.asset('models/texturedgrass.glb'),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
