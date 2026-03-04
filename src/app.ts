import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import authRoutes from './routes/auth';
import profileRoutes from './routes/profile';

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// TODO: Configure MongoDB connection string
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/underwater-basket-weaving');

app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);

app.use('/uploads', express.static('uploads'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;