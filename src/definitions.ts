export interface MetawearCapacitorPlugin {
	connect(): Promise<null>;
	disconnect(): Promise<null>;
	createDataFiles(): Promise<{ successful: boolean; }>;
	eraseDataFiles(): Promise<null>;
	startData(): Promise<null>;
	stopData(): Promise<null>;
}
