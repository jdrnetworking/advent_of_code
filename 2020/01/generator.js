#!/usr/bin/env node

const fs = require('fs');
const process = require('process');

const numbers = fs
  .readFileSync(process.argv[2])
  .toString()
  .split(/[\r\n]+/)
  .map(n => parseInt(n));

function* combination(arr, k) {
  if (k > arr.length)
    throw new Error(`Can't do combinations of ${k} on an array of size ${arr.length}`);

  let indices = Array.from(Array(k).keys());
  yield indices.map(n => arr[n]);
  while (indices[0] != arr.length - k) {
    let i;
    for (i = k - 1; i > 0 && indices[i] == arr.length - k + i; i--) {}
    indices[i] += 1;
    for (let j = i; j < k - 1; j++) {
      indices[j + 1] = indices[j] + 1;
    }
    yield indices.map(n => arr[n]);
  }
}

const getAnswer = (numbers, size, target = 2020) => {
  let iterator = combination(numbers, size);
  let nextCombination;
  while (
    (nextCombination = iterator.next()) &&
    !nextCombination.done &&
    (nextCombination.value.reduce((s,v) => s + v) != target)
  );
  if (nextCombination.done) return null;
  return nextCombination.value.reduce((s,v) => s * v);
}

console.log(getAnswer(numbers, 2));
console.log(getAnswer(numbers, 3));
