# ✅ Solução TCP Proxy + Cloudflare Tunnel

Criei uma solução completa para expor o MySQL via túnel TCP!

## 📋 Como Usar

### Passo 1: Iniciar Proxy TCP Local
```powershell
.\scripts\iniciar-proxy.bat
```

Isto cria um proxy em `localhost:3307` que reencaminha para `10.1.55.10:3306`

**Deixa este a correr!**

### Passo 2: Criar Túnel Cloudflare
Noutra janela PowerShell:
```powershell
.\scripts\criar-tunel-tcp.bat
```

Isto cria um túnel TCP temporário.

**⚠️ IMPORTANTE:** Copia a URL que aparece! Será algo como:
```
tcp://xxxxx.trycloudflare.com:xxxxx
```

### Passo 3: Configurar Railway

No Railway, usa a URL do túnel:
```
DB_HOST=xxxxx.trycloudflare.com
DB_PORT=xxxxx
DB_USER=root
DB_PASSWORD=<tua-password>
DB_NAME=consultingcast2
```

---

## ⚠️ Limitações

- **URL muda** cada vez que reinicias o túnel
- **Túnel temporário** - dura enquanto o processo estiver a correr
- Para URL fixa, precisas de túnel nomeado (requer domínio Cloudflare)

---

## 🎯 Status Atual

✅ Proxy TCP: **A CORRER** (porta 3307)
⏳ Túnel Cloudflare: Precisa ser iniciado manualmente

---

## 💡 Próximos Passos

1. **Agora:** Inicia o túnel Cloudflare (`.\scripts\criar-tunel-tcp.bat`)
2. **Copia a URL** que aparece
3. **Configura Railway** com essa URL
4. **Testa a app Web!**

---

**Quer que eu inicie o túnel agora ou prefere fazer manualmente?**

