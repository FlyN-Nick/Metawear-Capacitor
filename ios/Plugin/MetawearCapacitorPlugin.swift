import Foundation
import Capacitor
import MetaWear
import MetaWearCpp

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    private let implementation = MetawearCapacitor()
    private var sensor: MetaWear? = nil
    private var accelSignal: OpaquePointer? = nil
    private var context: UnsafeMutableRawPointer? = nil

    // I'll just leave this here for testing.
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        self.sensor!.cancelConnection()
        call.resolve()
    }
    
    @objc func connect(_ call: CAPPluginCall) {
        self.connect()
        call.resolve()
    }
    
    func connect() {
        if sensor != nil { return }
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            // We found a MetaWear board, see if it is close
            if device.rssi > -50 {
                // Hooray! We found a MetaWear board, so stop scanning for more
                MetaWearScanner.shared.stopScan()
                // Connect to the board we found
                device.connectAndSetup().continueWith { t in
                    if let error = t.error {
                        // Sorry we couldn't connect
                        print(error)
                        self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                    } else {
                        self.sensor = device // so we can use it in the future
                        self.notifyListeners("successfulConnection", data: nil)
                        
                        // Hooray! We connected to a MetaWear board, so flash its LED!
                        var pattern = MblMwLedPattern()
                        mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                        mbl_mw_led_stop_and_clear(device.board)
                        mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_GREEN)
                        mbl_mw_led_play(device.board)
                    }
                }
            }
        }
    }
    
    func startAccelData() {
        //mbl_mw_acc_bosch_set_range(self.sensor!.board, MBL_MW_ACC_BOSCH_RANGE_2G)
        //mbl_mw_acc_set_odr(self.sensor!.board, 25.0)
        //mbl_mw_acc_bosch_write_acceleration_config(self.sensor!.board)
        //let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(self.sensor!.board)!
        let signal = mbl_mw_acc_get_acceleration_data_signal(self.sensor!.board)
        self.accelSignal = signal
        
        mbl_mw_datasignal_subscribe(signal, self.context) { (context, data) in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            print(obj)
        }
        
        mbl_mw_acc_enable_acceleration_sampling(self.sensor!.board)
        mbl_mw_acc_start(self.sensor!.board)
     }
    
    func startGyroData() {
        //let signal = mbl_mw_gyro
        //mbl_mw_acc_
        //mbl_mw_gyro
    }
}
