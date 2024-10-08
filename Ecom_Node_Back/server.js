require("dotenv").config()

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());


//  the connection to the db

mongoose.connect(process.env.DATABASE_URL).then(() => {
     console.log("it is done bro we are in ")
}).catch(() => {
    console.log("it is not connected so go suck a piece of ....")
})
//  the Router for  the Uploading of file
app.post("/UploadFile", (req,res) => {
     

    res.status(200).json({
        message: " it is done in the golden "
    });
})



//   checking if we are not in the env space
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is starting on port ${PORT}`);
});

app.listen()
