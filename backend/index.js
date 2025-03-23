const express = require('express');
const app = express();
const cors = require('cors');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const data = require("./DBConnection/db.js");
const redisClient = require("./DBConnection/reddis.js");
const WebSocket = require('ws');

dotenv.config();
app.use(cors());
app.use(express.json());

const uri = process.env.DBURL;
const clientOptions = { serverApi: { version: '1', strict: true, deprecationErrors: true } };
mongoose.connect(uri, clientOptions)
    .then(() => console.log("Connected to DB"))
    .catch(err => console.log(err));

app.get('/', (req, res) => {
    res.send('<h1>hi hello world</h1>');
});

app.post('/putDetails', async (req, res) => {
    try {
        const textdata = new data({
        name: req.body.name,
        mobile: req.body.mobile,
        email: req.body.email
        });
        const userId = await textdata.save();
        res.status(200).json({ message: "Data saved successfully", userId: userId._id });
    } catch (e) {
        res.status(500).json({ message: e });
    }
});

app.post('/getDetails', async (req, res) => {
    try {
        const id = req.body.userId;
        const dbData = await data.findById(id);
        res.status(200).json({ data: dbData });
    } catch (error) {
        console.log(error);
        res.status(500).json({ message: error });
    }
});

app.post('/QrDetails', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
        return res.status(400).json({ message: "Missing userId in request" });
        }
        const userIdExistence = await redisClient.exists(userId);
        if (!userIdExistence) {
            await redisClient.sAdd(userId,userId);
            await redisClient.expire(userId, 3600);
            console.log(userId + " exists in the redis: " + redisClient.exists(userId));
        }
        res.status(200).json({
        message: "QR details processed. Please connect to the WebSocket server for further updates.",
        wsUrl: `ws://localhost:${process.env.WSURL}`
        });
    } catch (error) {
        console.error("Error processing QR details:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

app.post('/ScannerDetails', async (req, res) => {
    try{
        const scannerId=req.body.scannerId;
        const qrId=req.body.qrId;
        const userIdExistence=await redisClient.exists(qrId);
        if(userIdExistence){
            await redisClient.sAdd(qrId,scannerId);
            await redisClient.expire(qrId,3600);
        }else{
            await redisClient.sAdd(qrId,qrId);
            await redisClient.sAdd(qrId,scannerId);
            await redisClient.expire(qrId,3600);
        }
        console.log("saved to redis");
        const scannerIds = await redisClient.sMembers(qrId);
        const filteredScannerIds = scannerIds.filter(id => id !== qrId);
        let scannersDetails = [];
        const set1=Array.from(new Set(filteredScannerIds));
        
        for(const id of set1){
            const userDetails=await data.findById(id);
            console.log(userDetails);
            scannersDetails.push(userDetails);
        }
        console.log(scannersDetails);
        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN && client.userId === qrId) {
                client.send(JSON.stringify({
                    type: 'scannersUpdate',
                    scanners: scannersDetails
                }));
            }
        });
        return res.status(200).json({message:"saved to redis"});
    }catch(error){
        return res.status(400).json({message : error});
    };
})

const httpServer = app.listen(process.env.PORT, '0.0.0.0', () => {
    console.log("Listening on " + process.env.PORT);
});

const wss = new WebSocket.Server({ port: process.env.WSURL }, () => {
    console.log("WebSocket server is listening on port: " + process.env.WSURL);
});

wss.on('connection', (ws) => {
    console.log("New WebSocket connection established");

    ws.on('message', (message) => {
        try {
        const data = JSON.parse(message);
        if (data.type === "register" && data.userId) {
            ws.userId=data.userId
            console.log(`User ${data.userId} connected via WebSocket`);
        }
        } catch (error) {
        console.error("Error parsing message:", error);
        }
    });

    ws.send(JSON.stringify({ type: "welcome", message: "WebSocket connection established" }));
});
