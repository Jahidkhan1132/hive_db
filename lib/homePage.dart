import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_db/homePageProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Uint8List? _imageBytes;

  void showImagePicker() async {
    final imagePicker = ImagePicker();
    final picker = await imagePicker.pickImage(source: ImageSource.gallery);

    if (picker != null) {
      final File imageFile = File(picker.path);
      _imageBytes = await imageFile.readAsBytes();
      setState(() {}); // Update the UI to reflect the selected image
    } else {
      print('Image picker canceled');
    }
  }

  showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<HomePageProvider>(context, listen: false).deleteData(index);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  showEditDialog(BuildContext context, int index, User user) {
    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Edit User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: showImagePicker,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                      child: _imageBytes == null ? const Icon(Icons.add_a_photo) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 25,),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String name = nameController.text;
                  String email = emailController.text;
                  Provider.of<HomePageProvider>(context, listen: false).updateData(index, name, email, _imageBytes);
                  Navigator.of(context).pop();
                  nameController.clear();
                  emailController.clear();
                  _imageBytes = null;
                },
                child: const Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Database', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: Provider.of<HomePageProvider>(context, listen: false).getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Consumer<HomePageProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return Card(
                      child: GestureDetector(
                        onLongPress: () {
                          showDeleteConfirmationDialog(context, index);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.image != null ? MemoryImage(user.image!) : null,
                          ),
                          title: Text(user.name ?? ''),
                          subtitle: Text(user.email ?? ''),
                          trailing: GestureDetector(
                            onTap: () {
                              showEditDialog(context, index, user);
                            },
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            isScrollControlled: true,
            builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Add new item', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: showImagePicker,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                            child: _imageBytes == null ? const Icon(Icons.add_a_photo): null,
                          ),
                        ),
                        const SizedBox(height: 25,),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        MaterialButton(
                          onPressed: () async {
                            String name = nameController.text;
                            String email = emailController.text;
                            Provider.of<HomePageProvider>(context, listen: false).insertData(name, email, _imageBytes);
                            Navigator.of(context).pop();
                            nameController.clear();
                            emailController.clear();
                            _imageBytes = null;
                          },
                          color: Colors.blue,
                          minWidth: double.infinity,
                          child: const Text('Submit', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
