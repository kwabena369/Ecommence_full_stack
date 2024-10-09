require("dotenv").config()
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const itemModel = require('./Models/itemModel'); // Make sure this path is correct

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

 const mongodb_url = process.env.DATABASE_URL
// Database connection
mongoose.connect(mongodb_url, { serverSelectionTimeoutMS: 5000 })
  .then(() => console.log("Connected to database"))
  .catch((err) => {
    console.error("Failed to connect to database:", err);
    process.exit(1);  // Exit the process if unable to connect to the database
  });
// Route for uploading file
app.post("/UploadFile", async (req, res) => {
  try {
    const { name, price, aim, previewItemBaseContent } = req.body;

    const newItem = new itemModel({
      name: name,
      Price: price,
      Aim: aim,
      PreviewItem_Base_Content: previewItemBaseContent
    });

    await newItem.save();

    res.status(200).json({
      message: "Item uploaded successfully"
    });
  } catch (error) {
    console.error('Error uploading item:', error);
    res.status(500).json({
      message: "Failed to upload item",
      error: error.message
    });
  }
});

// New route for fetching all items
app.get("/items", async (req, res) => {
  try {
    const items = await itemModel.find();
    res.status(200).json(items);
  } catch (error) {
    console.error('Error fetching items:', error);
    res.status(500).json({
      message: "Failed to fetch items",
      error: error.message
    });
  }
});

//   router for handli/ng the deleting of things
app.delete("/items:id", () => {
   console.log("golden space")
})

// Health check route
app.get("/", (req, res) => {
  res.status(200).send("Server is running");
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app; // This is important for Vercel