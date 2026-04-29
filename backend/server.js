const express = require('express');
const cors = require('cors');
const app = express();
app.use(express.json());
app.use(cors())

const authRoutes = require('./auth');
const productRoutes = require('./productRoutes');
const orderRoutes = require('./orderRoutes')
const statsRoutes = require('./statsRoutes')
const addressRoutes = require('./addressRoutes');
const categoryRoutes = require('./categoryRoutes'); // P10: Add categoryRoutes

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders',orderRoutes); 
app.use('/api/stats',statsRoutes);
app.use('/api', addressRoutes);
app.use('/api/categories', categoryRoutes); // P10: Route danh mục
const PORT = 3000;


app.listen(PORT, () => {
    console.log(`Server đang chạy tại http://localhost:${PORT}`);
});