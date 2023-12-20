const express = require('express');
const app = express();

// prints hello
app.get('/', (req, res) => {
  res.send('Test CI of App again. Please work');
});

app.get('/hello', (req, res) => {
  // Send a GET request to Backend B
  fetch('http://app-demo-2872-3146-backend-dev.azurewebsites.net/hello')
    .then(response => response.json())
    .then(data => {
      res.status(200).send(`Message from Backend B: ${data.message}`);
      console.log(data)
    });
});

app.listen(3001, () => {
  console.log('frontend listening on port 3001');
});