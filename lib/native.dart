import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef RunStartNative = ffi.Void Function();
typedef RunStartDart = void Function();

typedef RunMiddleNative = ffi.Void Function();
typedef RunMiddleDart = void Function();

typedef RunEndNative = ffi.Void Function();
typedef RunEndDart = void Function();

class NativeBindings {
  late final RunStartDart RunStart;
  late final RunMiddleDart RunMiddle;
  late final RunEndDart RunEnd;

  NativeBindings() {
    final dll = ffi.DynamicLibrary.open("FocusAppLibrary.dll");

    RunStart = dll.lookupFunction<RunStartNative, RunStartDart>(
      "RunStart",
    );

    RunEnd = dll.lookupFunction<RunEndNative, RunEndDart>(
      "RunEnd",
    );

    RunMiddle = dll.lookupFunction<RunMiddleNative, RunMiddleDart>(
      "RunMiddle",
    );
  }

  void callRunStart() {
    RunStart();                      //call C++ function
  }
  void callRunMiddle() {
    RunMiddle();                      //call C++ function
  }
  void callRunEnd() {
    RunEnd();                      //call C++ function
  }

}