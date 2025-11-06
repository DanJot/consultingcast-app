# ⚠️ IMPORTANTE: Túnel TCP Cloudflare

O Cloudflare Tunnel requer configuração especial para TCP.

## 🔧 Solução: Configurar Túnel TCP Corretamente

O método `--url` não funciona bem para TCP. Precisamos criar um túnel nomeado primeiro.

### Passo 1: Autenticar (se ainda não fizeste)
```powershell
cd C:\Users\djcas\Documents\ConsultingCast\cloudflared
.\cloudflared.exe login
```
- Na página, pode clicar "Skip" ou fechar - vamos usar método sem zona

### Passo 2: Criar Túnel Nomeado
```powershell
.\cloudflared.exe tunnel create consultingcast-mysql
```

### Passo 3: Configurar Túnel TCP

Cria ficheiro `config.yml` na pasta cloudflared:

```yaml
tunnel: consultingcast-mysql
credentials-file: C:\Users\djcas\.cloudflared\<tunnel-id>.json

ingress:
  - service: tcp://10.1.55.10:3306
```

**Substitui `<tunnel-id>` pelo ID real que aparece quando crias o túnel**

### Passo 4: Iniciar Túnel
```powershell
.\cloudflared.exe tunnel run consultingcast-mysql
```

---

## 💡 Alternativa Mais Simples: Usar ngrok com Cartão

Se não quiseres complicar com Cloudflare:
- ngrok com cartão ($8/mês) dá URL fixa TCP
- Mais simples de configurar

---

## 🔄 Ou: Continuar com MySQL Direto

Para desenvolvimento, podes continuar a usar:
- Android Studio → MySQL direto (já funciona!)
- Windows Desktop → MySQL direto (já funciona!)

A API cloud só é necessária para produção Web.

---

Qual preferes:
1. Continuar a configurar Cloudflare Tunnel TCP?
2. Usar ngrok com cartão ($8/mês)?
3. Continuar desenvolvimento só Android/Desktop por agora?

