import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/app_models.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  const BannerCarousel({super.key, required this.banners});
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_currentIndex + 1) % widget.banners.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      SizedBox(
        height: 180,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.banners.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (context, index) {
            final b = widget.banners[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(fit: StackFit.expand, children: [
                  CachedNetworkImage(
                    imageUrl: b.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image_rounded, size: 40)),
                  ),
                  if (b.title != null && b.title!.isNotEmpty)
                    Positioned(bottom: 0, left: 0, right: 0, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)])),
                      child: Text(b.title!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    )),
                ]),
              ),
            );
          },
        ),
      ),
      if (widget.banners.length > 1) ...[
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
          widget.banners.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentIndex == i ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _currentIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          ),
        )),
      ],
    ]);
  }
}