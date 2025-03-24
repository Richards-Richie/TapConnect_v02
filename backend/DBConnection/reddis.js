const redis = require('redis');
const dotenv = require('dotenv');

dotenv.config();

// Environment variables for cache
const cacheHostName = process.env.REDIS_HOST_NAME;
const cachePassword = process.env.REDIS_ACCESS_KEY;

if (!cacheHostName) throw new Error("REDIS_HOST_NAME is empty");
if (!cachePassword) throw new Error("REDIS_ACCESS_KEY is empty");

const client = redis.createClient({
  url: `rediss://${cacheHostName}:6380`, // rediss = SSL
  password: cachePassword,
  socket: {
    tls: true, // Must enable TLS for Azure Redis
    rejectUnauthorized: false // Needed for Azure's SSL cert
  },
  retry_strategy: (options) => {
    if (options.error && options.error.code === 'ECONNREFUSED') {
      return new Error('The server refused the connection');
    }
    return Math.min(options.attempt * 100, 3000);
  }
});

// Event handlers
client.on('connect', () => console.log('Connecting to Redis...'));
client.on('ready', () => console.log('Connected to Azure Redis Cache'));
client.on('error', (err) => console.error('Redis Client Error:', err));
client.on('end', () => console.log('Disconnected from Redis'));

// Connect with async/await for better error handling
(async () => {
  try {
    await client.connect();
    // Test connection with a simple command
    await client.ping();
  } catch (err) {
    console.error('Connection failed:', err);
    process.exit(1);
  }
})();

module.exports = client;