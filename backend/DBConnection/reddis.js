const redis = require('redis');
const dotenv=require('dotenv');

dotenv.config();

// Environment variables for cache
const cacheHostName = process.env.REDIS_HOST_NAME;
const cachePassword = process.env.REDIS_ACCESS_KEY;

if (!cacheHostName) throw new Error("AZURE_CACHE_FOR_REDIS_HOST_NAME is empty");
if (!cachePassword) throw new Error("AZURE_CACHE_FOR_REDIS_ACCESS_KEY is empty");

// Create a Redis client instance (using 'rediss' for secure connection)
const client = redis.createClient({
    url: `rediss://${cacheHostName}:6380`,
    password: cachePassword,
    tls: { servername: cacheHostName }
    });

    // Connect to Redis
    client.connect()
    .then(() => {
        console.log("Connected to Azure Redis Cache");
        // Optionally, run test commands here if needed.
    })
    .catch(err => {
        console.error("Error connecting to Azure Redis Cache:", err);
    });

module.exports = client;
