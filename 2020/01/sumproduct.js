#!/usr/bin/env node

const fs = require('fs');
const process = require('process');

const numbers = fs
  .readFileSync(process.argv[2])
  .toString()
  .split(/[\r\n]+/)
  .map(n => parseInt(n));

let product = null;
for (let i = 0; i < numbers.length - 1; i++) {
  for (let j = i + 1; j < numbers.length; j++) {
    if (numbers[i] + numbers[j] == 2020) {
      product = numbers[i] * numbers[j];
      j = i = numbers.length;
    }
  }
}
console.log(product);

product = null;
for (let i = 0; i < numbers.length - 2; i++) {
  for (let j = i + 1; j < numbers.length - 1; j++) {
    for (let k = j + 1; k < numbers.length; k++) {
      if (numbers[i] + numbers[j] + numbers[k] == 2020) {
        product = numbers[i] * numbers[j] * numbers[k];
        j = i = k = numbers.length;
      }
    }
  }
}
console.log(product);
