# sample3d

Simple demo for Impeller Scene (Real 3D)

To run you must build Flutter engine with flags:

1. Create .gclient file
```
solutions = [
  {
    "managed": False,
    "name": "src/flutter",
    "url": "git@github.com:flutter/engine.git",
    "custom_deps": {},
    "deps_file": "DEPS",
    "safesync_url": "",
  },
]
```
2. Clone depot_tools (https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)
3. Add depot_tools to PATH (echo PATH=`pwd`/depot_tools:$PATH)
4. Clone flutter engine: `gclient sync`
5. Switch to src directory: `cd src`
6. Generate build scripts for host and iOS simulator images:
```
# M1/M2 simulator
./flutter/tools/gn --enable-impeller-3d --no-lto --ios --no-goma --simulator  --simulator-cpu=arm64 --unoptimized
# or Intel-based simulator
./flutter/tools/gn --enable-impeller-3d --no-lto --ios --no-goma --simulator  --simulator-cpu=x64 --unoptimized
# or real iOS device
./flutter/tools/gn --enable-impeller-3d --no-lto --ios --no-goma --unoptimized
# Host tools (including sky_engine)
./flutter/tools/gn --enable-impeller-3d --no-lto --no-goma --unoptimized
# compile
ninja -C out/host_debug_unopt
ninja -C out/ios_debug_sim_unopt
ninja -C out/ios_debug_sim_unopt_arm64
```
7. Copy experiments to sky_engine dir:
```
cp flutter/lib/ui/experiments/scene.dart out/host_debug_unopt/gen/dart-pkg/sky_engine/lib/ui
cp flutter/lib/ui/experiments/gpu.dart out/host_debug_unopt/gen/dart-pkg/sky_engine/lib/ui
echo "part 'gpu.dart'" >>out/host_debug_unopt/gen/dart-pkg/sky_engine/lib/ui/ui.dart
echo "part 'scene.dart'" >>out/host_debug_unopt/gen/dart-pkg/sky_engine/lib/ui/ui.dart
```
8. Toggle to the master channel of the Flutter Framework (`flutter channel master`)
9. Add path to patched sky_engine to the pubspec.yaml:
```
dependency_overrides:
  sky_engine:
    path: /path/to/src/out/host_debug_unopt/gen/dart-pkg/sky_engine
```
10. Run the application with custom engine:
```
# for X64 simulator
flutter run --local-engine ios_debug_sim_unopt --local-engine-src-path /path/to/src
# for M1/M2 simulator
flutter run --local-engine ios_debug_sim_unopt --local-engine-src-path /path/to/src
# for real iOS device
flutter run --local-engine ios_debug_unopt --local-engine-src-path /path/to/src
