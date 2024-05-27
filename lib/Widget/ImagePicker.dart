import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }

  UserImagePicker({super.key, required this.onPicked});
  final void Function(File PickedImage) onPicked;
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _imagePicker() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = File(image.path);
    });
    widget.onPicked(_pickedImage!);
  }

  Widget build(context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _imagePicker,
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          icon: Icon(
            Icons.image,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}
