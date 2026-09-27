import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/material_ui.dart';

const double _kBannerHeight = 184;

class UserProfileBanner extends StatelessWidget {
  const UserProfileBanner({
    required this.bannerUrl,
    required this.bannerColor,
    this.userId,
    this.height = _kBannerHeight,
    super.key,
  });

  final String? bannerUrl;
  final String? userId;
  final Color bannerColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? rawUrl = bannerUrl;
    final String? resolvedUrl = (rawUrl == null || rawUrl.isEmpty)
        ? null
        : (rawUrl.startsWith('http://') ||
                rawUrl.startsWith('https://') ||
                rawUrl.startsWith('data:') ||
                rawUrl.startsWith('blob:'))
            ? rawUrl
            : (userId != null && userId!.isNotEmpty)
                ? FluxerMediaUrl.userBanner(
                    userId: userId!,
                    hash: rawUrl,
                    animated: true,
                  )
                : rawUrl;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: resolvedUrl != null
          ? CachedNetworkImage(
              key: ValueKey(resolvedUrl),
              imageUrl: resolvedUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: bannerColor),
            )
          : ColoredBox(color: bannerColor),
    );
  }
}
