import express from "express";

// Create an instance of Express
const app = express();

// Define a sample route
app.get("/api/hello", (req, res) => {
  res.json({ message: "Hello, world!" });
});

// Start the server
const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
