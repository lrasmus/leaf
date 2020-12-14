const proxy = require('http-proxy-middleware'); module.exports = function(app) { app.use(proxy('/api', { target: 'http://host.docker.internal:5001/' })) }
