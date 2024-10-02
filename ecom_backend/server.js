require("dotenv").config();
//  making the user of the dotenv to be possible
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors")

//  the mongoose_url
const mongoose = require("mongoose")

//  the real deal 
const app = express();
// setting up the middleware tha would make certain thing possible
app.use(cors());
app.use(bodyParser.json())


//  the starting of the mongoosedb
mongoose.connect(process.env.MONGODB_URL).then(() => {
     console.log("successfully connected to the db")
}).catch(() => {
     console.error("Error doing connection to the db")
})
//   the router and other 



//  the real deal of starting the server
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
          console.log(`Server is ruuning at : ${PORT}`)
     })
}

module.exports = app