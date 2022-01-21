export interface metwearPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
