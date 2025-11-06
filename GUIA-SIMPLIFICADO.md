# 📋 GUIA SIMPLIFICADO - Uma Janela Para Tudo

## ✅ Solução Simplificada

Criei um script que inicia TUDO de uma vez!

### Executa Isto:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\iniciar-tudo-completo.bat
```

Isto vai:
1. ✅ Abrir API Node.js (nova janela)
2. ✅ Abrir Cloudflare Tunnel (nova janela)  
3. ✅ Executar Flutter Web (abre Chrome automaticamente!)

**Total: 3 janelas apenas!**

---

## 🎯 Ou Se Preferires Manual (Mais Controlo)

### Janela 1: API
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\api-server
node server.js
```

### Janela 2: Túnel
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\cloudflared
.\cloudflared.exe tunnel --url http://localhost:3000
```
Copia a URL que aparecer (ex: `https://xxxxx.trycloudflare.com`)

### Janela 3: Flutter
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\app2\app2
flutter run -d chrome --dart-define=API_BASE=https://xxxxx.trycloudflare.com
```
O Chrome abre automaticamente!

---

## ⚠️ IMPORTANTE

- **Mantém todas as janelas abertas** enquanto usas a app
- **Não feches nenhuma janela** enquanto a app estiver a correr
- A API precisa estar a correr para fazer login
- O túnel precisa estar a correr para expor a API
- O Flutter precisa estar a correr para servir a app

---

**Recomendação: Usa o script `iniciar-tudo-completo.bat` - é mais simples!**

