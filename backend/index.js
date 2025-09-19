const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory task storage
let tasks = [];

// POST /addTask
app.post('/addTask', (req, res) => {
  const { name } = req.body;
  if (!name) {
    return res.status(400).json({ error: "Task name is required" });
  }
  tasks.push(name);
  res.json({ message: "Task added", tasks });
});

// GET /listTasks
app.get('/listTasks', (req, res) => {
  res.json({ tasks });
});

// DELETE /deleteTask
app.delete('/deleteTask', (req, res) => {
  const { name } = req.body;
  if (!name) {
    return res.status(400).json({ error: "Task name is required" });
  }
  if (tasks.includes(name)) {
    tasks = tasks.filter(task => task !== name);
    return res.json({ message: "Task deleted", tasks });
  }
  res.status(404).json({ error: "Task not found", tasks });
});

// Start server
app.listen(port, () => {
  console.log(`Tasks API listening at http://localhost:${port}`);
});
