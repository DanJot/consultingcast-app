# 📋 Guia Completo - Setup Completo

## ✅ Passo 1: ngrok já está instalado!

Pasta: `C:\Users\djcas\Documents\ConsultingCast\ngrok\`

---

## 🔐 Passo 2: Configurar ngrok (Fazer UMA VEZ)

1. **Criar conta ngrok:**
   - Vai a: https://dashboard.ngrok.com/signup
   - Regista-te (grátis)
   - Faz login

2. **Obter authtoken:**
   - No dashboard, vai a: https://dashboard.ngrok.com/get-started/your-authtoken
   - Copia o authtoken (tipo: `ngrok authtoken xxxxxx`)

3. **Configurar:**
   - Executa: `setup-ngrok.bat` (na pasta ngrok)
   - Ou manualmente:
   ```powershell
   cd C:\Users\djcas\Documents\ConsultingCast\ngrok
   .\ngrok.exe config add-authtoken <seu-token>
   ```

---

## 🚀 Passo 3: Iniciar Túnel MySQL

1. Executa: `start-tunnel.bat` (na pasta ngrok)
   - Ou manualmente:
   ```powershell
   cd C:\Users\djcas\Documents\ConsultingCast\ngrok
   .\ngrok.exe tcp 3306
   ```

2. **Vai aparecer algo como:**
   ```
   Forwarding  tcp://0.tcp.ngrok.io:12345 -> localhost:3306
   ```

3. **Copia a URL:** `0.tcp.ngrok.io:12345`
   - Guarda esta informação - vais precisar!

---

## ☁️ Passo 4: Deploy API no Railway

### 4.1 Criar Conta Railway
1. Vai a: https://railway.app
2. Clica "Start a New Project"
3. Faz login com GitHub

### 4.2 Deploy API
1. Clica "New Project" → "Deploy from GitHub repo"
2. Se não tens GitHub:
   - Clica "Empty Project"
   - Depois "Deploy from GitHub repo" → cria repo novo
3. Railway detecta automaticamente Node.js

### 4.3 Configurar Variáveis de Ambiente
Na Railway, vai a "Variables" e adiciona:

```
DB_HOST=0.tcp.ngrok.io
DB_PORT=12345
DB_USER=luis
DB_PASSWORD=Admin1234
```

**⚠️ IMPORTANTE:** Usa a URL que ngrok deu (pode ser diferente de `12345`)

### 4.4 Obter URL da API
Railway vai dar uma URL tipo: `https://seu-projeto.up.railway.app`
**Guarda esta URL!**

---

## 📱 Passo 5: Atualizar App Flutter

1. Abre `app2/lib/services/auth_service.dart`

2. Procura a linha:
```dart
const String kApiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:3000');
```

3. Muda para:
```dart
const String kApiBase = String.fromEnvironment(
  'API_BASE', 
  defaultValue: 'https://seu-projeto.up.railway.app' // <-- URL da Railway
);
```

---

## ✅ Passo 6: Testar

1. **Certifica-te que:**
   - ✅ ngrok está a correr (túnel MySQL ativo)
   - ✅ API está deployada no Railway
   - ✅ Variáveis de ambiente estão corretas
   - ✅ App Flutter tem a URL correta

2. **Testa no browser:**
   ```bash
   flutter run -d chrome
   ```

3. **Tenta fazer login!**

---

## 🔄 Para Manter Tudo Funcionando

### ngrok sempre ligado:
- Executa `start-tunnel.bat` sempre que ligas o PC
- Ou configura como serviço Windows (Task Scheduler)

### Se URL do ngrok mudar:
- Com plano grátis, URL muda quando reinicias ngrok
- Atualiza `DB_HOST` e `DB_PORT` no Railway

---

## 💰 Upgrade para URL Fixa (Opcional)

Plano ngrok "Starter" ($8/mês):
- URL não muda nunca
- Mais estável para produção
- Vale a pena se vais usar em produção

---

## 🆘 Problemas?

**"Não conecta ao MySQL":**
- Verifica se ngrok está a correr
- Verifica se porta 3306 está correta
- Verifica variáveis no Railway

**"API não responde":**
- Verifica logs no Railway
- Testa `/health` no browser
- Verifica se Railway está deployado

**"URL mudou":**
- Atualiza variáveis no Railway
- Ou usa plano pago ngrok

---

## 📝 Checklist Final

- [ ] ngrok instalado ✅
- [ ] Conta ngrok criada
- [ ] ngrok configurado (authtoken)
- [ ] Túnel MySQL a funcionar
- [ ] Conta Railway criada
- [ ] API deployada no Railway
- [ ] Variáveis de ambiente configuradas
- [ ] App Flutter atualizada
- [ ] Testado no browser

---

## 🎉 Pronto!

Agora a tua app funciona:
- ✅ Android: MySQL direto (já funciona)
- ✅ Browser: API cloud → ngrok → MySQL (sempre disponível!)
- ✅ Produção: Pronto para Play Store e App Store

