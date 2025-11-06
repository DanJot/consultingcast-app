# 🔒 Cloudflare Tunnel - Alternativa Gratuita (Sem Cartão!)

Cloudflare Tunnel é gratuito e não precisa de cartão para túneis TCP!

## ✅ Passo 1: Criar Conta Cloudflare

1. Vai a: https://dash.cloudflare.com/sign-up
2. Regista-te (grátis, não precisa de cartão)
3. Faz login

## 📥 Passo 2: Instalar Cloudflared

### Windows:

1. **Download:**
   - Vai a: https://github.com/cloudflare/cloudflared/releases/latest
   - Download: `cloudflared-windows-amd64.exe`
   - Renomeia para `cloudflared.exe`
   - Coloca em: `C:\cloudflared\`

2. **Ou via PowerShell:**
```powershell
# Cria pasta
New-Item -ItemType Directory -Path "C:\cloudflared" -Force

# Download
Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile "C:\cloudflared\cloudflared.exe"
```

## 🔐 Passo 3: Autenticar Cloudflare

```powershell
cd C:\cloudflared
.\cloudflared.exe login
```

Isto vai abrir browser → faz login na Cloudflare → autoriza.

## 🌐 Passo 4: Criar Túnel

```powershell
.\cloudflared.exe tunnel create consultingcast-mysql
```

Isto cria um túnel chamado `consultingcast-mysql`

## 🚀 Passo 5: Criar Configuração

Cria ficheiro `C:\cloudflared\config.yml`:

```yaml
tunnel: consultingcast-mysql
credentials-file: C:\cloudflared\<tunnel-id>.json

ingress:
  - service: tcp://10.1.55.10:3306
```

**IMPORTANTE:** Substitui `<tunnel-id>` pelo ID real que aparece quando crias o túnel.

**OU** usa método mais simples (sem ficheiro config):

```powershell
.\cloudflared.exe tunnel run consultingcast-mysql --url tcp://10.1.55.10:3306
```

## ▶️ Passo 6: Iniciar Túnel

```powershell
.\cloudflared.exe tunnel run consultingcast-mysql
```

Vai mostrar uma URL tipo: `tcp://consultingcast-mysql-xxxxx.trycloudflare.com:xxxxx`

## ⚙️ Passo 7: Usar no Railway

No Railway, configura variáveis:
```
DB_HOST=consultingcast-mysql-xxxxx.trycloudflare.com
DB_PORT=xxxxx
DB_USER=luis
DB_PASSWORD=Admin1234
```

---

## 🔄 Alternativa Mais Simples: LocalTunnel

Se Cloudflare parecer complicado, usa **LocalTunnel** (mais simples):

### Instalar:
```powershell
npm install -g localtunnel
```

### Criar Túnel:
```powershell
lt --port 3306
```

Vai mostrar URL tipo: `https://xxxxx.loca.lt`

**MAS:** LocalTunnel é HTTP/HTTPS, não TCP direto. Precisa de adaptação.

---

## 💡 Recomendação

**Cloudflare Tunnel** é a melhor opção:
- ✅ Gratuito
- ✅ Sem cartão
- ✅ TCP nativo
- ✅ Mais estável

Quer que eu ajude a configurar Cloudflare Tunnel passo a passo?

