const express = require('express');
const app = express();


// prints hello
app.get('/', (req, res) => {
  res.send('Welcome to our application!');
});


// app.get('/hello', (req, res) => {
//     res.status(200).json({ message: 'Hello from Backend B!'});
// });

app.listen(3000, () => {
  console.log('Backend listening on port 3000');
});
