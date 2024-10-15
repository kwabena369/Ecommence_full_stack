require("dotenv").config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const session = require('express-session');
const bcrypt = require('bcrypt');
const ejs = require('ejs');
//  Various backend secma.
const itemModel = require('./Models/itemModel'); // Make sure this path is correct
const OrderItem = require("./Models/OrderItem");
const User = require("./Models/User");
const app = express();
const path = require('path');

const https = require("https")


 const mongodb_url = process.env.DATABASE_URL
// Database connection
mongoose.connect(mongodb_url,)
  .then(() => console.log("Connected to database"))
  .catch((err) => {
    console.error("Failed to connect to database:", err);
    process.exit(1);  // Exit the process if unable to connect to the database
  });

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));



app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
//  the routing for the admin and others 
// const authenticateAdmin = (req, res, next) => {
//   if (req.session.adminId) {
//     next();
//   } else {
//     res.redirect('/admin/login');
//   }
// };


app.get('/admin/login', (req, res) => {
  res.render('login');
});

app.post('/admin/login', async (req, res) => {
  const { email } = req.body;
  const admin = await User.findOne({ email:email, role: 'admin' });

// but later  leter the perosn need to end  enter thier information .
  if (admin ) {
    // req.session.adminId = admin._id;
    res.redirect('/admin/orders');
  } else {
    res.render('login', { error: 'Invalid credentials' });
  }
});

// Admin orders page
app.get('/admin/orders', async (req, res) => {
  const orders = await OrderItem.find().sort({ orderDate: -1 });
  res.render('orders', { orders });
});
//  there come a time when we 

// Update order status
app.post('/admin/orders/:orderId/update-status', async (req, res) => {
  const { orderId } = req.params;
  const { status } = req.body;

  await OrderItem.findByIdAndUpdate(orderId, { status : status });
  res.redirect('/admin/orders');
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





const paystackSecretKey = process.env.PAYSTACK_SECRET_KEY;




app.post('/submit-otp', async (req, res) => {
  const { otp, reference } = req.body;

  const params = JSON.stringify({
    "otp": otp,
    "reference": reference
  });

  const options = {
    hostname: 'api.paystack.co',
    port: 443,
    path: '/charge/submit_otp',
    method: 'POST',
    headers: {
      Authorization: `Bearer ${paystackSecretKey}`,
      'Content-Type': 'application/json'
    }
  };

  const paystackReq = https.request(options, paystackRes => {
    let data = '';
    paystackRes.on('data', (chunk) => {
      data += chunk;
    });

    paystackRes.on('end', () => {
      console.log(JSON.parse(data));
      res.header('Content-Type', 'application/json');
      res.status(200).json(JSON.parse(data));
    });
  }).on('error', error => {
    console.error(error);
    res.status(500).json({ error: 'Failed to submit OTP' });
  });

  paystackReq.write(params);
  paystackReq.end();
});



app.post('/initiate-payment', async (req, res) => {
  const { amount, phoneNumber } = req.body;

  const params = JSON.stringify({
    "amount": amount * 100, // Paystack expects amount in kobo
    "email": "bernardboampong614@gmail.com", // You might want to get this from the user or your database
    "currency": "GHS",
    "mobile_money": {
      "phone": phoneNumber,
      "provider": "mtn"
    }
  });

  const options = {
    hostname: 'api.paystack.co',
    port: 443,
    path: '/charge',
    method: 'POST',
    headers: {
      Authorization: `Bearer ${paystackSecretKey}`,
      'Content-Type': 'application/json'
    }
  };

  const paystackReq = https.request(options, paystackRes => {
    let data = '';

    paystackRes.on('data', (chunk) => {
      data += chunk;
    });

    paystackRes.on('end', () => {
      console.log(JSON.parse(data));
      res.header('Content-Type', 'application/json');
      res.header('Access-Control-Allow-Origin', '*');
      res.status(200).json(JSON.parse(data));
    });
  }).on('error', error => {
    console.error(error);
    res.status(500).json({ error: 'Failed to initiate payment' });
  });

  paystackReq.write(params);
  paystackReq.end();
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