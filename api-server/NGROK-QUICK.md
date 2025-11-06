# 🚀 Guia Rápido: ngrok para MySQL (5 minutos)

Permite que a API cloud aceda ao MySQL sem mexer na BD.

## ⚡ Passos Rápidos

### 1. Download ngrok
- Vai a: https://ngrok.com/download
- Download Windows → extrai

### 2. Criar Conta (grátis)
- Regista em: https://dashboard.ngrok.com/signup
- Copia o **authtoken** (tipo: `ngrok authtoken xxxxx`)

### 3. Configurar
```powershell
# Abre PowerShell na pasta do ngrok
.\ngrok.exe config add-authtoken <seu-token>
```

### 4. Criar Túnel MySQL
```powershell
.\ngrok.exe tcp 3306
```

Vai mostrar:
```
Forwarding  tcp://0.tcp.ngrok.io:12345 -> localhost:3306
```

### 5. Configurar API Cloud (Railway/Render)

Adiciona variáveis de ambiente:
```
DB_HOST=0.tcp.ngrok.io
DB_PORT=12345
DB_USER=luis
DB_PASSWORD=Admin1234
```

**NOTA:** Com plano grátis, a URL muda quando reinicias ngrok. Tens que atualizar as variáveis.

### 6. Manter ngrok Sempre Ligado

Cria ficheiro `start-ngrok.bat`:
```batch
@echo off
cd C:\caminho\para\ngrok
ngrok.exe tcp 3306
pause
```

E inicia quando o PC liga (ou usa Task Scheduler).

---

## 💰 Para URL Fixa (Recomendado para Produção)

Plano ngrok "Starter" ($8/mês) dá URL fixa:
- URL não muda nunca
- Mais estável para produção

---

## ✅ Pronto!

Agora a API cloud consegue aceder ao MySQL através do túnel ngrok!

