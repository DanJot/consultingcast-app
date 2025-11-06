const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000; // Usa PORT do ambiente ou 3000

// Configuração MySQL (lê do ambiente ou usa valores padrão)
const DB_CONFIG = {
  host: process.env.DB_HOST || '10.1.55.10',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'luis',
  password: process.env.DB_PASSWORD || 'Admin1234',
};

// Middleware
app.use(cors()); // Permite pedidos do browser
app.use(express.json());

// Helper: cria conexão MySQL
async function getConnection(databaseName) {
  return mysql.createConnection({
    ...DB_CONFIG,
    database: databaseName,
  });
}

// Helper: normaliza nome da BD (igual ao Flutter)
function normalizeDbName(dbName) {
  let db = dbName.trim();
  if (!db.startsWith('_')) db = '_' + db;
  if (!db.endsWith('_mobile')) db = db + '_mobile';
  return db;
}

// ========== ENDPOINTS ==========

// POST /login
app.post('/login', async (req, res) => {
  try {
    const { email, password, database } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email e password são obrigatórios',
      });
    }

    const dbName = database || 'consultingcast2';
    const conn = await getConnection(dbName);

    try {
      // Busca utilizador
      const [rows] = await conn.execute(
        'SELECT id, email, `password` FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1',
        [email.trim()]
      );

      if (rows.length === 0) {
        return res.json({ success: false, error: 'Credenciais inválidas' });
      }

      const user = rows[0];
      const storedPass = user.password || '';
      const inputPass = password.trim();

      // Valida password (bcrypt ou texto plano)
      let passwordMatches = false;
      if (storedPass.startsWith('$2y$') || storedPass.startsWith('$2a$') || storedPass.startsWith('$2b$')) {
        try {
          passwordMatches = await bcrypt.compare(inputPass, storedPass);
        } catch (err) {
          passwordMatches = false;
        }
      } else {
        passwordMatches = storedPass === inputPass;
      }

      if (!passwordMatches) {
        return res.json({ success: false, error: 'Credenciais inválidas' });
      }

      // Inferir nome do email
      const inferredName = user.email.includes('@')
        ? user.email.split('@')[0]
        : user.email;

      res.json({
        success: true,
        user: {
          id: user.id.toString(),
          email: user.email,
          name: inferredName,
        },
      });
    } finally {
      await conn.end();
    }
  } catch (error) {
    console.error('Erro em /login:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro interno do servidor',
    });
  }
});

// POST /companies
app.post('/companies', async (req, res) => {
  try {
    const { userId, database } = req.body;

    console.log(`[API] /companies - userId: ${userId}, database: ${database || 'efatura'}`);
    console.log(`[API] /companies - userId type: ${typeof userId}, value: ${JSON.stringify(userId)}`);

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'userId é obrigatório',
      });
    }

    const dbName = database || 'efatura';
    const conn = await getConnection(dbName);

    try {
      // Primeiro, vamos verificar se há empresas para esse userId
      const [checkRows] = await conn.execute(
        `SELECT COUNT(*) as total FROM fatura_credential WHERE id_user_cc = ?`,
        [userId]
      );
      console.log(`[API] /companies - Total registos na tabela para userId ${userId}: ${checkRows[0].total}`);

      const [checkRowsEstado] = await conn.execute(
        `SELECT COUNT(*) as total FROM fatura_credential WHERE id_user_cc = ? AND estado = 1`,
        [userId]
      );
      console.log(`[API] /companies - Total registos com estado=1 para userId ${userId}: ${checkRowsEstado[0].total}`);

      // Busca empresas da fatura_credential
      const [rows] = await conn.execute(
        `SELECT DISTINCT 
          fc.nif AS company_id,
          fc.nome_empresa AS company_name,
          fc.nif AS company_nif
        FROM fatura_credential fc
        WHERE fc.id_user_cc = ? AND fc.estado = 1
        ORDER BY fc.nome_empresa`,
        [userId]
      );

      console.log(`[API] /companies - Encontradas ${rows.length} empresas para userId: ${userId}`);
      if (rows.length > 0) {
        console.log(`[API] /companies - Primeira empresa: ${JSON.stringify(rows[0])}`);
      }

      const companies = rows.map((row) => ({
        company_id: row.company_id?.toString() || '',
        company_name: row.company_name || '',
        company_nif: row.company_nif?.toString() || '',
      }));

      res.json({
        success: true,
        companies: companies,
      });
    } finally {
      await conn.end();
    }
  } catch (error) {
    console.error('Erro em /companies:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro interno do servidor',
    });
  }
});

// POST /user/nifs - Busca NIFs associados a um utilizador
app.post('/user/nifs', async (req, res) => {
  try {
    const { userId, database } = req.body;

    console.log(`[API] /user/nifs - userId: ${userId}, database: ${database || 'consultingcast2'}`);

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'userId é obrigatório',
      });
    }

    const dbName = database || 'consultingcast2';
    const conn = await getConnection(dbName);

    try {
      // Busca NIFs na tabela user_nifs
      const [rows] = await conn.execute(
        `SELECT DISTINCT un.nif 
         FROM user_nifs un 
         WHERE un.user_id = ? 
         ORDER BY un.nif`,
        [userId]
      );

      console.log(`[API] /user/nifs - Encontrados ${rows.length} NIFs para userId: ${userId}`);

      const nifs = rows
        .map((row) => row.nif?.toString() || '')
        .filter((nif) => nif.length > 0);

      res.json({
        success: true,
        nifs: nifs,
      });
    } finally {
      await conn.end();
    }
  } catch (error) {
    console.error('Erro em /user/nifs:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro interno do servidor',
    });
  }
});

