import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "c_editor/folder_bookmark",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "createBookmark":
        guard let path = call.arguments as? String else {
          result(
            FlutterError(
              code: "INVALID_ARGUMENT",
              message: "path is required",
              details: nil
            )
          )
          return
        }
        result(Self.createBookmark(path: path))
      case "resolveBookmark":
        guard let bookmark = call.arguments as? String else {
          result(
            FlutterError(
              code: "INVALID_ARGUMENT",
              message: "bookmark is required",
              details: nil
            )
          )
          return
        }
        result(Self.resolveBookmark(bookmark: bookmark))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func createBookmark(path: String) -> String? {
    let url = URL(fileURLWithPath: path)
    let accessed = url.startAccessingSecurityScopedResource()
    defer {
      if accessed {
        url.stopAccessingSecurityScopedResource()
      }
    }
    do {
      let data = try url.bookmarkData(
        options: .minimalBookmark,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      return data.base64EncodedString()
    } catch {
      return nil
    }
  }

  private static func resolveBookmark(bookmark: String) -> String? {
    guard let data = Data(base64Encoded: bookmark) else {
      return nil
    }
    var isStale = false
    do {
      let url = try URL(
        resolvingBookmarkData: data,
        options: [],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return url.path
    } catch {
      return nil
    }
  }
}
