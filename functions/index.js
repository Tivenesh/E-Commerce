const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const stripe = require("stripe")("sk_test_51RgRX7Q00D5aT2cEIfcRekjvdjjfiddBUS4EwZtIv7XahBWa8vukj04PX5Jq7E3wfWQe0ngp6KnwNSjC8ISLH6Tq00Eq6V05mI"); // <-- Make sure your key is here

exports.createPaymentIntent = onCall(async (request) => {
  // For v2 onCall functions, the data is in request.data
  const amount = request.data.amount;

  // Check if the user is authenticated
  if (!request.auth) {
    logger.error("User is not authenticated.");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  logger.info(`Creating payment intent for amount: ${amount}`);

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: "myr",
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    logger.error("Stripe Error:", error);
    throw new functions.https.HttpsError("internal", "Could not create payment intent.", error.message);
  }
});