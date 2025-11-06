# API Node.js para ConsultingCast App

Servidor para permitir que a app Flutter funcione no browser (Web) e em produção.

## 🚀 Instalação Local

```bash
cd api-server
npm install
npm start
```

## ☁️ Deploy Online (Railway ou Render)

### Opção 1: Railway (Recomendado - Grátis)

1. Cria conta em https://railway.app
2. Clica em "New Project" → "Deploy from GitHub repo"
3. Conecta o repositório (ou faz upload dos ficheiros)
4. Railway detecta automaticamente Node.js
5. Adiciona variáveis de ambiente:
   - `DB_HOST`: 10.1.55.10
   - `DB_PORT`: 3306
   - `DB_USER`: luis
   - `DB_PASSWORD`: Admin1234
6. Railway dá-te uma URL tipo: `https://seu-projeto.railway.app`

### Opção 2: Render (Grátis)

1. Cria conta em https://render.com
2. Clica em "New" → "Web Service"
3. Conecta GitHub ou faz upload
4. Configura:
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Adiciona variáveis de ambiente (mesmas que acima)
6. Render dá URL tipo: `https://seu-projeto.onrender.com`

## 🔧 Configuração Variáveis de Ambiente

Para produção, configura estas variáveis no serviço de hosting:

- `DB_HOST`: Endereço do servidor MySQL
- `DB_PORT`: Porta MySQL (normalmente 3306)
- `DB_USER`: Utilizador MySQL
- `DB_PASSWORD`: Password MySQL
- `PORT`: Porta do servidor (geralmente automático)

## 📱 Atualizar App Flutter

Depois de fazer deploy, atualiza o `auth_service.dart`:

```dart
const String kApiBase = String.fromEnvironment(
  'API_BASE', 
  defaultValue: 'https://seu-projeto.railway.app' // ou .onrender.com
);
```

Ou compila com:
```bash
flutter build web --dart-define=API_BASE=https://seu-projeto.railway.app
```

## 📝 Notas Importantes

⚠️ **IMPORTANTE**: O servidor MySQL precisa estar acessível da internet!

Se o MySQL (`10.1.55.10`) está numa rede local:
- Precisas de abrir a porta 3306 no firewall
- Ou usar um túnel (ngrok, Cloudflare Tunnel)
- Ou migrar MySQL para um servidor cloud

## 🔒 Segurança

Para produção, considera:
- Adicionar rate limiting
- Usar HTTPS (Railway/Render já incluem)
- Validar inputs
- Implementar autenticação JWT
- Logs de segurança
