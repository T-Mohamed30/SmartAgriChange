// Conditional export based on platform
export 'usb_service_mobile.dart'
    if (dart.library.js) 'usb_service_web.dart';
