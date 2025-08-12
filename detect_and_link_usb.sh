#!/bin/bash

# Папка, где лежат ссылки
SOURCE_DIR="$HOME/storage"

# Паттерн для поиска пути SD-карты
PATTERN='[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}'

# Счетчик для usbN
count=0

# Цикл по всем объектам в SOURCE_DIR
for link in "$SOURCE_DIR"/*; do
  # Проверяем, что это символическая ссылка
  if [ -L "$link" ]; then
    # Узнаем путь, куда ведет ссылка
    target=$(readlink -f "$link")

    # Проверяем, есть ли в target путь с шаблоном XXXX-XXXX
    if echo "$target" | grep -qE "$PATTERN"; then
      # Берем часть пути с XXXX-XXXX
      mount_point=$(echo "$target" | grep -oE "/storage/$PATTERN")

      # Создаем символьную ссылку в ~/ с именем usbN, если еще не существует
      if [ ! -e "$HOME/usb$count" ]; then
        ln -s "$mount_point" "$HOME/usb$count"
        echo "Создана ссылка: usb$count -> $mount_point"
        count=$((count + 1))
      fi
    fi
  fi
done
