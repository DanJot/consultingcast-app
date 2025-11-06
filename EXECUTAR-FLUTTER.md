# 🚀 Executar Flutter Web - Instruções

## ✅ Status Atual

- ✅ API Node.js: A correr
- ✅ Cloudflare Tunnel: Ativo
- ✅ Flutter: A compilar (vejo processos Dart a correr)

---

## 🎯 Executa Isto Agora

Abre PowerShell e executa:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\executar-flutter-web.bat
```

**OU** executa diretamente:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast\app2\app2
flutter run -d chrome --dart-define=API_BASE=https://meditation-responsibilities-dryer-usr.trycloudflare.com
```

---

## ⚠️ Importante

- A primeira compilação pode demorar **alguns minutos**
- Vais ver mensagens de compilação no terminal
- Quando terminar, o Chrome abre automaticamente
- **Não feches o terminal** enquanto compila!

---

## 🔍 Se Não Abrir

1. Verifica se há erros no terminal
2. Verifica se a API está a correr
3. Verifica se o túnel está ativo
4. Podes tentar abrir manualmente: `http://localhost:porta` (a porta aparece no terminal)

---

**Executa o comando acima e aguarda a compilação! Pode demorar alguns minutos na primeira vez.**

