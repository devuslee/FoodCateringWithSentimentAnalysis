import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';

import '../reusableWidgets/reusableFunctions.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();


  PlatformFile? _selectedFile;
  UploadTask? uploadTask;

  List category = [];

  int counter = 0;

  String firstCategory = 'Loading...';
  String menuImage = '';
  String defaultImageDownload = "";
  String menuName = '';

  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      category = await getCategory();
      counter = await getMenuCounter();
      menuImage = "food_$counter";
      print("Menu Image: ${menuImage}"); // food_1
      menuName = "food_$counter";

      defaultImageDownload = await getMenuImage("blank_menu");

      if (mounted) {
        setState(() {
          category = category;
          firstCategory = category[0];
          defaultImageDownload = defaultImageDownload;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    if (mounted) {
      setState(() {
        _selectedFile = result.files.first;
        menuName = result.files.first.path!;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) return;

    // Assuming that the key is 'food_1', use it as the filename
    final fileName = menuImage;
    final path = 'menu/$fileName.jpeg';
    final file = File(_selectedFile!.path!);

    // Reference to the file location in Firebase Storage
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    // Wait for the upload to complete
    final snapshot = await uploadTask!.whenComplete(() {});

    // Get the download URL of the uploaded file
    final url = await snapshot.ref.getDownloadURL();
    print('Download-Link: $url');

    if (mounted) {
      setState(() {
        menuName = url;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
            children:[
              ReusableAppBar(title: "Add Menu", backButton: true),
              SizedBox(height: MediaQuery.of(context).size.width * 0.01),
              Stack(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: _selectedFile != null
                        ? Image.file(
                      File(_selectedFile!.path!),
                      fit: BoxFit.cover,
                    )
                        :
                    FutureBuilder(
                      future: getMenuImage("blank_menu"),
                      builder: (context, snapshot) {
                        return  CachedNetworkImage(
                          imageUrl: snapshot.data.toString(),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Text('Error: $error'),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: selectFile,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReusableTextField(
                  labelText: "Name",
                  controller: nameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
                  controller: descriptionController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: priceController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                          value: firstCategory,
                          items: category.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                          onChanged: (value) {
                            setState(() {
                              firstCategory = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
                    ),
          ),
          Positioned(
            bottom: 16,  // Adjust the padding as needed
            right: 16,   // Adjust the padding as needed
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: IconButton(
                onPressed: () {
                  if (_selectedFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an image'),
                      ),
                    );
                    return;
                  }
                  uploadFile();
                  addMenu(nameController.text, descriptionController.text, firstCategory, double.parse(priceController.text), menuImage);
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.add),
                iconSize: MediaQuery.of(context).size.width * 0.05, // Adjust the size as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
