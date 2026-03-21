import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitasora/widgets/app_colors.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text('Menu')),
          ListTile(
            title: Text('home'),
            leading: Icon(Icons.home),
            onTap:(){
            Navigator.pop(context);},
          ),
          ListTile(
            title: Text('Profile'),
            leading: Icon(Icons.account_circle_outlined),
            onTap: (){},
          ),
          ListTile(
            title: Text('Sign out'),
            leading: Icon(Icons.logout),
            onTap: ()async{
              Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),

    );
  }
}
