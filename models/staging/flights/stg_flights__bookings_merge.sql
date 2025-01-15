{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['book_ref'],
        tags = ['bookings'],
        merge_update_columns = ['total_amount'],
        on_schema_change = 'sync_all_columns'
    )
}}
select
        book_ref,
        book_date,
        total_amount
from {{ source('demo_src', 'bookings') }}
{% if is_incremental() %}
WHERE
    book_date > (SELECT MAX(book_date) FROM {{ source('demo_src', 'bookings') }}) - interval '97 day'
{% endif %}
/* Бронировать можно максимум за 90 дней вперед. Записи старше 7 дней не могут изменяться задним числом.
Т.е. берем период 97 дней от макс. даты в таблице бронирования. Это период, за который записи могут изменяться */