const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = 3000;

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'todoapp',
  user: process.env.DB_USER || 'todoapp',
  password: process.env.DB_PASSWORD || 'todoapp123',
});

// Initialize database
async function initDB() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Database initialization error:', err);
  }
}

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// POST /addTask
app.post('/addTask', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Task name is required" });
    }
    
    const result = await pool.query(
      'INSERT INTO tasks (name) VALUES ($1) RETURNING *',
      [name]
    );
    
    const tasks = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json({ message: "Task added", task: result.rows[0], tasks: tasks.rows });
  } catch (err) {
    console.error('Error adding task:', err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /listTasks
app.get('/listTasks', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json({ tasks: result.rows });
  } catch (err) {
    console.error('Error fetching tasks:', err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// DELETE /deleteTask
app.delete('/deleteTask', async (req, res) => {
  try {
    const { id } = req.body;
    if (!id) {
      return res.status(400).json({ error: "Task ID is required" });
    }
    
    const result = await pool.query('DELETE FROM tasks WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Task not found" });
    }
    
    const tasks = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json({ message: "Task deleted", tasks: tasks.rows });
  } catch (err) {
    console.error('Error deleting task:', err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Start server
app.listen(port, async () => {
  await initDB();
  console.log(`Tasks API listening at http://localhost:${port}`);
});
