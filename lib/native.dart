import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef RunHelloNative = ffi.Void Function(ffi.Pointer<Utf8> text);
typedef RunHelloDart = void Function(ffi.Pointer<Utf8> text);

class NativeBindings {
  late final RunHelloDart runHello;

  NativeBindings() {
    final dll = ffi.DynamicLibrary.open("FocusAppLibrary.dll");

    runHello = dll.lookupFunction<RunHelloNative, RunHelloDart>(
      "RunHello",
    );
  }

  void callRunHello(String text) {
    final ptr = text.toNativeUtf8();    // Dart string -> C++ const char*
    runHello(ptr);                      //call C++ function
    malloc.free(ptr);                   //free memory
  }
}