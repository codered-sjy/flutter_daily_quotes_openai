const admin = require("firebase-admin");
const functions = require("firebase-functions");
const axios = require("axios").default;
admin.initializeApp();

exports.generateQuoteOfTheDay = functions.https.onCall(
  async (data, context) => {
    let quoteSnapshot = await admin.database().ref("/quote").once("value");
    if (quoteSnapshot.exists()) {
      let createdDate = quoteSnapshot.val().createdDate;
      let currentDate = admin.firestore.Timestamp.now()
        .toDate()
        .toISOString()
        .substring(0, 10);
      if (currentDate == createdDate) {
        return quoteSnapshot.val().dailyQuote;
      } else {
        let response = await axios.post("https://api.openai.com/v1/completions",
          {
            model: "text-davinci-003",
            prompt: "Create a famous quote and put the quoter name at the end after ~~",
            max_tokens: 1000,
            temperature: 0.9
          },
          {
            headers: {
              "Content-Type": "application/json",
              Authorization: "Bearer " + functions.config().openai.key,
            },
          }
        );
        if (response.status == 200) {
          return admin
            .database()
            .ref("/quote")
            .set({
              createdDate: currentDate,
              dailyQuote: response.data["choices"][0]["text"],
            }).then(data => {
              functions.logger.log("Successfull WRITE to DB");
              return response.data["choices"][0]["text"];
            })
            .catch(error => {
              functions.logger.error("Error while generating quote");
              return null;
            });
        } else {
          functions.logger.error("Error while generating quote");
          return null;
        }
      }
    } else {
      functions.logger.error("Unknown error with DB");
      return null;
    }
  }
);