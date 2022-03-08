import 'package:flutter/material.dart';
import 'dart:math';

class Joystick extends StatefulWidget {
  final double thumbSize, padSize;
  final Widget? thumb, pad;
  final void Function(Offset)? onChange;

  const Joystick({
    Key? key,
    this.thumbSize = 70,
    this.padSize = 200,
    this.thumb,
    this.pad,
    this.onChange,
  }) : super(key: key);

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  late Offset position;
  late Offset center;

  @override
  void initState() {
    super.initState();
    double pos = (widget.padSize + widget.thumbSize) / 2;
    center = Offset(pos, pos);
    position = Offset(pos, pos);
  }

  @override
  Widget build(BuildContext context) {
    //  widget.thumbSize, widget.padSize,
    return GestureDetector(
      onPanUpdate: (details) {
        Offset offset = details.localPosition - center;
        double angle = atan2(offset.dy, offset.dx);
        double distance = min(
            widget.padSize / 2,
            sqrt((pow(offset.dy, 2) +
                pow(offset.dx, 2)))); //avoid distance over 1

        setState(() {
          position = Offset(
                cos(angle) * distance,
                sin(angle) * distance,
              ) +
              center;
        });

        Offset value = (position - center) / widget.padSize * 2;
        value = Offset(value.dx, -value.dy);
        if (widget.onChange != null) widget.onChange!(value);
      },
      onPanEnd: (details) {
        setState(() {
          position = center;
        });
      },
      child: Stack(children: [
        SizedBox(
          height: widget.padSize + widget.thumbSize,
          width: widget.padSize + widget.thumbSize,
          child: widget.pad ??
              Container(
                margin: EdgeInsets.all(widget.thumbSize / 2),
                height: widget.padSize,
                width: widget.padSize,
                decoration: BoxDecoration(
                  color: const Color(0x20ffffff),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x1a000000), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1a000000),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
        ),
        Positioned(
          top: position.dy - widget.thumbSize / 2,
          left: position.dx - widget.thumbSize / 2,
          child: widget.thumb ??
              Container(
                height: widget.thumbSize,
                width: widget.thumbSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
        )
      ]),
    );
  }
}
