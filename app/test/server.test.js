const { test, before, after } = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../server.js');

let server;
const TEST_PORT = 3999;

before((done) => {
  server = app.listen(TEST_PORT, done);
});

after((done) => {
  server.close(done);
});

test('GET /health returns 200 and status UP', (t, done) => {
  http.get(`http://localhost:${TEST_PORT}/health`, (res) => {
    assert.strictEqual(res.statusCode, 200);
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
      const json = JSON.parse(data);
      assert.strictEqual(json.status, 'UP');
      assert.ok(json.version);
      assert.ok(json.hostname);
      done();
    });
  });
});

test('GET /api/info returns Azure and Terraform metadata', (t, done) => {
  http.get(`http://localhost:${TEST_PORT}/api/info`, (res) => {
    assert.strictEqual(res.statusCode, 200);
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
      const json = JSON.parse(data);
      assert.strictEqual(json.cloud.provider, 'Microsoft Azure');
      assert.strictEqual(json.cloud.provisioner, 'Terraform');
      assert.ok(json.system.platform);
      done();
    });
  });
});
