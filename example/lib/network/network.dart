import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:example/base/response_model.dart';
import 'package:example/config/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Network {
  static Dio _dio;

  static String get platform {
    return Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : '');
  }

  static Dio get instance => _dio;

  static void setHttpProxy(String hostPort) {
    _initDio(hostPort:hostPort);
  }

  static Future<void> _initDio({String hostPort = ''}) async {
    _dio = Dio(BaseOptions(
      contentType: 'application/json',
//      baseUrl: Config.BASE_URL,
    ));
    _dio.options.receiveTimeout = 5000;
    _dio.options.connectTimeout = 30000;

    if (hostPort.length > 5) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        //这一段是解决安卓https抓包的问题
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return Platform.isAndroid;
        };

        client.findProxy = (uri) {
          //注入代理
          return "PROXY ${hostPort}";
        };
      };
    }
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (Options options) {
          options.headers['Source'] = platform.toLowerCase();
          return options;
        },
        onResponse: (Response res) {
          try {
            print('接口: ${res.request.path}');
            if (res.request.method == "POST") {
              print('参数: ${res.request.data}');
            } else {
              print('参数: ${res.request.queryParameters}');
            }
            print('返回数据: ${res.data}');
            print('\n');
            final data = ResponseModel.fromJSON(res.data);
            return data;
          } catch (e) {
            return res;
          }
        },
        onError: (DioError e) {
          print('\n');
          print(e);
          print('\n');
          print('报错接口: ${e.request.baseUrl}${e.request.path}');
          if (e.request.method == "POST") {
            print('参数: ${e.request.data}');
          } else {
            print('参数: ${e.request.queryParameters}');
          }
          switch (e.type) {
            case DioErrorType.CONNECT_TIMEOUT:
              // Fluttertoast.showToast(msg: '请求超时，请检查网络连接后重试');
              break;
            case DioErrorType.RESPONSE:
              print('response: ${e.response.data}');
              final data = e.response.data;
              if (data != null) {
                Fluttertoast.showToast(
                  msg: data['errorCode'] != null
                      ? '${data['errorCode']} ${data['errorMsg']}'
                      : '请求出现错误',
                );
              }
              break;
            default:
          }
          return e;
        },
      ),
    ]);
  }

  static Future<ResponseModel> get(
    String path, {
    String baseUrl = '',
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    bool isShowToast = false, //是否显示提示框

    void Function(int, int) onReceiveProgress,
  }) async {
    if (_dio == null) {
      await _initDio();
    }
    if (baseUrl.isEmpty) {
      baseUrl = Config.BASE_URL;
    }
    path = baseUrl + path;
    var res;
    try {
      res = await _dio.get<ResponseModel>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      responseHandling(res.data, isShowToast: isShowToast);
    } catch (e) {
      if (isShowToast) {
        Fluttertoast.showToast(
            msg: '网络错误，请检查网络连接后重试', gravity: ToastGravity.CENTER);
      }
    }

    return res.data;
  }

  static Future<ResponseModel> post(
    String path, {
    String baseUrl = '',
    dynamic data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    bool isShowToast = false, //是否显示提示框
    void Function(int, int) onSendProgress,
    void Function(int, int) onReceiveProgress,
  }) async {
    if (_dio == null) {
      await _initDio();
    }
    if (baseUrl.isEmpty) {
      baseUrl = Config.BASE_URL;
    }
    path = baseUrl + Config.BASE_URL;
    var res;
    try {
      res = await _dio.post<ResponseModel>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      responseHandling(res.data, isShowToast: isShowToast);
    } catch (e) {
      if (isShowToast) {
        Fluttertoast.showToast(
            msg: '网络错误，请检查网络连接后重试', gravity: ToastGravity.CENTER);
      }
    }
    return res.data;
  }

  //处理逻辑
  static responseHandling(
    ResponseModel data, {
    bool isShowToast, //是否显示提示框
  }) {
    if (data.code == 1 && data.bizCode != 20000) {
      if (isShowToast) {
        Fluttertoast.showToast(msg: data.bizMsg, gravity: ToastGravity.CENTER);
      }
    } else if (data.code == -1 || data.code == -2) {}
  }
}
