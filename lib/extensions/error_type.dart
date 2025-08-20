

import 'package:flutter/cupertino.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/models/enum/error.dart';

extension RequestErrorExtensions on RequestError {
  String localisedMessage(BuildContext context){
    final localisations = AppLocalizations.of(context)!;
    switch(this){

      case RequestError.notFound:
        return localisations.noResults;
      case RequestError.networkError:
        return localisations.networkError;
      case RequestError.locationServicesDisabled:
        return localisations.locationServicesDisabled;
      case RequestError.locationPermissionsDenied:
        return localisations.locationPermissionsDenied;
      case RequestError.locationPermissionsPermanentlyDenied:
        return localisations.locationPermissionsPermanentlyDenied;
      case RequestError.requestTimeout:
        return localisations.timeout;
      case RequestError.none:
        return '';
    }
  }
}