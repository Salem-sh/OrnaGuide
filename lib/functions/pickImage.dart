// image_utils.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<void> pickImage({
  required ImageSource source,
  required Function(Function()) setState,
  required void Function(File) onImagePicked,
}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    final image = File(pickedFile.path);
    setState(() {
      onImagePicked(image); // Update parent widget's state
    });
  }
}