import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/image_widgets.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import '../localization/appLanguage.dart';
import '../network/url_manager.dart';
import '../storage/local_storage_manager.dart';

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
             borderRadius: BorderRadius.circular(10),
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

   static Widget profileIcon({
     required BuildContext context,
     double radius = 18,
     VoidCallback? onTap,
     EdgeInsets? padding,
   }) {
     return Padding(
       padding: padding ?? const EdgeInsets.only(right: 16.0, left: 16.0),
       child: FutureBuilder<String?>(
         future: _loadProfilePictureUrl(),
         builder: (context, snapshot) {
           String? profilePictureUrl = snapshot.data;

           // Check if we have a valid URL
           final bool hasValidUrl = profilePictureUrl != null &&
               profilePictureUrl.isNotEmpty;

           return GestureDetector(
             onTap: onTap,
             child: CircleAvatar(
               radius: radius,
               backgroundColor: Colors.grey[300],
               child: hasValidUrl
                   ? ClipOval(
                 child: Image.network(
                   _getFullImageUrl(profilePictureUrl!),
                   width: radius * 2,
                   height: radius * 2,
                   fit: BoxFit.cover,
                   errorBuilder: (context, error, stackTrace) {
                     // Show default icon if image fails to load
                     return Icon(
                       Icons.person,
                       size: radius * 0.6,
                       color: Colors.grey,
                     );
                   },
                   loadingBuilder: (context, child, loadingProgress) {
                     if (loadingProgress == null) return child;
                     // Show loading indicator while image loads
                     return Center(
                       child: CircularProgressIndicator(
                         value: loadingProgress.expectedTotalBytes != null
                             ? loadingProgress.cumulativeBytesLoaded /
                             loadingProgress.expectedTotalBytes!
                             : null,
                         strokeWidth: 2,
                         color: Colors.grey,
                       ),
                     );
                   },
                 ),
               )
                   : Icon(
                 Icons.person,
                 size: radius * 0.6,
                 color: Colors.grey,
               ),
             ),
           );
         },
       ),
     );
   }

   /// Load profile picture URL from local storage
   static Future<String?> _loadProfilePictureUrl() async {
     try {
       final storage = await LocalStorageManager.getInstance();
       return storage.getString(LocalStorageManager.keyProfilePicture);
     } catch (e) {
       return null;
     }
   }

   /// Get full image URL by combining base URL with image path
   static String _getFullImageUrl(String imageUrl) {
     // Handle image URL - remove leading slash if present to avoid double slashes
     final cleanUrl = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
     return UrlManager.imageBaseUrl + cleanUrl;
   }

}