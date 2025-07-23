
#!/bin/bash

source_dir="/your/source/dir"

target_dir="/your/target/dir"

mkdir -p "$target_dir"

# цикл по всем файлам в каталоге
for file in "$source_dir"/*; do
    filename=$(basename "$file")
    
    # переименовываем файл, добавляя точку в конец
    new_filename="$filename."
    
    # тащим переименованный файл в целевую папку
    mv "$file" "$target_dir/$new_filename"
done
