import Foundation
import Capacitor
import MetaWear
import MetaWear

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    private let implementation = MetawearCapacitor()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
}
