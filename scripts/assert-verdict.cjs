const fs = require("node:fs");
const assert = require("node:assert/strict");
const report = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const expected = Number(process.argv[3]);
assert.equal(report.exitCode, expected);
assert.equal(report.passed, expected === 0);
assert.equal(report.category, expected === 0 ? "pass" : "regression");
assert.equal(report.evidencePassed, true, "An incomplete execution is not a behavioral regression");
if (expected === 2) assert(report.failures.some(failure => /unapproved refund/i.test(failure)), "The block must identify the actual approval regression");
