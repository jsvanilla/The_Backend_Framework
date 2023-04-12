const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  console.log('Hello, world!');
  res.send('Hello, world!');
});

app.post('/', (req, res) => {
  const { name } = req.body;
  console.log(`Hello, ${name}!`);
  res.send(`Hello, ${name}!`);
});

app.put('/:id', (req, res) => {
  const { id } = req.params;
  const { name } = req.body;
  console.log(`User ${id} updated with name ${name}`);
  res.send(`User ${id} updated with name ${name}`);
});

app.patch('/:id', (req, res) => {
  const { id } = req.params;
  const { name } = req.body;
  console.log(`User ${id} partially updated with name ${name}`);
  res.send(`User ${id} partially updated with name ${name}`);
});

const port = 3000;
app.listen(port, () => {
  console.log(`Server started on port ${port}`);
});
