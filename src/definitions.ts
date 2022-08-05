export interface MetawearCapacitorPlugin {
	/**
	 * Connects to the metawear sensor.
	 */
	connect(): Promise<null>;
	/**
	 * Disconnect metawear sensor.
	 */
	disconnect(): Promise<null>;
	/**
	 * Start accel and gryo data streaming and on-board logging.
	 */
	startData(): Promise<null>;
	/**
	 * Start accel data streaming and on-board logging. 
	 * 
	 * Listen in JS for the logging ID with:
	 * MetawearCapacitor.addListener('accelLogID', (logID) -> { ... });
	 * 
	 * Listen in JS with:
	 * MetawearCapacitor.addListener('accelData', (accel) => { ... });
	 */
	startAccelData(): Promise<null>;
	/**
	 * Start gyro data streaming and on-board logging.
	 * 
	 * Listen in JS for the logging ID with:
	 * MetawearCapacitor.addListener('gyroLogID', (logID) -> { ... });
	 * 
	 * Listen in JS for data stream with:
	 * MetawearCapacitor.addListener('gyroData', (gyro) => { ... });
	 */
	startGyroData(): Promise<null>;
	/**
	 * Stop data streaming and on-board logging.
	 */
	stopData(): Promise<null>;
	/**
	 * Downloads one of the two logs from the metawear sensor.
	 * 
	 * Listen in JS for the log data with:
	 * MetawearCapacitor.addListener('logData-ID', (logData) -> { ... });
	 * 
	 * Listen in JS for log finish with:
	 * MetawearCapacitor.addListener('logFinished-ID', () => { ... });
	 */
	downloadData(): Promise<null>;
}
