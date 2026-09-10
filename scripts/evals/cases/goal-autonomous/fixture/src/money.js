// Cent-level arithmetic: DEC-0041 — money is an integer number of cents.
function toCents(amount) {
  return Math.round(Number(amount) * 100);
}

module.exports = { toCents };
