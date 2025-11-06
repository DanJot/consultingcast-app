# 🚀 Bore.pub - Alternativa Simples para TCP

Bore.pub é uma ferramenta gratuita que cria túneis TCP sem precisar de configuração!

## ✅ Instalação

### Via PowerShell:
```powershell
# Instala Rust (se não tiveres)
# Ou download direto:
Invoke-WebRequest -Uri "https://github.com/ekzhang/bore/releases/latest/download/bore-x86_64-pc-windows-msvc.zip" -OutFile "bore.zip"
Expand-Archive -Path "bore.zip" -DestinationPath "." -Force
```

### Ou via cargo (se tiveres Rust):
```powershell
cargo install bore-cli
```

## 🚀 Usar

```powershell
bore local 3306 --to bore.pub
```

Vai mostrar URL tipo: `bore.pub:12345`

## ✅ Configurar Railway

No Railway, usa:
```
DB_HOST=bore.pub
DB_PORT=12345
```

---

## 💡 Ou: Usar serveo.net (Mais Simples Ainda)

```powershell
ssh -R 3306:localhost:3306 serveo.net
```

Mas precisa de adaptar para MySQL remoto.

---

## 🎯 Recomendação Final

Para desenvolvimento: **Continua Android Studio** ✅

Para produção: Quando precisares, configuramos então!

Quer que eu ajude a configurar bore.pub ou prefere continuar desenvolvimento Android por agora?

