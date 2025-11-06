# 🚀 Guia de Deploy - API ConsultingCast

## Opção 1: Railway (Mais Fácil) ⭐

### Passo 1: Criar Conta
1. Vai a https://railway.app
2. Clica em "Start a New Project"
3. Faz login com GitHub (mais fácil)

### Passo 2: Deploy
1. Clica em "New Project"
2. Escolhe "Deploy from GitHub repo"
3. Se não tens GitHub:
   - Clica em "Empty Project"
   - Depois "Deploy from GitHub repo" → cria repo novo
   - Ou faz upload manual dos ficheiros

### Passo 3: Configurar
1. Railway detecta automaticamente que é Node.js
2. Vai a "Variables" → adiciona:
   ```
   DB_HOST=10.1.55.10
   DB_PORT=3306
   DB_USER=luis
   DB_PASSWORD=Admin1234
   ```
3. Railway dá-te uma URL tipo: `https://seu-projeto.up.railway.app`

### Passo 4: Atualizar App Flutter
No `auth_service.dart`, muda:
```dart
const String kApiBase = String.fromEnvironment(
  'API_BASE', 
  defaultValue: 'https://seu-projeto.up.railway.app'
);
```

---

## Opção 2: Render (Alternativa)

### Passo 1: Criar Conta
1. Vai a https://render.com
2. Faz login com GitHub

### Passo 2: Deploy
1. Clica em "New" → "Web Service"
2. Conecta GitHub repo (ou upload manual)
3. Configura:
   - **Name**: consultingcast-api
   - **Runtime**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Instance Type**: Free

### Passo 3: Variáveis de Ambiente
Em "Environment Variables", adiciona:
```
DB_HOST=10.1.55.10
DB_PORT=3306
DB_USER=luis
DB_PASSWORD=Admin1234
```

### Passo 4: Deploy
1. Clica em "Create Web Service"
2. Render dá URL tipo: `https://seu-projeto.onrender.com`

---

## ⚠️ IMPORTANTE: MySQL Precisa Estar Acessível

O servidor MySQL (`10.1.55.10`) precisa estar acessível da internet!

### Se está numa rede local:
1. **Abra a porta 3306** no router/firewall
2. **Ou use Cloudflare Tunnel** (grátis):
   - Instala Cloudflare Tunnel
   - Expõe `10.1.55.10:3306` de forma segura

### Se não pode expor MySQL:
1. Migra MySQL para um servidor cloud (ex: PlanetScale, Railway DB)
2. Ou usa um túnel seguro (Cloudflare Tunnel)

---

## 📱 Depois do Deploy

### Atualizar App Flutter para Produção

**Opção A:** Mudar no código:
```dart
// auth_service.dart
const String kApiBase = 'https://seu-projeto.up.railway.app';
```

**Opção B:** Compilar com variável:
```bash
flutter build web --dart-define=API_BASE=https://seu-projeto.up.railway.app
```

---

## ✅ Checklist

- [ ] Conta criada no Railway/Render
- [ ] API deployada
- [ ] Variáveis de ambiente configuradas
- [ ] MySQL acessível da internet (ou túnel configurado)
- [ ] App Flutter atualizada com nova URL
- [ ] Testado no browser

---

## 💰 Custos

- **Railway**: Grátis até 500 horas/mês + $5 crédito grátis
- **Render**: Grátis, mas pode "dormir" após inatividade (acorda quando há pedido)

---

## 🆘 Problemas Comuns

**API não conecta ao MySQL:**
- Verifica se MySQL está acessível da internet
- Verifica firewall/porta 3306
- Usa túnel se necessário

**App não funciona:**
- Verifica se URL da API está correta
- Testa `/health` no browser
- Verifica logs no Railway/Render

