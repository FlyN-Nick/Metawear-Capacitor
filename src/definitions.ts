export interface MetawearCapacitorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
