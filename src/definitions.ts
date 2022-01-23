export interface MetawearCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  connect(): Promise<null>;
  disconnect(): Promise<null>;
}
