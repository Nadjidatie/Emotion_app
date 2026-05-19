import 'package:flutter/material.dart';

  enum Sexe {
    homme,
    femme,
    autre,
  }

class ProfilPhotoDefaut extends StatelessWidget {
  const ProfilPhotoDefaut({super.key, required this.genre});

  final Sexe genre;


  @override
  Widget build(BuildContext context) {
    String getImageUrl;
    switch (genre) {
      case Sexe.homme:
        getImageUrl = "https://img.magnific.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4857.jpg";
        break;
      case Sexe.femme:
        getImageUrl = "https://img.magnific.com/premium-zdjecie/mloda-usmiechnieta-kobieta-ann-avatar-3d-wektorowe-osoby-ilustracja-postaci-w-minimalistycznym-stylu-kreskowki_1240525-12695.jpg";
        break;
      case Sexe.autre:
        getImageUrl = "https://img.magnific.com/premium-vector/silver-membership-icon-default-avatar-profile-icon-membership-icon-social-media-user-image-vector-illustration_561158-4195.jpg";
        break;
    }
    return Image.network(getImageUrl);
  }
}