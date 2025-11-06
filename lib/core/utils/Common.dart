import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/image_widgets.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import '../localization/appLanguage.dart';

class Common{

   static Widget languageIcons({required BuildContext context,required AppLanguage appLanguage,required Function onLanguageChange,}){
     return  Padding(
       padding: const EdgeInsets.only(right: 8.0),
       child: Container(
         decoration: BoxDecoration(
           color:  appLanguage.appLocal.languageCode == 'ar' ? ColorPalette.colorGreen : ColorPalette.primary,
           borderRadius: BorderRadius.circular(10),
         ),
         child: Material(
           color: Colors.transparent,
           child: InkWell(
             borderRadius: BorderRadius.circular(20),
             onTap: () async {
               FocusScope.of(context).unfocus();
               // Toggle between English and Arabic
               final currentLanguage = appLanguage.appLocal.languageCode;
               if (currentLanguage == 'en') {
                 // Change to Arabic
                 await appLanguage.changeLanguage(const Locale('ar'));
               } else {
                 // Change to English
                 await appLanguage.changeLanguage(const Locale('en'));
               }
               onLanguageChange();
             },
             child: Padding(
               padding: const EdgeInsets.symmetric(
                 horizontal: 12,
                 vertical: 6,
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   BaseImage(source: ImageSource.asset,assetPath: ImageUtilsPath.icLanguage,),
                   const SizedBox(width: 6),
                   Text(
                     appLanguage.appLocal.languageCode == 'ar' ? 'AR' : 'EN',
                     style: const TextStyle(
                       fontFamily: 'Montserrat',
                       fontSize: 14,
                       fontWeight: FontWeight.w700,
                       color: Colors.white,
                     ),
                   ),
                 ],
               ),
             ),
           ),
         ),
       ),
     );
   }
}