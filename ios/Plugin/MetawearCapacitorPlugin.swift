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
    private var gyroSignal: OpaquePointer? = nil
    
    private var accelData: [MblMwCartesianFloat] = []
    private var gryoData: [MblMwCartesianFloat] = []

    // I'll just leave this here for testing.
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func connect(_ call: CAPPluginCall) {
        self.connect()
        call.resolve()
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        self.sensor!.cancelConnection()
        call.resolve()
    }
    
    @objc func startAccelData(_ call: CAPPluginCall) {
        self.startAccelData()
        call.resolve()
    }
    
    @objc func startGyroData(_ call: CAPPluginCall) {
        self.startGyroData()
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
        let signal = mbl_mw_acc_get_acceleration_data_signal(self.sensor!.board)
        self.accelSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        mbl_mw_datasignal_subscribe(signal, observer) { (observer, data) in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue()
            mySelf.accelData.append(obj)
            print(obj)
        }
        
        mbl_mw_acc_enable_acceleration_sampling(self.sensor!.board)
        mbl_mw_acc_start(self.sensor!.board)
     }
    
    func startGyroData() {
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(self.sensor!.board)
        self.gyroSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        mbl_mw_datasignal_subscribe(signal, observer) { observer, data in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue()
            mySelf.gryoData.append(obj)
            print(obj)
        }
    }
}
