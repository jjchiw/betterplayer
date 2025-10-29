import 'package:better_player/better_player.dart';
import 'package:better_player_example/constants.dart';
import 'package:better_player_example/utils.dart';
import 'package:flutter/material.dart';

class ArtPlayerPage extends StatefulWidget {
  @override
  _ArtPlayerPage createState() => _ArtPlayerPage();
}

class _ArtPlayerPage extends State<ArtPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Art player"),
      ),
      body: Column(
        children: [
          FutureBuilder<String>(
            future: Utils.getFileUrl(Constants.fileTestVideoEncryptUrl),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                return ArtPlayer(
                  introVideo: snapshot.data!,
                  loopVideo: snapshot.data!,
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }
}

class ArtPlayer extends StatefulWidget {
  const ArtPlayer({
    Key? key,
    this.introVideo,
    required this.loopVideo,
  }) : super(key: key);

  final String? introVideo;
  final String loopVideo;

  @override
  State<ArtPlayer> createState() => _ArtPlayerState();
}

class _ArtPlayerState extends State<ArtPlayer> {
  late BetterPlayerController _introPlayerController;
  late BetterPlayerController _loopPlayerController;
  late bool _introShown;
  bool _overlayVisible = true;

  @override
  void initState() {
    print(widget.introVideo);
    _introShown = widget.introVideo == null;

    BetterPlayerControlsConfiguration controlsConfiguration =
        BetterPlayerControlsConfiguration(
      showControls: false,
    );
    Widget placeholder = Container(
      color: Colors.white,
    );

    _introPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDispose: true,
        expandToFill: true,
        aspectRatio: 1,
        fit: BoxFit.fill,
        showPlaceholderUntilPlay: true,
        autoPlay: widget.introVideo != null,
        looping: false,
        placeholder: placeholder,
        controlsConfiguration: controlsConfiguration,
      ),
    );
    _loopPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDispose: true,
        expandToFill: true,
        aspectRatio: 1,
        fit: BoxFit.fill,
        autoPlay: widget.introVideo == null,
        looping: true,
        placeholder: placeholder,
        controlsConfiguration: controlsConfiguration,
      ),
    );

    if (widget.introVideo != null) {
      BetterPlayerDataSource introSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file, widget.introVideo!);
      _introPlayerController.setupDataSource(introSource);
      _introPlayerController.addEventsListener(_handleIntroEvents);
    }

    BetterPlayerDataSource loopSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file, widget.loopVideo);

    _loopPlayerController.setupDataSource(loopSource);
    _loopPlayerController.addEventsListener(_handleLoopEvents);

    super.initState();
  }

  void _handleIntroEvents(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() {
        _overlayVisible = false;
      });
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      setState(() {
        _introShown = true;
      });
      _loopPlayerController.play();
    }
  }

  void _handleLoopEvents(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() {
        _overlayVisible = false;
      });
    }
  }

  @override
  void dispose() {
    if (widget.introVideo != null) {
      _introPlayerController.removeEventsListener(_handleIntroEvents);
    }
    _introPlayerController.dispose();
    _loopPlayerController.dispose();
    _loopPlayerController.removeEventsListener(_handleLoopEvents);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wMask = Container(
      height: 10,
      color: Colors.white,
    );

    final vMask = Container(
      width: 10,
      color: Colors.white,
    );
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.introVideo != null)
              BetterPlayer(controller: _introPlayerController),
            Opacity(
              opacity: _introShown ? 1 : 0,
              child: BetterPlayer(controller: _loopPlayerController),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -5,
              child: wMask,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -5,
              child: wMask,
            ),
            Positioned(
              left: -5,
              top: 0,
              bottom: 0,
              child: vMask,
            ),
            Positioned(
              right: -5,
              top: 0,
              bottom: 0,
              child: vMask,
            ),
            Opacity(
              child: Container(color: Colors.white),
              opacity: _overlayVisible ? 1 : 0,
            ),
          ],
        ),
      ),
    );
  }
}
