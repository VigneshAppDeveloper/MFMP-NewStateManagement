import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class AppGuide extends StatefulWidget {
  const AppGuide({super.key});

  @override
  State<AppGuide> createState() => _AppGuideState();
}

class _AppGuideState extends State<AppGuide> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    const videoUrl = 'https://youtu.be/qmIXl147JCk';
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        useHybridComposition: true, // required for Android
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColor.maincolor,
        progressColors: ProgressBarColors(
          playedColor: AppColor.maincolor,
          handleColor: AppColor.maincolor,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CommonAppBar(title: "App Guide", showBack: true),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Watch this quick guide to learn how to use the MyFoodMyPrice App!",
                    style: Styles.textStyleMedium(context),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Embedded YouTube Player
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}