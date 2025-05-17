// import 'package:jaguar_jwt/jaguar_jwt.dart';
//
// bool isTokenExpired(String token) {
//   final parts = token.split('.');
//   if (parts.length != 3) return true; // Not a valid JWT
//
//   final payload = JwtDecoder.decode(token);
//   final exp = payload['exp'];
//   if (exp == null) return true; // No expiration
//
//   final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
//   return expiryDate.isBefore(DateTime.now());
// }
