# 🔄 TCP Proxy - Solução Simples

Servidor Node.js que faz proxy TCP para MySQL.

## 🚀 Como Usar

### 1. Iniciar Proxy Local
```powershell
cd tcp-proxy
node server.js
```

Isto cria um proxy em `localhost:3307` que reencaminha para `10.1.55.10:3306`

### 2. Criar Túnel Externo

Depois de iniciar o proxy, cria túnel para a porta 3307:

**Opção A: ngrok (com cartão)**
```powershell
ngrok tcp 3307
```

**Opção B: Cloudflare quick tunnel**
```powershell
cloudflared tunnel --url tcp://localhost:3307
```

### 3. Configurar Railway

No Railway, usa a URL do túnel:
```
DB_HOST=<host-do-tunel>
DB_PORT=<porta-do-tunel>
```

---

## ⚠️ IMPORTANTE

Este proxy corre LOCALMENTE. Precisa de:
1. ✅ Proxy Node.js a correr (localhost:3307)
2. ✅ Túnel externo (ngrok/Cloudflare) para expor porta 3307
3. ✅ Railway com URL do túnel

---

## 💡 Alternativa Mais Simples

Para desenvolvimento: **Continua Android Studio** ✅

Para produção: Quando precisares, configuramos então!

