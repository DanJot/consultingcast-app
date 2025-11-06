# 🎯 GUIA FINAL - Tudo Pronto!

## ✅ O Que Foi Configurado

1. ✅ **API Node.js** criada e configurada
2. ✅ **Scripts** criados para facilitar
3. ✅ **Cloudflare Tunnel** preparado
4. ✅ **Documentação** completa

---

## 🚀 Como Usar (3 Passos Simples)

### Passo 1: Instalar Dependências (SE AINDA NÃO FIZESTE)

Abre PowerShell na pasta `api-server`:
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\api-server
npm install
```

Isto instala: `express`, `mysql2`, `bcrypt`, `cors`

---

### Passo 2: Iniciar API + Túnel

**Opção A: Tudo Automático** (Recomendado)
```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\iniciar-tudo.bat
```

Isto vai:
- Iniciar API Node.js
- Criar túnel Cloudflare
- Mostrar URL do túnel

**Opção B: Manual (2 Janelas)**

**Janela 1 - API:**
```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\iniciar-api.bat
```

**Janela 2 - Túnel:**
```powershell
cd C:\Users\djcas\Documents\ConsultingCast
.\scripts\tunel-http-cloudflare.bat
```

---

### Passo 3: Copiar URL e Usar no Flutter

Na janela do túnel, vais ver algo como:
```
+--------------------------------------------------------------------------------------------+
|  Your quick Tunnel has been created! Visit it at (it may take some time to be reachable): |
|  https://xxxxx-xxxxx.trycloudflare.com                                                     |
+--------------------------------------------------------------------------------------------+
```

**Copia essa URL!** 📋

Depois executa:
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\app2\app2
flutter run -d chrome --dart-define=API_BASE=https://xxxxx-xxxxx.trycloudflare.com
```

**Substitui `https://xxxxx-xxxxx.trycloudflare.com` pela URL real!**

---

## 🔍 Verificar Status

Para verificar se tudo está a correr:
```powershell
.\scripts\verificar-status.bat
```

---

## 📁 Scripts Criados

- `scripts/iniciar-api.bat` - Inicia API Node.js
- `scripts/tunel-http-cloudflare.bat` - Cria túnel HTTP
- `scripts/iniciar-tudo.bat` - Inicia tudo automaticamente
- `scripts/verificar-status.bat` - Verifica se está tudo a correr
- `scripts/tunel-http-localtunnel.bat` - Alternativa (LocalTunnel)

---

## ⚠️ IMPORTANTE

- **Deixa a API a correr** (não feches a janela)
- **Deixa o túnel a correr** (não feches a janela)
- A URL muda cada vez que reinicias o túnel
- Mas é **100% GRATUITO** e funciona! ✅

---

## 🎯 Agora Faz Isto:

1. **Instala dependências** (se ainda não fizeste):
   ```powershell
   cd api-server
   npm install
   ```

2. **Inicia tudo**:
   ```powershell
   cd ..
   .\scripts\iniciar-tudo.bat
   ```

3. **Copia a URL** que aparece

4. **Executa Flutter** com a URL:
   ```powershell
   cd app2\app2
   flutter run -d chrome --dart-define=API_BASE=<URL_DO_TUNEL>
   ```

---

**Pronto! Agora é só seguir os passos acima! 🚀**

