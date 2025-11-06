# 🎯 SOLUÇÃO GRATUITA - API HTTP + Túnel HTTP

## ✅ Como Funciona

1. **API Node.js** corre localmente (porta 3000)
   - Conecta ao MySQL localmente (`10.1.55.10:3306`)
   - Expõe endpoints HTTP (`/login`, `/companies`, etc)

2. **Túnel HTTP** expõe a API na internet
   - Cloudflare Quick Tunnel (HTTP) - **GRATUITO**
   - LocalTunnel - **GRATUITO**
   - Serveo - **GRATUITO**

3. **Flutter Web** usa URL do túnel HTTP
   - Muito mais simples que TCP!
   - Mais estável
   - Funciona sempre!

---

## 🚀 Passos

### 1. Iniciar API Node.js
```powershell
cd api-server
node server.js
```

### 2. Criar Túnel HTTP (escolhe um):

**Opção A: Cloudflare Quick Tunnel HTTP**
```powershell
cd cloudflared
.\cloudflared.exe tunnel --url http://localhost:3000
```

**Opção B: LocalTunnel**
```powershell
npx localtunnel --port 3000
```

**Opção C: Serveo**
```powershell
ssh -R 80:localhost:3000 serveo.net
```

### 3. Copiar URL do Túnel
A URL será algo como:
- `https://xxxxx.trycloudflare.com` (Cloudflare)
- `https://xxxxx.loca.lt` (LocalTunnel)
- `https://xxxxx.serveo.net` (Serveo)

### 4. Configurar Flutter Web
```powershell
flutter run -d chrome --dart-define=API_BASE=https://xxxxx.trycloudflare.com
```

---

## ✅ Vantagens

- ✅ **100% GRATUITO**
- ✅ **Muito mais simples** (HTTP vs TCP)
- ✅ **Mais estável**
- ✅ **Funciona com qualquer túnel HTTP**

---

## 🎯 Vamos Começar!

