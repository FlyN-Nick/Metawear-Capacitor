/**
    Made by Nicholas Assaderaghi for Kyntic, 2021-2022.
*/

import Foundation
import Capacitor
import MetaWear
import MetaWearCpp

@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    
    private var sensor: MetaWear? = nil
    
    private var accelSignal: OpaquePointer? = nil
    private var gyroSignal: OpaquePointer? = nil
    
    private var accelStr: String = ""
    private var gyroStr: String = ""
    
    private var accelDataReceived = false
    private var gryoDataReceived = false
        
    private(set) var accelData = MWSensorDataStore()
    private(set) var gyroData = MWSensorDataStore()
    
    private var currentLogID: String = ""

    
    @objc func connect(_ call: CAPPluginCall) {
        print("Swift: Connect called.")
        self.connect()
        call.resolve()
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        print("Swift: Disconnect called.")
        self.sensor!.cancelConnection()
        self.sensor = nil
        call.resolve()
    }
    
    @objc func startData(_ call: CAPPluginCall) {
        print("Swift: StartData called.")
        self.startGyroData()
        self.startAccelData()
        call.resolve()
    }
    
    @objc func startAccelData(_ call: CAPPluginCall) {
        print("Swift: StartAccelData called.")
        self.startAccelData()
        call.resolve()
    }
    
    @objc func startGyroData(_ call: CAPPluginCall) {
        print("Swift: StartGyroData called.")
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
        print("Swift: time to connect!")
        if sensor != nil
        {
            self.notifyListeners("successfulConnection", data: nil) // JS is being silly, we are already connected :D
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (device) in
            // sensor found
            MetaWearScanner.shared.stopScan() // stop searching for the sensor
            // Connect to the board we found
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Error while trying to connect
                    print("Swift: Device found, but could not be connected to: ")
                    print(error)
                    self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                } else {
                    print("Swift: Device successfully connected to!")
                    self.sensor = device // so we can use it in the future
                    self.notifyListeners("successfulConnection", data: nil) // so js can respond to sensor connecting
                    
                    // Flash sensor LED blue to indicate successful connection
                    var pattern = MblMwLedPattern()
                    mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                    mbl_mw_led_stop_and_clear(device.board)
                    mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_BLUE)
                    mbl_mw_led_play(device.board)
                }
            }
        }
    }
    
    /**Start acceleration data stream and start logging acceleration data on-board.*/
    func startAccelData() {
        // get signal
        let signal = mbl_mw_acc_get_acceleration_data_signal(self.sensor!.board)
        self.accelSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // start log
        mbl_mw_datasignal_log(self.accelSignal, observer) { observer, logger in
                // callback for starting log, gives us info about the log
                let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
                let cString = mbl_mw_logger_generate_identifier(logger)!
                // the identifier is always "acceleration"
                let identifier = String(cString: cString)
                print("Swift: Accel Log ID: \(identifier)")
                let timestamp = NSDate().timeIntervalSince1970
                mySelf.notifyListeners("accelLogID", data: ["ID": identifier, "time": timestamp])
            }
        mbl_mw_logging_start(self.sensor!.board, 1) // second param is nonzero to overwrite older log entries

        // subscribe to data stream
        mbl_mw_datasignal_subscribe(self.accelSignal, observer) { observer, data in
            // callback for each datapoint we get
            let obj: MblMwCartesianFloat = data!.pointee.valueAs() // convert to tuple of floats
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            mySelf.accelStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: accel: " + mySelf.accelStr) // print accel data to console
            mySelf.notifyListeners("accelData", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give accel data to js
        }
        
        // turn on accel on sensor
        mbl_mw_acc_enable_acceleration_sampling(self.sensor!.board)
        mbl_mw_acc_start(self.sensor!.board)
     }
    
    /**Start gyroscope data stream and start logging gyroscope data on-board.*/
    func startGyroData() {
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(self.sensor!.board)
        self.gyroSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // start log
        mbl_mw_datasignal_log(self.gyroSignal, observer) { observer, logger in
                // callback for starting log, gives us info about the log
                let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
                let cString = mbl_mw_logger_generate_identifier(logger)!
                // the identifier is always "angular-velocity"
                let identifier = String(cString: cString)
                print("Swift: Gyro Log ID: \(identifier)")
                let timestamp = NSDate().timeIntervalSince1970
                mySelf.notifyListeners("gyroLogID", data: ["ID": identifier, "time": timestamp])
            }
        mbl_mw_logging_start(self.sensor!.board, 1) // second param is nonzero to overwrite older log entries
        
        // subscribe to data stream
        mbl_mw_datasignal_subscribe(self.gyroSignal, observer) { observer, data in
            // callback for each datapoint we get
            let obj: MblMwCartesianFloat = data!.pointee.valueAs() // convert to tuple of floats
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            mySelf.gyroStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: gyro: " + mySelf.gyroStr) // print gyro data to console
            mySelf.notifyListeners("gyroData", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give gyro data to js
        }
        
        // turn on gyro on sensor
        mbl_mw_gyro_bmi160_enable_rotation_sampling(self.sensor!.board)
        mbl_mw_gyro_bmi160_start(self.sensor!.board)
    }
    
    /**Given log IDs, download log data.**/
    func getLogData(ID: String) {
        self.currentLogID = ID
        let log = mbl_mw_logger_lookup_id(self.sensor!.board, UInt8(Int(ID)!))
        
        print("Swift: Yo here's the pointer to the log object: \(String(describing: log))")
        
        mbl_mw_logging_stop(self.sensor!.board)

        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            
        mbl_mw_logger_subscribe(log, observer, { (observer, data) in
            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            mySelf.notifyListeners("logData-\(mySelf.currentLogID)", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give log data point to js
        })
        
        var handlers = MblMwLogDownloadHandler()
        handlers.context = Unmanaged.passRetained(self).toOpaque()
        handlers.received_progress_update = { (observer, remainingEntries, totalEntries) in
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            print("Swift: Log download progress: \(progress)")
            if remainingEntries == 0 {
                print("Swift: Done downloading log :D")
                mySelf.notifyListeners("logFinished-\(mySelf.currentLogID)", data: nil)
                mySelf.currentLogID = ""
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("Swift: received_unknown_entry when downloading log")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("Swift: received_unhandled_entry when downloading log")
        }
        mbl_mw_logging_download(self.sensor!.board, 100, &handlers)
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
