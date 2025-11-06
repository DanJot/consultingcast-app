# 🔧 Abrir Túnel Manualmente

## ✅ Script Criado

Criei um script simples para abrir o túnel manualmente:

### Executa Isto:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\abrir-tunel.bat
```

Isto vai abrir uma janela do túnel Cloudflare.

---

## 📋 Passo a Passo

1. **Verifica se a API está a correr** (deve estar na porta 3000)
2. **Executa** `.\scripts\abrir-tunel.bat`
3. **Copia a URL** que aparece (ex: `https://xxxxx.trycloudflare.com`)
4. **Usa essa URL** no Flutter:
   ```powershell
   cd C:\Users\djcas\Documents\ConsultingCast\app2\app2
   flutter run -d chrome --dart-define=API_BASE=<URL_DO_TUNEL>
   ```

---

## 💡 Alternativa Rápida

Se preferires executar diretamente:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast\cloudflared
.\cloudflared.exe tunnel --url http://localhost:3000
```

Depois copia a URL e usa no Flutter!

---

**Executa o script `abrir-tunel.bat` ou o comando acima!**

