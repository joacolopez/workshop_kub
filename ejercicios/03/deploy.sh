#!/bin/bash

# Function to show help
function show_help {
    echo "Usage: $0 -s <stack_name> [-m <mysql_version>] [-n <nginx_version>] [-p <php_version>]"
    echo ""
    echo "Options:"
    echo "  -s <stack_name>      Stack name (mandatory)"
    echo "  -m <mysql_version>   MySQL version (optional, default: 5.7)"
    echo "  -n <nginx_version>   NGINX version (optional, default: alpine)"
    echo "  -p <php_version>     PHP version (optional, default: 8.1)"
    echo "  --help               Show this help and exit"
}

# Verify if Docker is installed
function check_docker {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Please install Docker and try again."
        exit 1
    fi
}

# Verify if Docker Compose is installed
function check_docker_compose {
    if ! command -v docker compose &> /dev/null; then
        echo "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
}

# Default variables
MYSQL_VERSION="5.7"
NGINX_VERSION="alpine"
PHP_VERSION="81"  # In Alpine, PHP packages are versioned without a dot
STACK_NAME=""

# Parse options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--stack) STACK_NAME="$2"; shift ;;
        -m|--mysql) MYSQL_VERSION="$2"; shift ;;
        -n|--nginx) NGINX_VERSION="$2"; shift ;;
        -p|--php) PHP_VERSION="${2//./}"; shift ;;  # Remove dot from PHP version
        --help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Verify that stack name is provided
if [ -z "$STACK_NAME" ]; then
    echo "Error: Stack name is mandatory."
    show_help
    exit 1
fi

# Verify Docker and Docker Compose are installed
check_docker
check_docker_compose

# Environment variables
MYSQL_ROOT_PASSWORD=imroot
MYSQL_DATABASE=testdb
MYSQL_USER=pepe
MYSQL_PASSWORD=strongpassword

# Create directory structure
echo "Creating directory structure..."
mkdir -p ${STACK_NAME}/nginx

# Create .env file in the stack directory
echo "Creating .env file..."
cat <<EOL > ${STACK_NAME}/.env
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
EOL

