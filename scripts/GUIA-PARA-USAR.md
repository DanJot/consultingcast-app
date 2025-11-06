# 📖 Guia Completo - Como Usar e Colocar Online

## 🚀 PARTE 1: Como Voltar a Abrir Quando Desligar Tudo

### Método Simples (Recomendado)

1. **Executa o script**: `INICIAR-TUDO.bat`
2. **Quando pedir**: 
   - Se já tens URL guardada, escolhe **S** para usar a mesma
   - Se quiseres novo túnel, escolhe **N**
3. **O script vai**:
   - Iniciar a API Node.js
   - Criar um túnel com localtunnel
   - Obter o teu IP público automaticamente
   - Abrir o browser para desbloquear o túnel
   - Mostrar-te o IP para colares
   - Iniciar o Flutter Web

### ⚠️ IMPORTANTE: URLs do Localtunnel Mudam

Cada vez que inicias o túnel, o `localtunnel` gera uma **URL diferente**.

**Exemplo:**
- Hoje: `https://easy-areas-feel.loca.lt`
- Amanhã: `https://outra-url.loca.lt`
- Depois: `https://mais-uma-url.loca.lt`

**Por isso, sempre que reinicias o PC:**
1. Precisas de executar `INICIAR-TUDO.bat` novamente
2. Criar um novo túnel (ou usar o guardado se ainda estiver ativo)
3. O script atualiza automaticamente o `index.html` com a nova URL

---

## 🌐 PARTE 2: Como Colocar Online SEM PC Ligado

Para ter a app **sempre online** sem precisar do PC ligado, precisas de fazer **deploy** em servidores na nuvem.

### ✅ Opções Gratuitas Disponíveis

#### **Opção 1: Railway.app** ⭐ RECOMENDADO (Mais fácil)

**Vantagens:**
- ✅ Grátis: $5 créditos por mês (suficiente para testes)
- ✅ Deploy automático via GitHub
- ✅ Suporta Node.js E Flutter Web
- ✅ SSL automático (HTTPS)
- ✅ Base de dados MySQL incluída (ou conecta à tua)

**Como fazer:**
1. Cria conta em https://railway.app
2. Conecta repositório GitHub
3. Adiciona serviços:
   - **API Node.js** → Railway detecta automaticamente
   - **Flutter Web** → Upload da pasta `build/web`
4. Configura variáveis de ambiente:
   - `DB_HOST`: 10.1.55.10
   - `DB_PORT`: 3306
   - `DB_USER`: luis
   - `DB_PASSWORD`: Admin1234

**Custo:** Grátis para começar!

---

#### **Opção 2: Render.com** (Alternativa)

**Vantagens:**
- ✅ Grátis: 750 horas/mês
- ✅ SSL automático
- ✅ Deploy automático

**Limitação:** 
- ⚠️ "Hiberna" após 15min sem uso (primeira requisição demora alguns segundos)

**Ideal para:** Testes e desenvolvimento

---

#### **Opção 3: Fly.io** (Rápido)

**Vantagens:**
- ✅ Grátis: 3 VMs grátis
- ✅ Muito rápido
- ✅ Suporta Docker

**Ideal para:** APIs e apps web que precisam de velocidade

---

#### **Opção 4: Combo (Mais Flexível)**

**API Node.js** → Railway.app ou Fly.io
**Flutter Web** → Vercel ou Netlify (deploy mais rápido)

**Vantagens:**
- ✅ Cada serviço no melhor lugar
- ✅ Deploy independente
- ✅ Fácil de atualizar

---

## 📋 Checklist para Deploy Permanente

### Antes de Começar:

- [ ] Tem conta no GitHub (se não tiver, cria em https://github.com)
- [ ] Tem o código da app num repositório GitHub
- [ ] Tem acesso à base de dados MySQL (10.1.55.10) disponível na internet

### Passos Gerais:

1. **Preparar API Node.js:**
   - [ ] Criar `railway.json` ou `Procfile` na pasta `api-server`
   - [ ] Verificar que `package.json` tem `start` script
   - [ ] Testar localmente que funciona

2. **Preparar Flutter Web:**
   - [ ] Executar `flutter build web --release`
   - [ ] Verificar que `build/web` foi criado
   - [ ] Testar localmente que funciona

3. **Deploy no Railway (exemplo):**
   - [ ] Criar conta Railway
   - [ ] Conectar GitHub
   - [ ] Adicionar serviço para API Node.js
   - [ ] Adicionar serviço para Flutter Web (ou usar Vercel)
   - [ ] Configurar variáveis de ambiente
   - [ ] Fazer deploy!

4. **Obter URLs:**
   - [ ] Railway dá-te uma URL tipo: `https://tua-api.railway.app`
   - [ ] Atualizar `index.html` com essa URL
   - [ ] Fazer rebuild do Flutter Web
   - [ ] Deploy do Flutter Web

---

## 🔧 Ficheiros Necessários para Deploy

### Para API Node.js:

**railway.json** (criar na pasta `api-server`):
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "node server.js"
  }
}
```

**package.json** (verificar que tem):
```json
{
  "scripts": {
    "start": "node server.js"
  }
}
```

### Para Flutter Web:

**build/web/** → Upload desta pasta para Vercel/Netlify/Railway

---

## 🎯 Recomendação Final

**Para começar RÁPIDO:**
1. Usa **Railway.app** para tudo (API + Flutter Web)
2. É grátis para começar
3. Deploy automático via GitHub
4. SSL automático

**Quando crescer:**
- Separa API (Railway) e Frontend (Vercel)
- Melhor performance
- Mais flexível

---

## ❓ Dúvidas Frequentes

**Q: Posso continuar a usar localtunnel?**
A: Sim, mas só funciona enquanto o PC está ligado. Para produção, precisa de deploy permanente.

**Q: Quanto custa Railway?**
A: Grátis para começar ($5 créditos/mês). Depois paga apenas o que usar.

**Q: A base de dados MySQL precisa estar acessível na internet?**
A: Sim, a Railway precisa de conseguir ligar-se a `10.1.55.10:3306`. Se for IP privado, pode precisar de VPN ou tornar pública.

**Q: Posso usar a mesma base de dados?**
A: Sim! Basta configurar as mesmas credenciais na Railway.

---

## 📞 Próximos Passos

1. **AGORA**: Continua a usar `INICIAR-TUDO.bat` para desenvolvimento
2. **DEPOIS**: Quando quiseres colocar online permanentemente, segue o guia acima
3. **AJUDA**: Se precisares de ajuda com o deploy, pede ajuda!

---

✨ **Resumo**: Para desenvolvimento, usa `INICIAR-TUDO.bat`. Para produção, faz deploy no Railway ou outra plataforma!

