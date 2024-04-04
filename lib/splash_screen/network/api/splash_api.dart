import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../../service_helper/api/api_strings.dart';

part 'splash_api.g.dart';

@RestApi(baseUrl: ApiStrings.baseUrlOFMarketing)
abstract class SplashAPi {
  factory SplashAPi(Dio dio) = _SplashAPi;


  @GET(ApiStrings.installApi)
  Future<HttpResponse> getInstallAppStatus(
      @Queries() Map<String, dynamic> queryParameters);


}
