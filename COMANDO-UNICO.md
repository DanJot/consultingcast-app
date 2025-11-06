# 📋 INICIAR TUDO DE UMA VEZ

## ✅ Script Único Criado!

Criei um script que inicia **TUDO** automaticamente!

### Executa Isto:

```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\iniciar-tudo-simples.bat
```

Isto vai:
1. ✅ Limpar processos antigos
2. ✅ Iniciar API Node.js (nova janela)
3. ✅ Iniciar Cloudflare Tunnel (nova janela)
4. ✅ Executar Flutter Web (abre Chrome automaticamente!)

**Total: 3 janelas** (API, Túnel, e esta que executa Flutter)

---

## ⚠️ IMPORTANTE

- **Mantém TODAS as janelas abertas** enquanto usas a app
- **Não feches nenhuma janela** enquanto a app estiver a correr
- A primeira compilação pode demorar 3-5 minutos
- Quando o Chrome abrir, faz login e testa!

---

## 🔍 Se Precisares de Mudar URL do Túnel

Se a URL do túnel mudar (aparece na janela do túnel):
1. Para o Flutter (Ctrl+C nesta janela)
2. Executa novamente:
   ```powershell
   flutter run -d chrome --dart-define=API_BASE=<NOVA_URL>
   ```

---

**Agora fecha tudo e executa só `.\scripts\iniciar-tudo-simples.bat`!**

