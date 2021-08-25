const Chats = require("../schema/Chats");
const { v4: uuidV4 } = require("uuid");

const addUser = ({ receiverEmail, senderEmail }, socket) => {
  if (!receiverEmail || !senderEmail) {
    return { error: "You tried to add wrong chat." };
  }

  const users = { receiverEmail, senderEmail };
  Chats.aggregate([{ $match: { receiverEmail, senderEmail } }]).then((chat) => {
    if (chat.length > 0) {
      socket.emit("openChat", { ...chat[0] });
    } else {
      Chats.aggregate([
        { $match: { receiverEmail: senderEmail, senderEmail: receiverEmail } },
      ]).then((lastAttempt) => {
        if (lastAttempt.length > 0) {
          socket.emit("openChat", { ...lastAttempt[0] });
        } else {
          const newRoomID = uuidV4();
          const newChat = { ...users, roomID: uuidV4() };

          socket.emit("openChat", { ...newChat });

          new Chats({ ...users, roomID: newRoomID }).save();
        }
      });
    }
  });
};

module.exports = { addUser };
