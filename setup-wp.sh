#!/bin/bash

# Função para exibir mensagens coloridas
print_info() {
    echo -e "\033[1;34m$1\033[0m"  # Azul
}

print_success() {
    echo -e "\033[1;32m$1\033[0m"  # Verde
}

print_warning() {
    echo -e "\033[1;33m$1\033[0m"  # Amarelo
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"  # Vermelho
}

# Função para verificar se a porta já está em uso (usando ss em vez de netstat)
check_port() {
    if ss -tuln | grep ":$1 "; then
        return 1  # Porta em uso
    else
        return 0  # Porta livre
    fi
}

# Função para obter a última versão estável do WordPress
get_latest_wp_version() {
    latest_version=$(curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r '.offers[0].current')
    echo $latest_version
}

# Verifica se o docker compose está instalado
if ! command -v docker &> /dev/null; then
    print_error "O Docker não está instalado. Por favor, instale o Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose não encontrado. Por favor, instale o Docker Compose."
    exit 1
fi

# Pergunta sobre o diretório de instalação
print_info "Onde deseja instalar a aplicação?"
echo "1 - Na pasta atual"
echo "2 - Nova pasta"
read dir_choice

print_info "Digite o nome da aplicação:"
read app_name

# Configuração do diretório de instalação
if [ "$dir_choice" == "2" ]; then
    install_dir="wp-${app_name}"
    mkdir -p $install_dir
else
    install_dir="."
fi

cd $install_dir

# Solicita as informações do usuário
print_info "Versão do PHP [8.1]:"
read php_version
if [ -z "$php_version" ]; then
    php_version="8.1"  # Valor padrão para PHP
fi

# Obtém a última versão estável do WordPress
wp_version=$(get_latest_wp_version)
print_info "Versão do WordPress [${wp_version}]:"
read wp_version_input

# Se o usuário fornecer uma versão, sobrescreve o valor
if [ -n "$wp_version_input" ]; then
    wp_version="$wp_version_input"
fi

# Solicita a porta para a aplicação
while true; do
    print_info "Porta para a aplicação (exemplo: 8000):"
    read app_port
    check_port $app_port
    if [ $? -eq 0 ]; then
        break
    else
        print_warning "A porta $app_port já está em uso. Por favor, escolha uma porta diferente."
    fi
done

# Configurações do PHP
upload_max_filesize="1024M"
post_max_size="1024M"
memory_limit="256M"
max_execution_time="300"

# Definindo as portas do banco de dados e phpMyAdmin com base na porta da aplicação
db_port=$((app_port + 1))
phpmyadmin_port=$((app_port + 2))

# Criar o conteúdo do docker-compose.yml
print_info "Gerando o arquivo docker-compose.yml..."
cat > docker-compose.yml <<EOF
version: '3'

services:
  wordpress:
    image: wordpress:${wp_version}-php${php_version}-apache
    container_name: ${app_name}
    ports:
      - "$app_port:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - ./wp-content:/var/www/html/wp-content
      - ./php-config/php.ini:/usr/local/etc/php/php.ini
    depends_on:
      - db

  db:
    image: mysql:5.7
    container_name: db-${app_name}
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "$db_port:3306"

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin-${app_name}
    ports:
      - "$phpmyadmin_port:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: root

volumes:
  db_data:
EOF

# Subir o container com Docker Compose
print_info "Subindo containers..."
docker compose up -d

# Função para verificar se o container está rodando
wait_for_container() {
    container_name=$1
    print_info "Aguardando o container $container_name iniciar..."
    while ! docker inspect --format '{{.State.Running}}' $container_name | grep -q "true"; do
        print_warning "Aguardando o container $container_name estar em execução..."
        sleep 2
    done
    print_success "Container $container_name está em execução."
}

# Esperar os containers WordPress, db e phpMyAdmin estarem prontos
wait_for_container $app_name
wait_for_container "db-${app_name}"
wait_for_container "phpmyadmin-${app_name}"

# Após os containers estarem prontos, configure as permissões e o php.ini
print_success "Todos os containers estão em funcionamento!"

# Adicionando permissões no diretório wp-content
print_info "Configurando permissões no diretório ./wp-content..."
sudo chown -R www-data:www-data ./wp-content
sudo chmod -R 755 ./wp-content

# Criar o arquivo php.ini com as configurações fornecidas
mkdir -p php-config
cat > php-config/php.ini <<EOF
upload_max_filesize = ${upload_max_filesize}
post_max_size = ${post_max_size}
memory_limit = ${memory_limit}
max_execution_time = ${max_execution_time}
EOF


# Exibe uma mensagem de conclusão
print_success "O arquivo docker-compose.yml foi gerado e os containers foram iniciados com sucesso!"
print_success "A última versão estável do WordPress foi instalada."
print_success "O arquivo php.ini foi configurado com os valores fornecidos."
print_success "As permissões para o diretório ./wp-content foram ajustadas."
print_success "Acesse o WordPress em http://localhost:$app_port"
print_success "Acesse o phpMyAdmin em http://localhost:$phpmyadmin_port"
print_success "Acesse o banco de dados MySQL na porta $db_port"