// POST /companies/by-nifs - Busca empresas por lista de NIFs
app.post('/companies/by-nifs', async (req, res) => {
  try {
    const { nifs, database } = req.body;

    console.log(`[API] /companies/by-nifs - NIFs: ${JSON.stringify(nifs)}, database: ${database || 'efatura'}`);

    if (!nifs || !Array.isArray(nifs) || nifs.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'nifs é obrigatório e deve ser um array não vazio',
      });
    }

    const dbName = database || 'efatura';
    const conn = await getConnection(dbName);

    try {
      // Cria placeholders dinâmicos para IN clause
      const placeholders = nifs.map(() => '?').join(',');
      
      // Busca empresas na tabela fatura_credential
      const [rows] = await conn.execute(
        `SELECT DISTINCT 
          fc.nif AS company_id,
          fc.nome_empresa AS company_name,
          fc.nif AS company_nif
        FROM fatura_credential fc
        WHERE fc.nif IN (${placeholders})
        ORDER BY fc.nome_empresa`,
        nifs
      );

      console.log(`[API] /companies/by-nifs - Encontradas ${rows.length} empresas para ${nifs.length} NIFs`);

      const companies = rows.map((row) => ({
        company_id: row.company_id?.toString() || '',
        company_name: row.company_name || '',
        company_nif: row.company_nif?.toString() || '',
      }));

      res.json({
        success: true,
        companies: companies,
      });
    } finally {
      await conn.end();
    }
  } catch (error) {
    console.error('Erro em /companies/by-nifs:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro interno do servidor',
    });
  }
});

// POST /sales/snapshot
app.post('/sales/snapshot', async (req, res) => {
  try {
    const { database, ano, mes, mode } = req.body;

    if (!database) {
      return res.status(400).json({
        success: false,
        error: 'database é obrigatório',
      });
    }

    const dbName = normalizeDbName(database);
    const conn = await getConnection(dbName);

    try {
      let query, params;

      if (ano && mes) {
        // Período específico
        query = `SELECT ano, mes, VENDAS_AC AS vendas_acumuladas, 
                 VENDAS_N_1 AS vendas_mes_ano_anterior
                 FROM resultados_mensais 
                 WHERE ano = ? AND mes = ? 
                 LIMIT 1`;
        params = [ano, mes];
      } else {
        // Modo automático (último período fechado ou corrente)
        const useMode = mode || 'last_closed';
        if (useMode === 'last_closed') {
          // Último período fechado (mês anterior ao atual)
          const now = new Date();
          const targetMonth = now.getMonth(); // 0-11
          const targetYear = now.getFullYear();
          const prevMonth = targetMonth === 0 ? 12 : targetMonth;
          const prevYear = targetMonth === 0 ? targetYear - 1 : targetYear;

          query = `SELECT ano, mes, VENDAS_AC AS vendas_acumuladas,
                   VENDAS_N_1 AS vendas_mes_ano_anterior
                   FROM resultados_mensais
                   WHERE ano = ? AND mes = ?
                   LIMIT 1`;
          params = [prevYear, prevMonth];
        } else {
          // current_mtd - mês atual
          const now = new Date();
          query = `SELECT ano, mes, VENDAS_AC AS vendas_acumuladas,
                   VENDAS_N_1 AS vendas_mes_ano_anterior
                   FROM resultados_mensais
                   WHERE ano = ? AND mes = ?
                   LIMIT 1`;
          params = [now.getFullYear(), now.getMonth() + 1];
        }
      }

      const [rows] = await conn.execute(query, params);

      if (rows.length === 0) {
        return res.json({
          success: true,
          data: null,
        });
      }

      res.json({
        success: true,
        data: {
          ano: rows[0].ano,
          mes: rows[0].mes,
          vendas_acumuladas: parseFloat(rows[0].vendas_acumuladas) || 0,
          vendas_mes_ano_anterior: parseFloat(rows[0].vendas_mes_ano_anterior) || 0,
        },
      });
    } finally {
      await conn.end();
    }
  } catch (error) {
    console.error('Erro em /sales/snapshot:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro interno do servidor',
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'API está a funcionar!',
    timestamp: new Date().toISOString()
  });
});

// Inicia servidor
app.listen(PORT, () => {
  console.log(`🚀 API a correr em http://localhost:${PORT}`);
  console.log(`📋 Endpoints disponíveis:`);
  console.log(`   POST /login`);
  console.log(`   POST /companies`);
  console.log(`   POST /user/nifs`);
  console.log(`   POST /companies/by-nifs`);
  console.log(`   POST /sales/snapshot`);
  console.log(`   GET  /health`);
  console.log(`\n💡 Para produção, configura variáveis de ambiente:`);
  console.log(`   DB_HOST, DB_PORT, DB_USER, DB_PASSWORD`);
});