# Create index.php file
cat <<EOL > ${STACK_NAME}/nginx/index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Basic webapp with Docker</title>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .container {
            width: 50%;
            margin: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
        form {
            margin-top: 20px;
        }
        form input, form button {
            padding: 10px;
            margin: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Nginx + DB - Basic CRUD webapp</h1>
        
        <?php
        // Get environment variables
        \$servername = "db";
        \$username = getenv('MYSQL_USER');
        \$password = getenv('MYSQL_PASSWORD');
        \$database = getenv('MYSQL_DATABASE');

        // Create connection
        try {
            \$dsn = "mysql:host=\$servername;dbname=\$database";
            \$options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            \$pdo = new PDO(\$dsn, \$username, \$password, \$options);
        } catch (PDOException \$e) {
            echo "<p>Error: " . \$e->getMessage() . "</p>";
            exit;
        }

        // Handle form submission
        if (\$_SERVER['REQUEST_METHOD'] == 'POST') {
            if (isset(\$_POST['action'])) {
                \$action = \$_POST['action'];
                if (\$action == 'create') {
                    \$name = \$_POST['name'];
                    \$email = \$_POST['email'];
                    \$stmt = \$pdo->prepare("INSERT INTO users (name, email) VALUES (:name, :email)");
                    \$stmt->execute(['name' => \$name, 'email' => \$email]);
                } elseif (\$action == 'update') {
                    \$id = \$_POST['id'];
                    \$name = \$_POST['name'];
                    \$email = \$_POST['email'];
                    \$stmt = \$pdo->prepare("UPDATE users SET name = :name, email = :email WHERE id = :id");
                    \$stmt->execute(['name' => \$name, 'email' => \$email, 'id' => \$id]);
                } elseif (\$action == 'delete') {
                    \$id = \$_POST['id'];
                    \$stmt = \$pdo->prepare("DELETE FROM users WHERE id = :id");
                    \$stmt->execute(['id' => \$id]);
                }
            }
        }

        // Fetch records
        \$stmt = \$pdo->query("SELECT * FROM users");
        \$users = \$stmt->fetchAll();
        ?>

        <!-- Display records -->
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach (\$users as \$user): ?>
                    <tr>
                        <td><?php echo htmlspecialchars(\$user['id']); ?></td>
                        <td><?php echo htmlspecialchars(\$user['name']); ?></td>
                        <td><?php echo htmlspecialchars(\$user['email']); ?></td>
                        <td>
                            <form style="display:inline-block;" method="post">
                                <input type="hidden" name="id" value="<?php echo \$user['id']; ?>">
                                <input type="hidden" name="name" value="<?php echo \$user['name']; ?>">
                                <input type="hidden" name="email" value="<?php echo \$user['email']; ?>">
                                <input type="hidden" name="action" value="delete">
                                <button type="submit">Delete</button>
                            </form>
                            <button onclick="editUser('<?php echo \$user['id']; ?>', '<?php echo \$user['name']; ?>', '<?php echo \$user['email']; ?>')">Edit</button>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <!-- User form -->
        <form method="post">
            <input type="hidden" name="id" id="userId">
            <input type="hidden" name="action" id="formAction" value="create">
            <input type="text" name="name" id="userName" placeholder="Name" required>
            <input type="email" name="email" id="userEmail" placeholder="Email" required>
            <button type="submit">Submit</button>
            <button type="reset" onclick="resetForm()">Reset</button>
        </form>
    </div>

    <script>
        function editUser(id, name, email) {
            document.getElementById('userId').value = id;
            document.getElementById('userName').value = name;
            document.getElementById('userEmail').value = email;
            document.getElementById('formAction').value = 'update';
        }

        function resetForm() {
            document.getElementById('userId').value = '';
            document.getElementById('formAction').value = 'create';
        }
    </script>
</body>
</html>
EOL

# Create Dockerfile for NGINX
cat <<EOL > ${STACK_NAME}/nginx/Dockerfile
FROM nginx:${NGINX_VERSION}

# Install PHP and dependencies
RUN apk --no-cache add php81 php81-fpm php81-pdo php81-pdo_mysql

# Create directory if it doesn't exist
RUN mkdir -p /etc/php81/php-fpm.d/

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.php /usr/share/nginx/html/index.php
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
COPY php-fpm.conf /etc/php81/php-fpm.d/www.conf

# Start PHP-FPM and NGINX
CMD ["sh", "-c", "/usr/local/bin/wait-for-db.sh"]
EOL

# Create php-fpm.conf file
cat <<EOL > ${STACK_NAME}/nginx/php-fpm.conf
[global]
daemonize = no

[www]
listen = 127.0.0.1:9000
listen.allowed_clients = 127.0.0.1
user = nginx
group = nginx
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
env[MYSQL_USER] = ${MYSQL_USER}
env[MYSQL_PASSWORD] = ${MYSQL_PASSWORD}
env[MYSQL_DATABASE] = ${MYSQL_DATABASE}
env[MYSQL_ROOT_PASSWORD] = ${MYSQL_ROOT_PASSWORD}
clear_env = no
EOL

# Create wait-for-db.sh script
cat <<EOL > ${STACK_NAME}/nginx/wait-for-db.sh
#!/bin/sh

# Wait for the database to be available
echo "Waiting for the database to be available..."
until nc -z -v -w60 db 3306; do
    echo "Waiting for the database..."
    sleep 10
done

echo "Database is available, starting services..."
php-fpm81 -F & nginx -g 'daemon off;'
EOL

# Make wait-for-db.sh executable
chmod +x ${STACK_NAME}/nginx/wait-for-db.sh

# Create NGINX configuration file
cat <<EOL > ${STACK_NAME}/nginx/nginx.conf
user  nginx;
worker_processes   1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        root   /usr/share/nginx/html;
        index  index.php;

        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        location ~ \.php\$ {
            include fastcgi_params;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
EOL

# Create docker-compose.yml file
cat <<EOL > ${STACK_NAME}/docker-compose.yml
version: '3.8'

services:
  nginx:
    build: ./nginx
    ports:
      - "80:80"
    env_file:
      - ./.env
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/index.php:/usr/share/nginx/html/index.php
      - ./nginx/php-fpm.conf:/etc/php81/php-fpm.d/www.conf
      - ./nginx/wait-for-db.sh:/usr/local/bin/wait-for-db.sh
    networks:
      - stack_network

  db:
    image: mysql:${MYSQL_VERSION}
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${MYSQL_DATABASE}
      MYSQL_USER: \${MYSQL_USER}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - stack_network

networks:
  stack_network:
    driver: bridge

volumes:
  db_data:
EOL

# Stop and remove existing containers but keep volumes
echo "Stopping and removing existing containers but keeping volumes..."
docker compose -f ${STACK_NAME}/docker-compose.yml down

# Build images to reflect changes
echo "Building images..."
docker compose -f ${STACK_NAME}/docker-compose.yml build

# Deploy services with Docker Compose
echo "Deploying services with Docker Compose..."
docker compose -f ${STACK_NAME}/docker-compose.yml up -d

# Wait for the MySQL server to be ready
echo "Waiting for MySQL server to be ready..."
until docker exec -i $(docker compose -f ${STACK_NAME}/docker-compose.yml ps -q db) mysqladmin ping -h"db" --silent; do
    echo "Waiting for the database connection..."
    sleep 10
done

# Create the users table in the database if it does not exist
echo "Creating users table in the database if it does not exist..."
docker exec -i $(docker compose -f ${STACK_NAME}/docker-compose.yml ps -q db) mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h db ${MYSQL_DATABASE} <<EOF
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);
EOF

echo "Deployment completed. You can access NGINX at http://localhost"
