export function reconcile(batch: string[]): string[] {
  return Array.from(new Set(batch));
}
