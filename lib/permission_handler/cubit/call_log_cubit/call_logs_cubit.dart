import 'package:call_log/call_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../api/permission_api.dart';
import '../../network/call_log_modal.dart';
import 'dart:async';
import 'dart:isolate';

part 'call_logs_state.dart';

class CallLogsCubit extends Cubit<CallLogsState> {
  CallLogsCubit() : super(CallLogsInitial());

  static CallLogsCubit get(context) => BlocProvider.of(context);

  final api = PermissionApi(DioApi(isHeader: true).sendRequest);

  Future<void> fetchCallLogsAndPostToAPI() async {
    emit(CallLogLoading());
    PermissionStatus permissionStatus = await Permission.phone.request();

    if (permissionStatus.isGranted) {
      try {
        Iterable<CallLogEntry> callLogEntries = await CallLog.query();
        List<MyCallLogModal> callLogData = [];
        for (var entry in callLogEntries) {
          callLogData.add(MyCallLogModal(
              type: entry.callType.toString(),
              date: entry.timestamp != null ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!).toString() : 'None',
              duration: entry.duration.toString(),
              name: entry.name,
              phone: entry.number));
        }

        var data = {"row_data": callLogData, "num_of_count": callLogData.length, "action_type": "call_logs"};

        final res = await api.postPermissionData(data);
        if (res.response.statusCode == 200) {
          ErrorModal successModal = ErrorModal.fromJson(res.data);
          emit(CallLogLoaded(message: successModal.responseMsg.toString()));
        } else {
          ErrorModal errorModal = ErrorModal.fromJson(res.data);
          emit(CallLogError(errorMessage: errorModal.responseMsg.toString()));
        }
      } on DioError catch (e) {
        emit(CallLogError(errorMessage: handleDioError(e).toString()));
      } catch (e) {
        emit(CallLogError(errorMessage: MyWrittenText.somethingWrong));
      }
    } else {
      emit(CallLogError(errorMessage: 'Permission denied'));
    }
  }

  Future<void> fetchCallLogsAndPostToAPI1() async {
    emit(CallLogLoading());
    PermissionStatus permissionStatus = await Permission.phone.request();
    print("log case 1");

    if (permissionStatus.isGranted) {
      try {
        print("log case 2");
        Iterable<CallLogEntry> callLogEntries = await CallLog.query();
        List<MyCallLogModal> callLogData = [];
        for (var entry in callLogEntries) {
          callLogData.add(MyCallLogModal(
            type: entry.callType.toString(),
            date: entry.timestamp != null ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!).toString() : 'None',
            duration: entry.duration.toString(),
            name: entry.name,
            phone: entry.number,
          ));
        }
        print("log case 3");
        var data = {"row_data": callLogData, "num_of_count": callLogData.length, "action_type": "call_logs"};
        print("log case 4");

        // Create a ReceivePort to receive messages from the isolate
        ReceivePort receivePort = ReceivePort();

        // Spawn the isolate with the _backgroundTask function
        await Isolate.spawn(_backgroundTask, receivePort.sendPort);

        // Get the SendPort from the isolate
        SendPort sendPort = await receivePort.first;
        print("log case 5");

        // final response = Completer<void>();

        // Send data and response Completer to the isolate
        // sendPort.send({'data': data, 'response': response});
        print("log case 6");

        // Wait for the background task to complete
        // await response.future;
        print("log case 7");
      } on DioError catch (e) {
        print("log case 8");
        emit(CallLogError(errorMessage: handleDioError(e).toString()));
      } catch (e) {
        print("log case 9 + $e");
        emit(CallLogError(errorMessage: MyWrittenText.somethingWrong));
      }
    } else {
      print("log case 10");
      emit(CallLogError(errorMessage: 'Permission denied'));
    }
  }

// Background isolate task
  void _backgroundTask(SendPort sendPort) async {
    print("log case 11");
    final ReceivePort receivePort = ReceivePort();
    print("log case 12");

    // Send the SendPort back to the main isolate
    sendPort.send(receivePort.sendPort);
    print("log case 13");

    // Wait for data from the main isolate
    await for (var msg in receivePort) {
      print("log case 14");

      Map<String, dynamic> data = msg['data'];

      try {
        // Perform your background processing here
        print("log case 16");
        final res = await api.postPermissionData(data);
        print("log case 17");

        if (res.response.statusCode == 200) {
          print("log case 18");
          ErrorModal successModal = ErrorModal.fromJson(res.data);
          print("log case 19");
          sendPort.send({'result': 'success', 'message': successModal.responseMsg});
        } else {
          ErrorModal errorModal = ErrorModal.fromJson(res.data);
          sendPort.send({'result': 'error', 'message': errorModal.responseMsg});
        }
      } catch (e) {
        sendPort.send({'result': 'error', 'message': e.toString()});
      }
    }
  }
}
