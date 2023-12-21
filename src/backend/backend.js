const express = require('express');
const app = express();


// prints hello
app.get('/', (req, res) => {
  res.send('Welcome to our application! welcome');
});


app.get('/hello', (req, res) => {
    res.status(200).json({ message: 'Hello from Backend B!'});
    res.send('check your inbox ;)');
});

app.listen(3000, () => {
  console.log('Backend listening on port 3000');
});
