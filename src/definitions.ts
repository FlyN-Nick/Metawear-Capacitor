export interface MetawearCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  connect(options: null): Promise<null>;
  disconnect(options: null): Promise<null>;
}
