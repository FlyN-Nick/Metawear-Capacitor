import Foundation
import Capacitor
import MetaWear
import MetaWearCpp

/**
    Made by Nicholas Assaderaghi, 2021.
 */
@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    private let implementation = MetawearCapacitor()
    
    private var sensor: MetaWear? = nil
    
    private var accelSignal: OpaquePointer? = nil
    private var gyroSignal: OpaquePointer? = nil
    
    private var accelStr: String = ""
    private var gyroStr: String = ""
    
    private final var accelFilePath = NSHomeDirectory() + "/accel.txt"
    private final var gryoFilePath = NSHomeDirectory() + "/gryo.txt"
    
    private final var accelFileURL = URL(fileURLWithPath: NSHomeDirectory() + "/accel.txt")
    private final var gryoFileURL = URL(fileURLWithPath: NSHomeDirectory() + "/gryo.txt")
    
    // I'll just leave this here for testing.
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func createDataFiles(_ call: CAPPluginCall) {
        FileManager.default.createFile(atPath: self.accelFilePath, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: self.gryoFilePath, contents: nil, attributes: nil)
        call.resolve()
    }
    
    @objc func eraseDataFiles(_ call: CAPPluginCall) {
        var errored = false
        do {
            let text = ""
            try text.write(toFile: accelFilePath, atomically: false, encoding: String.Encoding.utf8)
            try text.write(toFile: gryoFilePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error {
            errored = true
            print(error.localizedDescription)
            call.reject(error.localizedDescription)
        }
        if errored { call.resolve() }
    }
    
    @objc func connect(_ call: CAPPluginCall) {
        self.connect()
        call.resolve()
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        self.sensor!.cancelConnection()
        call.resolve()
    }
    
    @objc func startData(_ call: CAPPluginCall) {
        self.startAccelData()
        self.startGyroData()
        call.resolve()
    }
    
    @objc func stopData(_ call: CAPPluginCall) {
        self.stopAccelData()
        self.stopGyroData()
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
            mySelf.accelStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("accel: " + mySelf.accelStr)
            do {
                try mySelf.accelStr.appendToURL(fileURL: mySelf.accelFileURL)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
     }
    
    func startGyroData() {
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(self.sensor!.board)
        self.gyroSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        mbl_mw_datasignal_subscribe(signal, observer) { observer, data in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue()
            mySelf.gyroStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("gyro: " + mySelf.gyroStr)
            do {
                try mySelf.gyroStr.appendToURL(fileURL: mySelf.gryoFileURL)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func stopAccelData() {
        mbl_mw_acc_stop(self.sensor!.board)
        mbl_mw_acc_disable_acceleration_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.accelSignal!)
    }
    
    func stopGyroData() {
        mbl_mw_gyro_bmi160_stop(self.sensor!.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.gyroSignal!)
    }
}

extension String {
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
 }

extension Data {
  func append(fileURL: URL) throws {
      if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
          defer {
              fileHandle.closeFile()
          }
          fileHandle.seekToEndOfFile()
          fileHandle.write(self)
      }
      else {
          try write(to: fileURL, options: .atomic)
      }
  }
}
