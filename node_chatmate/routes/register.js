const express = require("express");
const User = require("../schema/User");
const bcrypt = require("bcryptjs");
const router = express.Router();
const jwt = require("jsonwebtoken");
const config = require("config");

//* Post Request *//
router.post("/", (req, res) => {
  const { name, email, password, cpassword } = req.body;
  if (!email || !password || !cpassword) {
    return res.status(400).json({ msg: "Please enter all fields." });
  }
  if (password !== cpassword) {
    res.status(400).json({ msg: "Passwords must match." });
  }

  User.findOne({ email })
    .then((user) => {
      if (user) return res.status(400).json({ msg: "User Exists" });
      bcrypt.hash(password, 12).then((hashedPassword) => {
        const newUser = new User({
          email: email,
          password: hashedPassword,
          name: name,
        });
        newUser.save();
      });
    })
    .catch((err) => console.log(err));
});

module.exports = router;
