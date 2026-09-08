export type Mismatch = { eventId: string; cents: number };

export function tolerated(m: Mismatch): boolean {
  return Math.abs(m.cents) <= 5;
}
