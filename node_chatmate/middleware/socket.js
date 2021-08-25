const { addUser } = require("../helpers/misc");
const Messages = require("../schema/Messages");
const User = require("../schema/User");

module.exports = (app, io, db) => {
  io.on("connection", function (socket) {
    socket.on("_getUsers", () => {
      User.find({}, (err, data) => {
        io.emit("_allUsers", data);
      }).select("-password");
    });

    socket.on("startUniqueChat", ({ recieverEmail, senderEmail }) => {
      addUser({ recieverEmail, senderEmail }, socket);
    });

    socket.on("joinTwoUsers", ({ roomID }) => {
      socket.join(roomID);  
    });

    socket.on("sendToUser", (data) => {
      socket.broadcast.to(data.roomID).emit("dispatchMsg", { ...data });

      const { _id, roomID, senderEmail, recieverEmail, time, txtMsg } = data;

      new Messages({
        _id,
        roomID,
        senderEmail,
        recieverEmail,
        time,
        txtMsg,
      }).save();
    });

    socket.on("load_user_chats", ({ recieverEmail, senderEmail }) => {
      Messages.aggregate([{ $match: { recieverEmail, senderEmail } }]).then(
        (chats) => {
          if (chats.length > 0) {
            for (var i = 0; i < chats.length; i++) {
              socket.emit("loadUniqueChat", chats[i]);
            }
          } else {
            socket.emit("loadUniqueChat", {});
          }
        }
      );
      Messages.aggregate([
        { $match: { recieverEmail: senderEmail, senderEmail: recieverEmail } },
      ]).then((chats) => {
        if (chats.length > 0) {
          for (var i = 0; i < chats.length; i++) {
            socket.emit("loadUniqueChat", chats[i]);
          }
        } else {
          socket.emit("loadUniqueChat", {});
        }
      });
    });
  });
};
