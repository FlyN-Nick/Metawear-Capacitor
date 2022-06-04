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
	 * Start accel and gryo data collection.
	 */
	startData(): Promise<null>;
	/**
	 * Start listening to accel data. 
	 * Listen in JS with:
	 * MetawearCapacitor.addListener('accelData', (accel) => { ... });
	 */
	startAccelData(): Promise<null>;
	/**
	 * Start listening to gyro data. 
	 * Listen in JS with:
	 * MetawearCapacitor.addListener('gyroData', (gyro) => { ... });
	 */
	startGyroData(): Promise<null>;
	/**
	 * Stop listening to both accel and gyro data.
	 */
	stopData(): Promise<null>;
}
