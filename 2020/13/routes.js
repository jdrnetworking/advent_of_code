#!/usr/bin/env node

const fs = require('fs');
const process = require('process');

const busses = fs.readFileSync(process.argv[2], 'utf8').split(',');
const ids_with_offsets = busses
  .map((bus_id, index) => [Number.parseInt(bus_id), index])
  .filter(pair => !Number.isNaN(pair[0]));
const [max_bus_id, max_bus_offset] = ids_with_offsets.reduce((max, pair) => pair[0] > max[0] ? pair : max, [0, 0])
let m = busses.size > 15 ? Math.floor((100000000000000 - max_bus_offset) / max_bus_id) : 1
let t = 0
while(true) {
  t = m * max_bus_id - max_bus_offset;
  if (ids_with_offsets.every(pair => (t + pair[1]) % pair[0] == 0)) break;
  m += 1;
}
console.log(t);
