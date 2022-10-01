import 'dart:io';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService _instance = CloudinaryService._();

  static CloudinaryService get instance => _instance;

  Cloudinary cloudinary = Cloudinary.full(
    apiKey: dotenv.env['CLOUDINARY_API_KEY']!,
    apiSecret: dotenv.env['CLOUDINARY_SECRET']!,
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!,
  );

  Future<String> uploadImage(String imagePath, String folder) async {
    final res = await cloudinary.uploadResource(CloudinaryUploadResource(
      uploadPreset: 'expense_tracker',
      filePath: imagePath,
      folder: folder,
      fileBytes: File(imagePath).readAsBytesSync(),
    ),);
    if (res.isSuccessful){
      return res.publicId!;
    } else {
      return '';
    }
  }
}
