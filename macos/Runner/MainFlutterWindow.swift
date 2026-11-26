import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    #if DEBUG
    self.title = "Venera-PC-Dev"
    #else
    self.title = "Venera-PC"
    #endif

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
