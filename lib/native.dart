import 'dart:ffi' as ffi;
import 'dart:io';

typedef RunHelloNative = ffi.Void Function();
typedef RunHelloDart = void Function();

class NativeBindings {
  late final RunHelloDart runHello;

  NativeBindings() {
    final dll = ffi.DynamicLibrary.open("FocusAppLibrary.dll");

    runHello = dll.lookupFunction<RunHelloNative, RunHelloDart>(
      "RunHello",
    );
  }
}