# Contagem de Bebidas — Mercearia Amauri (app próprio)

App de contagem que roda no seu endereço (GitHub Pages) com banco no Supabase.
Instala como ícone no celular, funciona em Android e iPhone.

## 1. GitHub — publicar o app

1. Crie o repositório `contagem-amauri` em github.com (pode ser público; a chave que vai nele é a chave pública do Supabase).
2. Envie **todos os arquivos desta pasta** para a raiz do repositório (botão *Add file › Upload files*, arraste tudo).
3. Vá em **Settings › Pages**: em *Source* escolha **Deploy from a branch**, branch `main`, pasta `/ (root)`, e salve.
4. Em um ou dois minutos o app fica no ar em `https://SEU-USUARIO.github.io/contagem-amauri/`.

## 2. Supabase — criar o banco

1. Crie a conta em supabase.com e um projeto novo (região **South America (São Paulo)**).
2. Em **SQL Editor › New query**, cole o `schema.sql` e rode. Depois faça o mesmo com o `seed.sql`
   (cria os 3 ambientes e os 286 produtos da planilha, com Smirnoff em 305 g de tara).
3. Em **Project Settings › API**, copie a **Project URL** e a chave **anon public**.

## 3. Ligar os dois

Abra o app no celular. Na primeira vez ele pede a URL e a chave — cole e salve (fica guardado no aparelho).
Para a equipe não precisar colar nada, edite o arquivo `config.js` no GitHub e preencha:

```js
window.SUPABASE_URL = 'https://xxxx.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```

## 4. Instalar no celular

- **Android (Chrome):** menu ⋮ › *Instalar app* / *Adicionar à tela inicial*.
- **iPhone (Safari):** botão compartilhar › *Adicionar à Tela de Início*.

## 5. Primeiro uso

O app pede para criar o acesso do gestor (nome + PIN de 4 dígitos).
Depois, em **Cadastro › Equipe**, cadastre as outras pessoas como *contador* ou *gestor*.

## Observações

- **Segurança:** o PIN identifica quem lançou e separa gestor de contador. Quem tiver o endereço do app
  e a chave pública consegue ler os dados por fora dele. Se um dia quiser fechar de verdade, dá para trocar
  por login de e-mail e senha do Supabase sem refazer o app.
- **Internet:** a contagem grava direto no banco; sem internet o app abre, mas não salva.
- **Excel:** o botão "Gerar planilha Excel" baixa o arquivo no próprio aparelho.
- **Drive:** o envio automático para a pasta compartilhada ainda está no app do Claude. Para fazer isso aqui,
  falta criar uma credencial Google (OAuth) — é o próximo passo.
