#!/bin/bash


# -----------------------------------------------
# 1. Инициализация базы для pgbench
# -----------------------------------------------
echo "=== Инициализация pgbench ==="
pgbench -i -s 1 -U pgbench -p 5432 bench

echo "Скриншот 1: вывод инициализации базы (для PDF)"
# Подпись: "Инициализация базы pgbench с масштабом 1"

# -----------------------------------------------
# 2. Запуск нагрузочного теста pgbench
# -----------------------------------------------
echo "=== Нагрузочное тестирование pgbench ==="
pgbench -c 5 -j 2 -T 30 -U pgbench -p 5432 bench

# Подпись: "Результаты 30 секундного теста с 5 клиентами и 2 потоками"

# -----------------------------------------------
# 3. Проверка расширения pg_stat_statements
# -----------------------------------------------
echo "=== Проверка pg_stat_statements ==="
psql -U postgres -p 5432 -d bench -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

# -----------------------------------------------
# 4. Получение самых ресурсоемких запросов
# -----------------------------------------------
echo "=== ТОП 5 по времени выполнения (execution time) ==="
psql -U postgres -p 5432 -d bench -c "
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;
"

echo "=== ТОП 5 по write IO (shared_blks_written) ==="
psql -U postgres -p 5432 -d bench -c "
SELECT query, calls, shared_blks_written, local_blks_written, temp_blks_written
FROM pg_stat_statements
ORDER BY shared_blks_written DESC
LIMIT 5;
"
