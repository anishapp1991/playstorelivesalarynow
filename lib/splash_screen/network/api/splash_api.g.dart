// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_api.dart';

class _SplashAPi implements SplashAPi {
  _SplashAPi(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'https://tracking.icubeswire.co/';
  }

  final Dio _dio;

  String? baseUrl;


  @override
  Future<HttpResponse<dynamic>> getInstallAppStatus(
      Map<String, dynamic> queryParameters) async {
    const _extra = <String, dynamic>{};
    final _queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    _queryParameters.addAll(queryParameters);
    final _result =
    await _dio.fetch(_setStreamType<HttpResponse<dynamic>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
      _dio.options,
      'aff_a?',
      queryParameters: _queryParameters,
      data: _data,
    )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data;
    final httpResponse = HttpResponse(value, _result);
    return httpResponse;
  }



  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
