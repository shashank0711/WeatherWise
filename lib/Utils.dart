import 'package:flutter/material.dart';

Widget ForecastBlock(time, iconData, tempData){
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(iconData,size: 30),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '$tempData °C',
                style: TextStyle(
                  fontSize: 12,),
              ),
            ),


          ],
        ),
      ),
    ),
  );
}


Widget Additional_info_block(icon, text, value ){
  return Container(
    child: Column(
      children: [
        Icon(
          icon,
          size: 40,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 7),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
          ),
        )
      ],
    ),
  );
}