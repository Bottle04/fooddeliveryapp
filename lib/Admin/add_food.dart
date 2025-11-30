import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/widget_support.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:fooddeliveryapp/service/constant.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> categories = ['Pizza', 'Burger', 'Chinese', 'Mexican'];
  String? selectedCategory;

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? selectedImage;
  String imageUrl = "";
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // ---------------- CLOUDINARY UPLOAD ------------------
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      isUploading = true;
    });

    try {
      /// ⚠️ THAY THẾ BẰNG KEY CLOUDINARY CỦA BẠN
      final cloudinary = Cloudinary.full(
        apiKey: "863528186415452",
        apiSecret: "aLk2u-q2RzaVgEwVIxzPYUn6Vqc",
        cloudName: "dkn8mmvyw",
      );

      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: image.path,
          fileName: "food_${DateTime.now().millisecondsSinceEpoch}",
          resourceType: CloudinaryResourceType.image,
          folder: "food_app",
        ),
      );

      if (response.isSuccessful) {
        setState(() {
          imageUrl = response.secureUrl ?? "";
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      setState(() => isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload error: $e")),
      );
    }
  }
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Add New Product", style: AppWidget.HeadlineTextFeildStyle()),
        backgroundColor: const Color(0xFFececf8),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xffef2b39)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category", style: AppWidget.SimpleTextFeildStyle()),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(hintText: "Select Category"),
              value: selectedCategory,
              items: categories.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Text("Product Name", style: AppWidget.SimpleTextFeildStyle()),
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(hintText: 'e.g., Pepperoni Pizza'),
            ),
            const SizedBox(height: 20),
            Text("Price (\$)", style: AppWidget.SimpleTextFeildStyle()),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'e.g., 15.99'),
            ),
            const SizedBox(height: 20),
            Text("Description", style: AppWidget.SimpleTextFeildStyle()),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'e.g., Delicious with extra cheese...'),
            ),
            const SizedBox(height: 20),
            Text("Product Image", style: AppWidget.SimpleTextFeildStyle()),
            GestureDetector(
              onTap: isUploading ? null : pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : selectedImage == null
                        ? Center(
                            child: Icon(Icons.camera_alt,
                                color: Colors.grey[600], size: 50))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                Image.file(selectedImage!, fit: BoxFit.cover),
                          ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: isUploading
                  ? null
                  : () async {
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please select a category.")),
                        );
                        return;
                      }

                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please fill Product Name and Price.")),
                        );
                        return;
                      }

                      if (selectedImage != null && imageUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Please wait for image upload to complete.")),
                        );
                        return;
                      }

                      Map<String, dynamic> foodInfo = {
                        "Name": nameController.text,
                        "Price": priceController.text,
                        "Description": descriptionController.text,
                        "Image": imageUrl.isEmpty
                            ? "https://via.placeholder.com/150"
                            : imageUrl,
                        "IsAvailable": true,
                        "SearchKey":
                            nameController.text.substring(0, 1).toUpperCase(),
                      };

                      try {
                        await DatabaseMethods()
                            .addFoodItem(foodInfo, selectedCategory!);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${nameController.text} added successfully!")),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error saving product: $e")),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isUploading ? Colors.grey : const Color(0xffef2b39),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text("SAVE PRODUCT",
                      style: AppWidget.boldwhiteTextFeildStyle()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
