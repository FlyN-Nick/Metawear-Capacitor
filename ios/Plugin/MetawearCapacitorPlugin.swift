import Foundation
import Capacitor
import MetaWear
import MetaWearCpp

/**
    Made by Nicholas Assaderaghi, 2021.
 */
@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    
    private var sensor: MetaWear? = nil
    
    private var accelSignal: OpaquePointer? = nil
    private var gyroSignal: OpaquePointer? = nil
    
    private var accelStr: String = ""
    private var gyroStr: String = ""
    
    private final var accelFilePath = NSHomeDirectory() + "/accel.txt"
    private final var gryoFilePath = NSHomeDirectory() + "/gryo.txt"
    
    private final var dataFolderPath = NSHomeDirectory()
    
    private final var accelFileURL = URL(fileURLWithPath: NSHomeDirectory() + "/accel.txt")
    private final var gryoFileURL = URL(fileURLWithPath: NSHomeDirectory() + "/gryo.txt")
    
    private var accelDataReceived = false
    private var gryoDataReceived = false
    
    
    @objc func createDataFiles(_ call: CAPPluginCall) {
        //NSSearchPathForDirectoriesInDomains()
        
        // this currently is unsuccessful
        var unsuccessful = !FileManager.default.createFile(atPath: self.accelFilePath, contents: nil, attributes: nil)
        unsuccessful = !FileManager.default.createFile(atPath: self.gryoFilePath, contents: nil, attributes: nil) ||  unsuccessful
        print("Swift: success of creating data files:")
        print(!unsuccessful)
        
        // this successfully creates the directory
        do {
            print("Swift: trying to create data directory.")
            try FileManager.default.createDirectory(atPath: dataFolderPath, withIntermediateDirectories: true)
        }
        catch let error {
            print("Swift: Error while trying to create directory: ")
            print(error.localizedDescription)
        }
        
        // this says we don't have the permission to save the file in the folder
        do {
            let data = "".data(using: String.Encoding.utf8)
            print("Swift: data:")
            print(data as Any)
            try data!.write(to: self.gryoFileURL)
            try data!.write(to: self.accelFileURL)
        }
        catch let error {
            print("Swift: Error while trying to write to files: ")
            print(error.localizedDescription)
        }
        
//        // this tries to write to system, unsuccessfully of course
//        do {
//            let data = "test".data(using: String.Encoding.utf8)
//            print("Swift: data:")
//            print(data as Any)
//            try data!.write(to: URL(fileURLWithPath: "/gryo.txt"))
//            try data!.write(to: URL(fileURLWithPath: "/accel.txt"))
//        }
//        catch let error {
//            print("Swift: Error while hail mary: ")
//            print(error.localizedDescription)
//        }
        
        call.resolve(["successful": !unsuccessful])
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
            print("Swift: Error while erasing data files: ")
            print(error.localizedDescription)
            call.reject(error.localizedDescription)
        }
        if !errored { call.resolve() }
    }
    
    @objc func connect(_ call: CAPPluginCall) {
        print("Swift: Connect called.")
        self.connect()
        call.resolve()
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        print("Swift: Disconnect called.")
        self.sensor!.cancelConnection()
        call.resolve()
    }
    
    @objc func startData(_ call: CAPPluginCall) {
        print("Swift: StartData called.")
        self.startAccelData()
        self.startGyroData()
        call.resolve()
    }
    
    @objc func stopData(_ call: CAPPluginCall) {
        print("Swift: StopData called.")
        self.stopAccelData()
        self.stopGyroData()
        call.resolve()
    }
    
    func connect() {
        if sensor != nil
        {
            self.notifyListeners("successfulConnection", data: nil)
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            // We found a MetaWear board, see if it is close
            // Hooray! We found a MetaWear board, so stop scanning for more
            MetaWearScanner.shared.stopScan()
            // Connect to the board we found
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Sorry we couldn't connect
                    print("Swift: Device found, but could not be connected to: ")
                    print(error)
                    self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                } else {
                    print("Swift: Device successfully connected to!")
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
    
    func startAccelData() {
        let signal = mbl_mw_acc_get_acceleration_data_signal(self.sensor!.board)
        self.accelSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        mbl_mw_datasignal_subscribe(signal, observer) { (observer, data) in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue()
            mySelf.accelStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: accel: " + mySelf.accelStr)
            do {
                try mySelf.accelStr.appendToURL(fileURL: mySelf.accelFileURL)
            }
            catch let error {
                print("Swift: Error while appending to accel data file: ")
                print(error.localizedDescription)
            }
            if !mySelf.accelDataReceived
            {
                mySelf.accelDataReceived = true
                if (mySelf.gryoDataReceived)
                {
                    mySelf.notifyListeners("dataReceived", data: nil)
                }
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
            print("Swift: gyro: " + mySelf.gyroStr)
            do {
                try mySelf.gyroStr.appendToURL(fileURL: mySelf.gryoFileURL)
            }
            catch let error {
                print("Swift: Error while appending to gryo data file: ")
                print(error.localizedDescription)
            }
            if !mySelf.gryoDataReceived
            {
                mySelf.gryoDataReceived = true
                if (mySelf.accelDataReceived)
                {
                    mySelf.notifyListeners("dataReceived", data: nil)
                }
            }
        }
    }
    
    func stopAccelData() {
        mbl_mw_acc_stop(self.sensor!.board)
        mbl_mw_acc_disable_acceleration_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.accelSignal!)
        self.accelDataReceived = false
    }
    
    func stopGyroData() {
        mbl_mw_gyro_bmi160_stop(self.sensor!.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.gyroSignal!)
        self.gryoDataReceived = false
    }
}

extension String {
    func appendToURL(fileURL: URL) throws {
        print("Swift: Appending to URL!")
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
 }

extension Data {
  func append(fileURL: URL) throws {
      print("Swift: data.append called!")
      if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
          print("Swift: using filehandle!")
          defer {
              fileHandle.closeFile()
          }
          fileHandle.seekToEndOfFile()
          fileHandle.write(self)
      }
      else {
          print("Swift: using write!")
          try write(to: fileURL, options: .atomic)
      }
  }
}
