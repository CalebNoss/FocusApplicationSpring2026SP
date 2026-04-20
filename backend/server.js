// load environment variables from the .env file into process.env
require("dotenv").config();

// import express framework to create the web server
const express = require("express");

// import cors middleware to allow frontend requests
const cors = require("cors");

// import pool from pg (postgres client) to connect to the database
const { Pool } = require("pg");

// create an express application (this is your backend server)
const app = express();

// enable cors so flutter web can communicate with this backend
app.use(cors());

// allow the server to understand json data sent in request bodies
app.use(express.json());

// create a connection pool to the postgres database
// pool manages database connections efficiently
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});// create a test route at "/health"
// this checks whether the backend can successfully talk to the database
app.get("/health", async (req, res) => {
  try {
    // run a simple sql query that asks the database for the current time
    const result = await pool.query("SELECT NOW()");

    // send back a json response confirming the database is connected
    res.json({
      status: "database connected",
      time: result.rows[0].now,
    });

  } catch (error) {
    // if something fails, send an error response
    res.status(500).json({
      status: "database connection failed",
      error: error.message,
    });
  }
});

// define which port the server should run on
// use the deployment platform's port if provided
// otherwise default to 3000 for local development
const PORT = process.env.PORT || 3000;

// start the server and listen for incoming requests
app.listen(PORT, () => {
  // log a message in the terminal so we know the server is running
  console.log(`server running on port ${PORT}`);
});