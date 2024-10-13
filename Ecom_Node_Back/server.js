require("dotenv").config()
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');


//  Various backend secma.
const itemModel = require('./Models/itemModel'); // Make sure this path is correct
const OrderItem = require("./Models/OrderItem");
const User = require("./Models/User");
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



app.use(express.json());

app.post("/newUser", async (req, res) => {
  console.log("newUser Creation");
  try {
    const {
      email,
      displayName,
      firebaseUid,
      authProvider,
      photoURL,
      phoneNumber,
      isEmailVerified
    } = req.body;

    // Check if user already exists
    let user = await User.findOne({ firebaseUid });

    if (user) {
      // Update existing user
      user.displayName = displayName;
      user.photoURL = photoURL;
      user.phoneNumber = phoneNumber;
      user.isEmailVerified = isEmailVerified;
      user.lastLogin = new Date();
      await user.save();
    } else {
      // Create new user
      user = new User({
        email,
        displayName,
        firebaseUid,
        authProvider,
        photoURL,
        phoneNumber,
        isEmailVerified,
        lastLogin: new Date()
      });
      await user.save();
    }

    res.json({
      status: true,
      message: "User data saved successfully",
      user: {
        id: user._id,
        email: user.email,
        displayName: user.displayName,
        role: user.role
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: false,
      message: "Error saving user data"
    });
  }
});

//   router for handli/ng the deleting of things
app.delete("/items:id", () => {
   console.log("golden space")
})
//  for new orders
app.post("/newOrder", async (req, res) => {
  console.log("newOrder Intake");
  try {
    const { user, items, totalAmount, shippingAddress } = req.body;

    //  finding that specific user
    let userContent = await User.findOne({
      email : user
    })

    let userId = userContent.id
    if (userContent) {
          const newOrder = new OrderItem({
      userId,
      items,
      totalAmount,
      shippingAddress,
    });

    const savedOrder = await newOrder.save();

    res.status(200).json({
      message: "Order created successfully",
      orderId: savedOrder._id,
    });

    } else {
        res.status(500).json({
      message: "kcuf it is right ",
      orderId: savedOrder._id,
    });

    }


  } catch (error) {
    console.error("Error creating order:", error);
    res.status(500).json({
      message: "Error creating order",
      error: error.message,
    });
  }
});

app.get("/orders/:userEmail", async (req, res) => {
  try {
    let userContent= req.params.userEmail;

    let userInformation = await User.findOne({
       email : userContent
     })
    const orders = await OrderItem.find({ userId: userInformation.id })
      .populate('items.item')
      .sort({ orderDate: -1 });
    res.status(200).json(orders);
    console.log(orders)
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({
      message: "Error fetching orders",
      error: error.message,
    });
  }
});

// Health check route
app.get("/", (req, res) => {
  res.status(200).send("Server is running");
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});


module.exports = app; // This is important for Vercel