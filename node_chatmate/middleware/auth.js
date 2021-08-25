const config = require("config");
const jwt = require("jsonwebtoken");

function auth(req, res, next) {
    const token = req.header('x-chatmate-token');
    if (!token) return res.status(401).json({ msg: "No token found." });

    try {
        //verifying token and store user
        const decoded = jwt.verify(token, config.get("flutter__secret"));
        req.chatUser = decoded;
        next();
    } catch (err) {
        res.status(400).json({ msg: "Token is invalid." });
    }

}

module.exports = auth;
