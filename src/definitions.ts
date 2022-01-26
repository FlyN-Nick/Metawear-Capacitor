export interface MetawearCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  connect(): Promise<null>;
  disconnect(): Promise<null>;
  createDataFiles(): Promise<null>;
  eraseDataFiles(): Promise<null>;
  startData(): Promise<null>;
  stopData(): Promise<null>;
}
