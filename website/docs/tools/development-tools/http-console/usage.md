---
sidebar_position: 3
---

# Использование

## Быстрый старт

1. Откройте меню **Универсальные инструменты → Консоль HTTP-запросов**.
2. Укажите URL эндпоинта.
3. Выберите метод HTTP (GET, POST и т.д.).
4. При необходимости настройте заголовки и тело запроса.
5. Нажмите **Выполнить** и просмотрите ответ.

## Сценарии использования

### Сценарий 1: GET-запрос к REST API

```
GET https://api.example.com/v1/products
Headers:
  Accept: application/json
  Authorization: Bearer {{token}}
```

Ответ будет отображён в панели результатов. JSON можно скопировать в [Редактор JSON](/docs/tools/development-tools/json-editor) для анализа.

### Сценарий 2: POST-запрос с JSON-телом

```
POST https://api.example.com/v1/orders
Headers:
  Content-Type: application/json
  Authorization: Bearer {{token}}

Body:
{
    "customer_id": "12345",
    "items": [
        {"product_id": "ABC", "quantity": 2},
        {"product_id": "XYZ", "quantity": 1}
    ],
    "delivery_date": "2026-07-01"
}
```

### Сценарий 3: Работа с веб-хуками

Проверка входящего веб-хука от внешней системы:

```
POST https://hook.example.com/payment
Headers:
  Content-Type: application/x-www-form-urlencoded

Body:
event=payment.completed&order_id=ORD-2026-001&amount=1500.00
```

После выполнения проверьте код ответа — `200 OK` означает успешный приём.
