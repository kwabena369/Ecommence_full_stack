// for each times
const mongoose = require("mongoose");
 const bcypt = require("bcrypt")

//  this seciton is for each fucken user
const Userschema = new mongoose.Schema({
    UserName: {
        type: String,
    },
    Contact_Information: {
        phone_Number: {
      type : String,
        },
         Email: {
              type : String,
         }
    },
    //   the pw
     UserPw: {
         type: String,
         require: true 
     }
})
 

//  the hashing of the pw
Userschema.pre("save", async(next) => {
    //   checking if there is anything like modification to thee pw
    if (this.isModified("UserPw")) { 
        //  then we do the hasing of the pw
        this.UserPw = await bcypt.hash(this.UserPw, 10);
    }
    next();
})


//    making if available to the others
module.exports = mongoose.model("User",Userschema)

const ItemsSchema = new mongoose.Schema({
    ItemName: {
        type: String,
        required:  true
    },
    PriceItem: {
        type: Number,
        required:true
    },
    Ratings: {
         type : Number
    },

})

module.exports = mongoose.model("Item",ItemsSchema)

