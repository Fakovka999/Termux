#!/bin/bash

FOLDER="Classic"
VERSION="1.21.8"
SERVER_JAR="server.jar"
URL="https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"


# Установка необходимых пакетов
pkg install -y tree nano wget openjdk-21

# Создаём папку, если не существует
mkdir -p "$FOLDER/$VERSION"

# Проверяем наличие файла именно там
if [ ! -f "$FOLDER/$VERSION/$SERVER_JAR" ]; then
    echo "Скачиваем серверный jar..."
    wget -O "$FOLDER/$VERSION/$SERVER_JAR" "$URL"
else
    echo "Файл уже существует: $FOLDER/$VERSION/$SERVER_JAR"
fi

# Первый запуск сервера для создания необходимых файлов
echo "Запуск сервера для инициализации..."
cd "$FOLDER/$VERSION" || exit 1
java -Xmx4096M -Xms2048M -jar "$SERVER_JAR" nogui
# Ждем завершения (сервер запускается, генерирует файлы, затем вылетает)
echo "Генерация завершена"

# Правим eula.txt (соглашаемся с лицензионным соглашением)
echo "Подтверждаем лицензионное соглашение в eula.txt"
if [ -f "eula.txt" ]; then
    sed -i 's/eula=false/eula=true/' "eula.txt"
fi

# Правим server.properties (online-mode=false)
echo "Добавляем online-mode=false в server.properties"
if [ -f "server.properties" ]; then
    sed -i 's/^online-mode=.*/online-mode=false/' "server.properties"
fi

# Создаем Server.sh в папке с версией
cat > "Server.sh" << EOF
#!/bin/bash
java -Xmx4096M -Xms2048M -jar "$SERVER_JAR" nogui
EOF
chmod +x "Server.sh"

# Создаем ServerGUI.sh в той же папке
cat > "ServerGUI.sh" << EOF
#!/bin/bash
screen -S minecraft java -Xmx4096M -Xms2048M -jar "$SERVER_JAR"
EOF
chmod +x "ServerGUI.sh"

echo "Установка завершена. Используйте ./Server.sh для запуска сервера."
