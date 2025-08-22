const jwt = require('jsonwebtoken');

// Middleware de vérification du token JWT
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ 
      success: false,
      message: "Accès refusé. Token manquant." 
    });
  }

  jwt.verify(token, process.env.JWT_SECRET || "votre_secret_tres_securise", (err, user) => {
    if (err) {
      return res.status(403).json({ 
        success: false,
        message: "Token invalide ou expiré." 
      });
    }
    req.user = user;
    next();
  });
};

// Middleware pour vérifier les rôles
const verifyRole = (roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ 
        success: false,
        message: "Accès non autorisé." 
      });
    }
    next();
  };
};

module.exports = {
  verifyToken,
  verifyRole
};
