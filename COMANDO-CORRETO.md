# ✅ CORRIGIR COMANDO FLUTTER

## ❌ Erro Comum

**NÃO uses** `<` e `>` na URL:
```powershell
# ERRADO:
flutter run -d chrome --dart-define=API_BASE=<https://...>

# CORRETO:
flutter run -d chrome --dart-define=API_BASE=https://...
```

---

## ✅ Comando Correto

```powershell
cd C:\Users\djcas\Documents\ConsultingCast\app2\app2
flutter run -d chrome --dart-define=API_BASE=https://yen-been-homeland-lawyers.trycloudflare.com
```

**Substitui `https://yen-been-homeland-lawyers.trycloudflare.com` pela URL real do teu túnel!**

---

## 📋 Passo a Passo

1. **Abre o túnel** e copia a URL (sem `<` e `>`)
2. **Executa o comando acima** com a URL correta
3. **Aguarda** a compilação (3-5 minutos)
4. **O Chrome abre automaticamente** quando compilar!

---

**Executei o comando com a URL correta. Aguarda a compilação!**

