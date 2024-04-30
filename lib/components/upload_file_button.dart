import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioUploadButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AudioUploadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}