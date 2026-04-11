import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef RunStartNative = ffi.Void Function(ffi.Pointer<Utf8> text);
typedef RunStartDart = void Function(ffi.Pointer<Utf8> text);

typedef RunMiddleNative = ffi.Void Function(ffi.Pointer<Utf8> text);
typedef RunMiddleDart = void Function(ffi.Pointer<Utf8> text);

typedef RunEndNative = ffi.Void Function(ffi.Pointer<Utf8> text);
typedef RunEndDart = void Function(ffi.Pointer<Utf8> text);

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

  void callRunStart(String text) {
    final ptr = text.toNativeUtf8();    // Dart string -> C++ const char*
    RunStart(ptr);                      //call C++ function
    malloc.free(ptr);                   //free memory
  }
  void callRunMiddle(String text) {
    final ptr = text.toNativeUtf8();    // Dart string -> C++ const char*
    RunMiddle(ptr);                      //call C++ function
    malloc.free(ptr);                   //free memory
  }
  void callRunEnd(String text) {
    final ptr = text.toNativeUtf8();    // Dart string -> C++ const char*
    RunEnd(ptr);                      //call C++ function
    malloc.free(ptr);                   //free memory
  }

}