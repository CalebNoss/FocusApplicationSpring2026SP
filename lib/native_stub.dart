/// Web and other platforms without FFI: native DLL calls are no-ops.
class NativeBindings {
  NativeBindings();

  void callRunStart() {}

  void callRunMiddle() {}

  void callRunEnd() {}
}
