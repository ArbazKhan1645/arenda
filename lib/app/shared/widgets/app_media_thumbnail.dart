import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Detects whether a URL is a video by extension.
bool isVideoUrl(String url) {
  final lower = url.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.webm') ||
      lower.endsWith('.m3u8') ||
      lower.contains('/video/') ||
      lower.contains('video=true');
}

/// Shows an image or auto-detected video thumbnail.
/// For videos it shows a static poster with a play button overlay.
/// Tapping opens a full-screen inline player.
class AppMediaThumbnail extends StatelessWidget {
  const AppMediaThumbnail({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (isVideoUrl(url)) {
      return _VideoThumbnail(
        url: url,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      );
    }
    // Image fallback
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _ErrorPlaceholder(width: width, height: height),
      ),
    );
  }
}

// ── Video Thumbnail with play button ─────────────────────────────────────────

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPlayer(context),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            // Dark background as poster
            Container(
              width: width,
              height: height,
              color: AppColors.textPrimary,
              child: Center(
                child: Icon(
                  PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
                  size: 36,
                  color: Colors.white38,
                ),
              ),
            ),
            // Play button overlay
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIcons.play(PhosphorIconsStyle.fill),
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Video badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.video(PhosphorIconsStyle.fill),
                        size: 10, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text('Vidéo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => _FullScreenVideoPlayer(url: url),
    );
  }
}

// ── Full screen video player (bottom sheet) ───────────────────────────────────

class _FullScreenVideoPlayer extends StatefulWidget {
  const _FullScreenVideoPlayer({required this.url});
  final String url;

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.play();
        }
      }).catchError((_) {
        if (mounted) setState(() => _error = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: SizedBox(
        height: screenH,
        child: Stack(
          children: [
            Center(
              child: _error
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIcons.warningCircle(),
                            size: 48, color: Colors.white54),
                        const SizedBox(height: 12),
                        const Text('Impossible de charger la vidéo',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    )
                  : !_initialized
                      ? const CircularProgressIndicator(color: Colors.white)
                      : GestureDetector(
                          onTap: () => _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play(),
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
            ),
            // Close button
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(PhosphorIcons.x(), size: 18, color: Colors.white),
                ),
              ),
            ),
            // Play/pause controls
            if (_initialized)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (_, value, _) => IconButton(
                        icon: Icon(
                          value.isPlaying
                              ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                              : PhosphorIcons.play(PhosphorIconsStyle.fill),
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () => value.isPlaying
                            ? _controller.pause()
                            : _controller.play(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Error placeholder ─────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({this.width, this.height});
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: Center(
        child: Icon(PhosphorIcons.image(), size: 32, color: AppColors.textTertiary),
      ),
    );
  }
}
