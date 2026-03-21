/* import 'package:cloud_firestore/cloud_firestore.dart'; // You need to import this for FirebaseFirestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseFirestore.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Ther is no user")));
          return;
        }
        final uid = user.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'phone number': _phoneController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile added successfully')),
        );
        // Form clearing
        _nameController.clear();
        _ageController.clear();
        _phoneController.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Stream<DocumentSnapshot> _getUserData() {
    final user = FirebaseFirestore.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Don't forget to assign the form key
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController, // Add controller
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageController, // Add controller
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an age';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController, // Add controller
                        decoration: const InputDecoration(
                            labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // You might want to add more specific phone number validation
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        // Just pass the function reference
                        child: const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                    stream: _getUserData(), builder: (context, snapshot)){
            if (!snapshot.hasDta || !snapshot.data!.exists ){
            return Text(" No user found");
            }

            return Card(
            child: ListTile(
            title: Text('Name : ${data ['name']}'),
            subtitle: Column(
            children: [
            Text('Age : ${data ['age']}'),
            Text('Phone number : ${data ['phone number']}'),
            ],
            ),
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(onPressed: onPressed(){
            _nameController.text = data ['name'];
            _ageController.text = data ['age'].toString();
            _phoneController.text = data ['phone number'];

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can edit your profile now')));
            }, icon: Icon(Icons.edit)),
            IconButton(onPressed: onPressed(){

              final confirm = await showDialog<bool>(context: context,
            builder: (context)=> AlertDialog(
            title: Text('Delete profile'),
            content: Text('Are you sure you want to delete this profile'),
            actions: [
              TextButton(onPressed: ()=> Navigator.pop(context,false), child: Text('cancel')),
              TextButton(onPressed: ()=> Navigator.pop(context,true), child: Text('Delete')),
            ],
            ));
              if (confirm==true){
                final user = FirebaseAuth.instance.currentUser;
                if (user != null){
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete(),
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile has been deleted')))
            }
            }

            }, icon: Icon(Icons.delete)),
            ],
            ),
            ),
            ),
            }
            }

  )

  ,

  )

  ,

  );
}}


* Firebase aurhentification with the model from the google colab
*
* cloudinary
*
*
*
*
* */