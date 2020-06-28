import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hack20/cyber_shape.dart';
import 'package:video_player/video_player.dart';

String clipUrl =
    "https://media.rawg.io/media/stories-640/115/11594d211e87a8fd53e7f8bb95cf3306.mp4";

class VideoPreview extends HookWidget {
  const VideoPreview({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialized = useState(false);
    VideoPlayerController videoController = useMemoized(
      () => VideoPlayerController.network(
        clipUrl,
      ),
    );
    useEffect(() {
      videoController.initialize().then((value) => initialized.value = true);
      videoController.setLooping(true);

      return videoController.dispose;
    }, []);

    print(videoController.value?.aspectRatio);
    return initialized.value
        ? GestureDetector(
          onTap: () {
            videoController.value.isPlaying
                ? videoController.pause()
                : videoController.play();
          },
          child: AspectRatio(
            aspectRatio: 16/9,
            child: VideoPlayer(videoController),
          ),
        )
        : SizedBox();
  }
}
