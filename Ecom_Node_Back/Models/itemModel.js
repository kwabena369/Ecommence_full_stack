const mongoose = require("mongoose");

//  creating the schema


let itemShema = new mongoose.Schema({
    name: {
        type: String,
        required : true
    },
    PreviewItem_Base_Content: {
        type: String,
        required : true,
    },
    Price : {
        type: Number,
        required : true 
    }

})
//  exporting the item
module.exports = mongoose.model("itemModel", itemShema);