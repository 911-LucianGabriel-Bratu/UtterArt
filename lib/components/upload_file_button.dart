import 'package:flutter/material.dart';

class AudioUploadButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AudioUploadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(60),
        child: const Icon(
          Icons.upload_file,
          color: Colors.black,
          size: 60,
        ),
      ),
    );
  }
}