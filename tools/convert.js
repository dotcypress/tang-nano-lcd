const { readFileSync, writeFileSync } = require('fs')

const bitmap = readFileSync('./image.raw')
const bits = bitmap.reduce((acc, word) => ([...acc, ...word.toString(2).padStart(8, '0')]), [])
writeFileSync("./../src/bitmap.mem", bits.join(' '))