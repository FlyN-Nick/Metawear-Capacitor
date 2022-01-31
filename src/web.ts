import { WebPlugin } from '@capacitor/core';

import type { MetawearCapacitorPlugin } from './definitions';

export class MetawearCapacitorWeb
	extends WebPlugin
	implements MetawearCapacitorPlugin {
	async startAccelData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async startGyroData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async createDataFiles(): Promise<{ successful: boolean; }> {
		throw new Error('Method not implemented.');
	}
	async eraseDataFiles(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async startData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async stopData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async connect(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async disconnect(): Promise<null> {
		throw new Error('Method not implemented.');
	}
}
