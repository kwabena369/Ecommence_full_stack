const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    // Not required because it might be null for social auth
  },
  displayName: {
    type: String,
    trim: true
  },
  firebaseUid: {
    type: String,
    unique: true,
      sparse: true
  },
  Secret_String: {
    type: String,
    trim: true,
    required:false
  }
  ,
  authProvider: {
    type: String,
    enum: ['email', 'google', 'facebook'],
    required: true
  },
  photoURL: String,
  phoneNumber: String,
  address: {
    street: String,
    city: String,
    state: String,
    country: String,
    zipCode: String
  },
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  lastLogin: Date,
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);