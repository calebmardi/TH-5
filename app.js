const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Configurar EJS como motor de plantillas
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Datos de ejemplo para visualización
const sampleData = {
  sales: [
    { month: 'Enero', amount: 12000 },
    { month: 'Febrero', amount: 15000 },
    { month: 'Marzo', amount: 18000 },
    { month: 'Abril', amount: 14000 },
    { month: 'Mayo', amount: 20000 },
    { month: 'Junio', amount: 22000 }
  ],
  users: [
    { name: 'Juan Pérez', role: 'Admin', active: true },
    { name: 'María García', role: 'Usuario', active: true },
    { name: 'Carlos López', role: 'Usuario', active: false }
  ]
};

// Rutas
app.get('/', (req, res) => {
  res.render('index', { 
    title: 'DataVision App',
    message: 'Bienvenido a la aplicación de visualización de datos'
  });
});

app.get('/dashboard', (req, res) => {
  res.render('dashboard', {
    title: 'Dashboard - DataVision',
    salesData: sampleData.sales,
    userData: sampleData.users
  });
});

app.get('/api/sales', (req, res) => {
  res.json({
    success: true,
    data: sampleData.sales
  });
});

app.get('/api/users', (req, res) => {
  res.json({
    success: true,
    data: sampleData.users
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).render('error', {
    title: 'Página no encontrada',
    error: 'La página que buscas no existe'
  });
});

// Manejo de errores del servidor
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).render('error', {
    title: 'Error del servidor',
    error: 'Ha ocurrido un error interno del servidor'
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 DataVision App ejecutándose en puerto ${PORT}`);
  console.log(`📊 Dashboard disponible en: http://localhost:${PORT}/dashboard`);
  console.log(`🔍 Health check en: http://localhost:${PORT}/health`);
});

module.exports = app;