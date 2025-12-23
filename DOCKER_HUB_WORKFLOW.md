# Configuração do Workflow Docker Hub

## Visão Geral
Este repositório inclui um workflow do GitHub Actions que constrói e publica automaticamente uma imagem Docker no Docker Hub.

## Secrets Necessários
Para usar este workflow, você precisa configurar os seguintes secrets no seu repositório GitHub:

1. Acesse seu repositório no GitHub
2. Navegue até **Settings** → **Secrets and variables** → **Actions**
3. Adicione os seguintes secrets:

### DOCKER_USERNAME
Seu nome de usuário do Docker Hub (ex: `josemaeldon`)

### DOCKER_PASSWORD
Sua senha do Docker Hub ou token de acesso (recomendado usar um token de acesso ao invés da senha)

Para criar um token de acesso do Docker Hub:
1. Faça login no [Docker Hub](https://hub.docker.com)
2. Vá em **Account Settings** → **Security**
3. Clique em **New Access Token**
4. Dê uma descrição (ex: "GitHub Actions")
5. Copie o token e adicione-o como o secret `DOCKER_PASSWORD`

## Gatilhos do Workflow

O workflow será executado automaticamente quando:

1. **Push para branch main/master**: Cria e publica imagens com a tag do nome do branch e `latest`
2. **Criação de tag**: 
   - Formato da tag: `v1.3.17` ou `1.3.17`
   - Cria múltiplas tags: versão completa, major.minor e versão major
3. **Disparo manual**: Execute manualmente pela aba GitHub Actions com uma tag personalizada

## Tags da Imagem Docker

O workflow cria múltiplas tags para flexibilidade:

- `josemaeldon/akaunting-pro-1.3.17:latest` - Versão mais recente da branch main/master
- `josemaeldon/akaunting-pro-1.3.17:1.3.17` - Versão específica (de tags)
- `josemaeldon/akaunting-pro-1.3.17:1.3` - Versão major.minor
- `josemaeldon/akaunting-pro-1.3.17:1` - Versão major

## Usando a Imagem Docker

### Exemplo Docker Compose

```yaml
version: "3.7"

services:
  app:
    image: josemaeldon/akaunting-pro-1.3.17:latest
    working_dir: /var/www/html
    volumes:
      - app_data:/var/www/html
    ports:
      - "80:80"
    environment:
      - DB_HOST=mysql
      - DB_DATABASE=akaunting
      - DB_USERNAME=akaunting
      - DB_PASSWORD=password

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: akaunting
      MYSQL_USER: akaunting
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  app_data:
  mysql_data:
```

### Exemplo Docker Swarm Stack

```yaml
version: "3.7"

services:
  app:
    image: josemaeldon/akaunting-pro-1.3.17:1.3.17
    working_dir: /var/www/html

    volumes:
      - contabilidade_app_data:/var/www/html

    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.docker.network=luzianet"
        - "traefik.http.routers.contabilidade.rule=Host(`caixa.santaluzia.org`)"
        - "traefik.http.routers.contabilidade.entrypoints=websecure"
        - "traefik.http.routers.contabilidade.tls=true"
        - "traefik.http.routers.contabilidade.tls.certresolver=letsencryptresolver"
        - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
        - "traefik.http.routers.contabilidade.middlewares=redirect-to-https"
        - "traefik.http.routers.contabilidade.service=contabilidade-service"
        - "traefik.http.services.contabilidade-service.loadbalancer.server.port=80"

    networks:
      - luzianet

volumes:
  contabilidade_app_data:
    external: true

networks:
  luzianet:
    external: true
```

## Recursos da Imagem

A imagem Docker inclui:

- **PHP 7.4** com servidor web Apache configurado e otimizado
- **Apache VirtualHost** configurado com DocumentRoot apontando para `/var/www/html/public`
- **Extensões PHP**: pdo_mysql, gd, zip, mbstring, xml, curl, bcmath, opcache
- **Composer**: Pré-instalado para gerenciamento de dependências
- **Módulos Apache habilitados**: mod_rewrite, mod_headers
- **Multi-arquitetura**: Suporta linux/amd64 e linux/arm64
- **Otimizado para Produção**: 
  - OPcache habilitado para melhor desempenho
  - Autoloader otimizado para produção
  - Permissões de arquivo adequadas
  - Apache com configuração de segurança
  - Imagens publicadas corretamente como tipo "image" no Docker Hub (provenance desabilitado)
- **Entrypoint inteligente**: 
  - Instala dependências do Composer automaticamente se não instaladas
  - Configura permissões corretas ao iniciar
  - Inicia Apache em foreground

## Configuração Inicial

Ao executar o container pela primeira vez:

1. O container automaticamente instalará as dependências PHP se necessário
2. Acesse a aplicação através do seu navegador (ex: http://localhost:8080)
3. Complete o assistente de instalação do Akaunting
4. Configure a conexão com o banco de dados:
   - Host: mysql (ou nome do serviço de banco de dados)
   - Database: akaunting_db (ou conforme configurado)
   - Username: akaunting_admin (ou conforme configurado)
   - Password: akaunting_password (ou conforme configurado)
5. Configure os detalhes da sua empresa

**Nota**: O Apache está configurado para servir a aplicação do diretório `/var/www/html/public`, que é o padrão para aplicações Laravel/Akaunting.

## Solução de Problemas

### Problemas de Permissão
Se você encontrar problemas de permissão com os diretórios storage ou cache:
```bash
docker exec -it <nome_container> chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
docker exec -it <nome_container> chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
```

### Conexão com Banco de Dados
Certifique-se de que seu banco de dados está acessível pelo container e que as variáveis de ambiente estão configuradas corretamente.

### Logs
Para visualizar os logs da aplicação:
```bash
docker logs <nome_container>
```

## Build Manual

Para construir a imagem manualmente:

```bash
docker build -t josemaeldon/akaunting-pro-1.3.17:1.3.17 .
docker push josemaeldon/akaunting-pro-1.3.17:1.3.17
```

## Suporte

Para questões relacionadas a:
- **Aplicação Akaunting**: Visite o [Fórum Akaunting](https://akaunting.com/forum)
- **Imagem Docker**: Abra uma issue neste repositório
- **Workflow**: Verifique os logs do GitHub Actions na aba "Actions"
