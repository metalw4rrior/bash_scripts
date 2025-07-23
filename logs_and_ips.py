import re
from collections import Counter

log_file_path = "access.log"
#  для записи IP-адресов
output_file_path = "filtered_ips.txt"

# реджекс для поиска IP-адресов в строке
ip_pattern = r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
ip_counter = Counter()

with open(log_file_path, 'r') as file:
    for line in file:
        if "403" in line and "200" not in line:
            ips_in_line = re.findall(ip_pattern, line)
            ip_counter.update(ips_in_line)

sorted_ips = sorted(ip_counter.items(), key=lambda x: x[1], reverse=True)

with open(output_file_path, 'w') as output_file:
    output_file.write("IP адреса и количество повторений (отсортированные по убыванию):\n")
    for ip, count in sorted_ips:
        output_file.write(f"{ip}: {count}\n")

print(f"отсортированные IP адреса были записаны в файл: {output_file_path}")
