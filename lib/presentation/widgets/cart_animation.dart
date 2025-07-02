// lib/presentation/widgets/cart_animation.dart

import 'package:flutter/material.dart';

// This is the main function you'll call to start the animation.
void runCartAnimation(
    BuildContext context,
    GlobalKey itemKey,
    GlobalKey cartKey,
    ImageProvider? imageProvider,
    VoidCallback onAnimationComplete,
    ) {
  // Find the position of the item's image and the cart icon.
  final RenderBox itemRenderBox =
  itemKey.currentContext!.findRenderObject() as RenderBox;
  final RenderBox cartRenderBox =
  cartKey.currentContext!.findRenderObject() as RenderBox;

  final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
  final cartPosition = cartRenderBox.localToGlobal(Offset.zero);

  // Create an OverlayEntry to draw the animating widget on top of the UI.
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      // This private widget handles the animation's state and rendering.
      return _AnimatingItem(
        startPosition: itemPosition,
        endPosition: cartPosition,
        imageProvider: imageProvider,
        onComplete: () {
          // When animation is done, remove the overlay and call the final callback.
          overlayEntry.remove();
          onAnimationComplete();
        },
      );
    },
  );

  // Add the overlay to the screen to start the animation.
  Overlay.of(context).insert(overlayEntry);
}

// A private stateful widget to manage the animation itself.
class _AnimatingItem extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final ImageProvider? imageProvider;
  final VoidCallback onComplete;

  const _AnimatingItem({
    required this.startPosition,
    required this.endPosition,
    required this.imageProvider,
    required this.onComplete,
  });

  @override
  _AnimatingItemState createState() => _AnimatingItemState();
}

class _AnimatingItemState extends State<_AnimatingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Create a curved animation for a more dynamic effect.
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Animate the position from the item's location to the cart's location.
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(curve);

    // Start the animation and call the onComplete callback when it's done.
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: 1.0 - _controller.value, // Fade out as it moves
            child: Transform.scale(
              scale: 1.0 - (_controller.value * 0.5), // Shrink as it moves
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: widget.imageProvider != null
                        ? DecorationImage(image: widget.imageProvider!, fit: BoxFit.cover)
                        : null,
                  ),
                  child: widget.imageProvider == null
                      ? const Icon(Icons.shopping_bag, color: Colors.grey)
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}