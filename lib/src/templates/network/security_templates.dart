String getEncryptionServiceTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final _key = encrypt.Key.fromSecureRandom(32);
  static final _iv = encrypt.IV.fromSecureRandom(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String encryptData(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decryptData(String encryptedText) {
    return _encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: _iv);
  }
}
""";

String getEncryptionInterceptorTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class EncryptionInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null && options.data is String) {
      options.data = EncryptionService.encryptData(options.data);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null && response.data is String) {
      response.data = EncryptionService.decryptData(response.data);
    }
    super.onResponse(response, handler);
  }
}
""";
