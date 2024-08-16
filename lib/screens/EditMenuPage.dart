import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';

import '../reusableWidgets/reusableFunctions.dart';

class EditMenuPage extends StatefulWidget {
  MapEntry<String, dynamic> menuItem;

  EditMenuPage(
      {Key? key,
        required this.menuItem
      }) : super(key: key);

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();


  PlatformFile? _selectedFile;
  UploadTask? uploadTask;

  List category = [];

  String imageName = '';
  String firstCategory = 'Loading...';

  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      imageName = widget.menuItem.value['imageURL'];
      nameController.text = widget.menuItem.value['name'].toString();
      priceController.text = widget.menuItem.value['price'].toString();
      descriptionController.text = widget.menuItem.value['description'].toString();
      categoryController.text = widget.menuItem.value['category'].toString();
      category = await getCategory();

      if (mounted) {
        setState(() {
          category = category;
          firstCategory = widget.menuItem.value['category'].toString();
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
        widget.menuItem.value['imageURL'] = result.files.first.path!;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) return;

    final fileName = imageName;
    final path = 'menu/$fileName.jpeg';
    final file = File(_selectedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});

    final url = await snapshot.ref.getDownloadURL();
    print('Download-Link: $url');

    if (mounted) {
      setState(() {
        widget.menuItem.value['imageURL'] = url;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [Column(
          children:[
            ReusableAppBar(title: "Edit Menu", backButton: true),
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
                  future: getMenuImage(widget.menuItem.value['imageURL']),
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
                  uploadFile();
                  updateMenu(nameController.text, descriptionController.text, firstCategory, double.parse(priceController.text), imageName);
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.update),
                iconSize: MediaQuery.of(context).size.width * 0.05, // Adjust the size as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
