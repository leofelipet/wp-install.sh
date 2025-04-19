# WordPress Docker Setup

Script de automação para criação rápida de ambientes WordPress usando Docker e Docker Compose.

## Funcionalidades

- Configuração completa de WordPress, MySQL e phpMyAdmin em containers Docker
- Detecção automática da última versão estável do WordPress
- Verificação de portas disponíveis
- Configuração personalizada de PHP (upload_max_filesize, memory_limit, etc.)
- Suporte a múltiplas versões de PHP

## Requisitos

- Docker
- Docker Compose V2 (comando `docker compose` sem hífen)
- curl
- jq

## Sobre o Docker Compose

Este script utiliza a versão mais recente do Docker Compose (V2), que usa o comando `docker compose` (sem hífen) em vez do antigo `docker-compose` (com hífen). O Docker Compose V2 foi integrado diretamente à CLI do Docker e é a versão recomendada para uso.

Se você ainda estiver usando a versão mais antiga (V1) com o comando `docker-compose`, será necessário atualizar para a versão mais recente do Docker ou modificar o script.

## Como usar

1. Baixe o script
2. Dê permissão de execução: `chmod +x setup-wordpress.sh`
3. Execute: `./setup-wordpress.sh`
4. Siga as instruções interativas

## Configurações

O script solicitará:
- Local de instalação (pasta atual ou nova)
- Nome da aplicação
- Versão do PHP (padrão: 8.1)
- Versão do WordPress (padrão: última estável)
- Porta para acesso web

## Estrutura gerada

- `docker-compose.yml` - Configuração dos containers
- `wp-content/` - Diretório para temas, plugins e uploads
- `php-config/` - Configurações personalizadas do PHP

## Acesso

Após a execução do script, você terá acesso a:
- WordPress: http://localhost:[porta_escolhida]
- phpMyAdmin: http://localhost:[porta_escolhida+2]
- MySQL: porta [porta_escolhida+1]

## Sobre o script

Este script foi desenvolvido para facilitar a criação de ambientes de desenvolvimento WordPress usando a tecnologia de containers Docker. Com ele, você evita a necessidade de configurar manualmente o servidor web, PHP, banco de dados e permissões de arquivos.

O ambiente criado é ideal para desenvolvimento e testes, permitindo que você trabalhe em projetos WordPress sem afetar sua máquina local com múltiplas instalações.

## Segurança

Note que este script usa senhas padrão para o banco de dados em ambiente de desenvolvimento. Para uso em produção, recomenda-se modificar as senhas no arquivo docker-compose.yml gerado.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests com melhorias.

## Licença

MIT
