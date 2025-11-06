# 🚀 Opções Gratuitas para Deploy da ConsultingCast

## Problema Atual
- A aplicação só funciona enquanto o PC está ligado (`localhost:8080`)
- Não é acessível externamente quando o PC desliga

## ✅ Soluções Gratuitas Disponíveis

### 1. **Railway.app** ⭐ RECOMENDADO
- **Gratuito**: $5 grátis por mês (suficiente para testes)
- **Vantagens**: 
  - Deploy automático via GitHub
  - Suporta Node.js e Flutter Web
  - Base de dados MySQL incluída
  - SSL automático
- **Como usar**:
  1. Cria conta em https://railway.app
  2. Conecta repositório GitHub
  3. Adiciona serviços: API Node.js + Flutter Web
  4. Configura variáveis de ambiente (DB_HOST, etc.)

### 2. **Render.com**
- **Gratuito**: 750 horas/mês
- **Vantagens**: 
  - Deploy automático
  - SSL automático
  - Suporta Node.js
- **Limitação**: O serviço "hiberna" após 15min sem uso (primeira requisição demora alguns segundos)

### 3. **Fly.io**
- **Gratuito**: 3 VMs grátis
- **Vantagens**: 
  - Muito rápido
  - Suporta Docker
  - Globally distributed
- **Ideal para**: APIs e apps web

### 4. **Vercel** (só para Flutter Web)
- **Gratuito**: Ilimitado para projetos pessoais
- **Vantagens**: 
  - Deploy instantâneo
  - CDN global
  - SSL automático
- **Limitação**: Só hospeda frontend (Flutter Web). A API precisa estar noutro lugar.

### 5. **Netlify** (só para Flutter Web)
- **Gratuito**: Ilimitado
- **Vantagens**: 
  - Deploy automático via Git
  - SSL automático
  - Formulários e funções serverless
- **Limitação**: Só frontend. API precisa estar noutro serviço.

### 6. **Cloudflare Pages** (só para Flutter Web)
- **Gratuito**: Ilimitado
- **Vantagens**: 
  - CDN global extremamente rápido
  - SSL automático
  - Integração com GitHub
- **Limitação**: Só frontend.

### 7. **GitHub Pages** (só para Flutter Web estático)
- **Gratuito**: Totalmente gratuito
- **Vantagens**: 
  - Integrado com GitHub
  - SSL automático
- **Limitação**: Só serve arquivos estáticos (Flutter Web build)

---

## 📋 Estratégia Recomendada (Completamente Gratuita)

### Opção A: Tudo no Railway.app
1. **API Node.js** → Railway.app
2. **Flutter Web** → Railway.app (como serviço estático)
3. **MySQL** → Railway.app PostgreSQL (ou MySQL externo)

### Opção B: Combo (Mais rápido)
1. **API Node.js** → Railway.app ou Fly.io
2. **Flutter Web** → Vercel ou Netlify (deploy mais rápido)
3. **MySQL** → Railway.app ou MySQL externo (se já tiver)

### Opção C: Tudo Divulgado Separadamente
1. **API Node.js** → Render.com
2. **Flutter Web** → Vercel
3. **MySQL** → Servidor MySQL existente (10.1.55.10)

---

## 🛠️ Passos para Deploy no Railway.app (Exemplo)

### 1. Preparar API Node.js
```bash
# No diretório da API Node.js, cria railway.json ou procfile
# railway.json:
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "node server.js"
  }
}
```

### 2. Preparar Flutter Web
```bash
# Build Flutter Web
flutter build web --release

# Railway serve os arquivos estáticos automaticamente
```

### 3. Configurar Variáveis de Ambiente no Railway
- `DB_HOST`: 10.1.55.10
- `DB_PORT`: 3306
- `DB_USER`: luis
- `DB_PASSWORD`: Admin1234
- `NODE_ENV`: production

### 4. Deploy
1. Conecta GitHub ao Railway
2. Seleciona o repositório
3. Railway detecta automaticamente Node.js/Flutter
4. Adiciona variáveis de ambiente
5. Deploy automático!

---

## 🔧 Arquivos Necessários para Deploy

### Para API Node.js:
- `package.json` com scripts
- `server.js` ou `index.js`
- `.env` ou variáveis de ambiente

### Para Flutter Web:
- `flutter build web` → gera `build/web/`
- Upload de `build/web/` para serviço de hosting

---

## ⚠️ Nota Importante sobre MySQL

Se a base de dados MySQL está em `10.1.55.10` (servidor privado), precisas garantir que:
1. O servidor MySQL aceita conexões externas
2. O firewall permite conexões do serviço de deploy
3. Ou migras para uma base de dados hospedada (Railway PostgreSQL, PlanetScale MySQL, etc.)

---

## 📝 Próximos Passos

1. **Escolhe uma opção** de deploy (recomendo Railway.app)
2. **Prepara os arquivos** de configuração
3. **Faz deploy** da API primeiro
4. **Atualiza** a URL da API na app Flutter
5. **Faz deploy** da app Flutter Web
6. **Testa** tudo funcionando

---

## 🆘 Ajuda

Se precisares de ajuda com o deploy específico, diz qual serviço escolheste e eu ajudo com os detalhes!


