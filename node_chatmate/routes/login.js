const express = require("express");
const User = require("../schema/User");
const bcrypt = require("bcryptjs");
const router = express.Router();
const jwt = require("jsonwebtoken");
const config = require("config");
const auth = require("../middleware/auth");

router.post("/", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ msg: "Please enter all fields." });
  }

  User.findOne({ email })
    .then((user) => {
      if (!user) return res.status(400).json({ msg: "User does not Exists" });
      bcrypt.compare(password, user.password).then((doMatch) => {
        if (doMatch) {
          jwt.sign(
            { id: user._id },
            config.get("flutter__secret"),
            {
              expiresIn: 3600,
            },
            (err, token) => {
              if (err) throw err;
              res.status(200).json({
                token,
                user: { id: user._id, name: user.name, email: user.email },
              });
            }
          );
        }
      });
    })
    .catch((err) => console.log(err));
});

// Load a user
router.get("/user", auth, (req, res) => {
  User.findById(req.chatUser.id)
    .select("-password")
    .then((user) => {
      res.status(200).json(user);
    })
    .catch((err) => console.log(err));
});

module.exports = router;
