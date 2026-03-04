import express from 'express';
import cors from 'cors';
import mongoose from 'mongoose';
import authRoutes from './routes/auth';
import profileRoutes from './routes/profile';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);

// TODO: Add MongoDB connection
// mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/underwater-basket-weaving');

export default app;