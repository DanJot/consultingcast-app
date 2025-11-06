# 🔒 Cloudflare Tunnel - Guia Completo

Permite que a API cloud (Railway/Render) aceda ao MySQL (`10.1.55.10`) de forma segura SEM abrir portas diretamente.

## 📋 Pré-requisitos

- Conta Cloudflare (grátis): https://cloudflare.com
- Servidor/computador onde está o MySQL (`10.1.55.10`) precisa estar ligado

---

## 🚀 Passo 1: Criar Conta Cloudflare

1. Vai a https://dash.cloudflare.com/sign-up
2. Cria conta grátis (não precisa de domínio próprio)

---

## 📥 Passo 2: Instalar Cloudflared

### Windows (onde está o MySQL):

1. **Download:**
   - Vai a: https://github.com/cloudflare/cloudflared/releases
   - Download `cloudflared-windows-amd64.exe`
   - Renomeia para `cloudflared.exe`
   - Coloca numa pasta (ex: `C:\cloudflared\`)

2. **Ou via PowerShell (mais fácil):**
```powershell
# Abre PowerShell como Administrador
Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile "C:\cloudflared\cloudflared.exe"
```

### Linux (se MySQL está em servidor Linux):
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

---

## 🔐 Passo 3: Autenticar Cloudflare

1. Abre PowerShell/CMD na pasta onde está `cloudflared.exe`
2. Executa:
```powershell
.\cloudflared.exe login
```
3. Vai abrir browser → faz login na Cloudflare
4. Seleciona o domínio (se não tiveres, cria um grátis ou usa uma conta sem domínio)

---

## 🌐 Passo 4: Criar Túnel

1. Executa:
```powershell
.\cloudflared.exe tunnel create consultingcast-mysql
```

Isto cria um túnel chamado `consultingcast-mysql`

---

## 📝 Passo 5: Criar Ficheiro de Configuração

Cria ficheiro `config.yml` na mesma pasta:

```yaml
tunnel: consultingcast-mysql
credentials-file: C:\cloudflared\<tunnel-id>.json

ingress:
  # Expõe MySQL na porta 3306
  - hostname: mysql-tunnel.cloudflare.com
    service: tcp://10.1.55.10:3306
  
  # Catch-all
  - service: http_status:404
```

**IMPORTANTE:** Substitui `<tunnel-id>` pelo ID real que aparece quando crias o túnel.

**OU** usa o método mais simples:

```powershell
.\cloudflared.exe tunnel route dns consultingcast-mysql mysql-tunnel
```

---

## ▶️ Passo 6: Iniciar Túnel

### Opção A: Manual (para testes)
```powershell
.\cloudflared.exe tunnel run consultingcast-mysql
```

### Opção B: Como Serviço Windows (sempre ligado)
```powershell
.\cloudflared.exe service install
.\cloudflared.exe tunnel run consultingcast-mysql
```

O túnel vai mostrar uma URL tipo: `mysql-tunnel-xxxxx.trycloudflare.com`

---

## ⚙️ Passo 7: Configurar API Cloud

Agora a API precisa de usar o túnel em vez de `10.1.55.10` diretamente.

### No Railway/Render:

Adiciona variável de ambiente:
```
DB_HOST=mysql-tunnel-xxxxx.trycloudflare.com
DB_PORT=3306
DB_USER=luis
DB_PASSWORD=Admin1234
```

**MAS ESPERA!** Cloudflare Tunnel expõe como TCP, então precisas de usar a URL específica.

---

## 🔄 Alternativa Mais Simples: Túnel Local com ngrok

Se Cloudflare parecer complicado, usa **ngrok** (mais simples):

### Passo 1: Instalar ngrok
1. Vai a https://ngrok.com/download
2. Download para Windows
3. Extrai e coloca numa pasta

### Passo 2: Criar Conta (grátis)
1. Regista em https://dashboard.ngrok.com
2. Copia o authtoken

### Passo 3: Configurar
```powershell
.\ngrok.exe config add-authtoken <seu-token>
```

### Passo 4: Criar Túnel TCP
```powershell
.\ngrok.exe tcp 3306
```

Vai mostrar algo como:
```
Forwarding  tcp://0.tcp.ngrok.io:12345 -> localhost:3306
```

### Passo 5: Configurar API Cloud

No Railway/Render, usa:
```
DB_HOST=0.tcp.ngrok.io
DB_PORT=12345  # O número que ngrok dá
DB_USER=luis
DB_PASSWORD=Admin1234
```

**NOTA:** Com plano grátis ngrok, a URL muda cada vez que reinicias. Para URL fixa, precisas de plano pago ($8/mês).

---

## ✅ Recomendação Final

**Para desenvolvimento/testes:** Usa ngrok (mais fácil)

**Para produção:** 
- Cloudflare Tunnel (grátis, URL fixa se configurares DNS)
- Ou ngrok com plano pago para URL fixa

---

## 🔧 Configurar ngrok Como Serviço (Windows)

Para ngrok estar sempre ligado:

1. Cria ficheiro `start-ngrok.bat`:
```batch
@echo off
cd C:\caminho\para\ngrok
ngrok.exe tcp 3306
```

2. Usa Task Scheduler para executar ao iniciar Windows

---

## 📝 Checklist

- [ ] Cloudflare/ngrok instalado
- [ ] Túnel criado e a funcionar
- [ ] API cloud configurada com URL do túnel
- [ ] Testado conexão MySQL através do túnel
- [ ] Túnel configurado para iniciar automaticamente

---

## 🆘 Problemas Comuns

**"Não conecta ao MySQL":**
- Verifica se túnel está a correr
- Verifica se porta 3306 está correta
- Testa conexão local primeiro

**"URL muda sempre (ngrok free)":**
- Atualiza variáveis de ambiente na API cloud
- Ou usa plano pago ngrok/Cloudflare Tunnel com DNS

---

## 💡 Dica

Para desenvolvimento, usa ngrok. Para produção, considera Cloudflare Tunnel com DNS próprio (mais estável).

