import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/image_widgets.dart';
import '../components/language_dialog.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import '../localization/appLanguage.dart';
import '../localization/appLocalization.dart';

class Common{

   static Widget languageIcons({required BuildContext context,required AppLanguage appLanguage,required Function onLanguageChange,}){
     return  Padding(
       padding: const EdgeInsets.only(right: 8.0),
       child: Container(
         decoration: BoxDecoration(
           color:  appLanguage.appLocal.languageCode == 'ar' ? ColorPalette.colorGreen : ColorPalette.primary,
           borderRadius: BorderRadius.circular(5),
         ),
         child: Material(
           color: Colors.transparent,
           child: InkWell(
             borderRadius: BorderRadius.circular(20),
             onTap: () async {
               FocusScope.of(context).unfocus();
               final languageChanged = await showLanguageDialog(context);
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
                       fontWeight: FontWeight.w600,
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