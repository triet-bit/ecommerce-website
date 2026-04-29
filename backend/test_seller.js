const jwt = require('jsonwebtoken');
const token = jwt.sign(
    { id: 11, email: 'seller.klong@gmail.com', role: 'seller' },
    '12345',
    { expiresIn: '1h' }
);
console.log(token);
