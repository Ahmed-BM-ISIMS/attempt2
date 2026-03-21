import 'package:vitasora/widgets/app_colors.dart';
import 'package:flutter/material.dart';

Widget authHeader({required String Title, required String Subtitle}) {
  return Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.seconndary]),
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(85), bottomRight: Radius.circular(85)),

    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(Title,style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,letterSpacing: 2, color: Colors.white),),
        Text(Subtitle,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 2, color: Colors.white),),
      ],
    ),
  );
}
