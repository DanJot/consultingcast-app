# 🚀 Cloudflare Tunnel - Guia Rápido

## ✅ Cloudflared já está instalado!

## 📋 Passos (em ordem):

### 1. Autenticar Cloudflare
- Executa: `login-cloudflare.bat`
- Vai abrir browser → faz login → autoriza

### 2. Criar Túnel
- Executa: `criar-tunel.bat`
- Cria túnel chamado `consultingcast-mysql`

### 3. Iniciar Túnel
- Executa: `iniciar-tunel.bat`
- Mantém a janela aberta!
- Vai mostrar URL tipo: `tcp://xxxxx.trycloudflare.com:xxxxx`

### 4. Copiar URL
- Copia a URL completa
- Separa em HOST e PORT
- Usa no Railway quando fizeres deploy

---

## 💡 Dica

A URL do Cloudflare Tunnel **NÃO muda** (ao contrário do ngrok grátis)!

---

## ⚠️ Importante

- Mantém o túnel sempre ligado quando quiseres usar a API cloud
- Se fechares a janela, o túnel para
- Para produção, configura como serviço Windows (Task Scheduler)

