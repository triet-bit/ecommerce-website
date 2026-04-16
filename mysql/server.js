const express = require('express');
const app = express();
app.use(express.json());

const authRoutes = require('./auth');
const productRoutes = require('./productRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});