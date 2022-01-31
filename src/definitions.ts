export interface MetawearCapacitorPlugin {
	connect(): Promise<null>;
	disconnect(): Promise<null>;
	createDataFiles(): Promise<{ successful: boolean; }>;
	eraseDataFiles(): Promise<null>;
	startData(): Promise<null>;
	startAccelData(): Promise<null>;
	startGyroData(): Promise<null>;
	stopData(): Promise<null>;
}
