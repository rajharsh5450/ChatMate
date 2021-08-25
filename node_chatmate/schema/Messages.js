const mongoose = require("mongoose");
const { stringify } = require("uuid");
const Schema = mongoose.Schema;

const MessagesSchema = new Schema({
  _id: { type: String },
  txtMsg: { type: String, required: true },
  roomID: { type: String, required: true },
  senderEmail: { type: String, required: true },
  recieverEmail: { type: String, required: true },
  time: { type: String, default: Date.now },
});

module.exports = Messages = mongoose.model("messages", MessagesSchema);
